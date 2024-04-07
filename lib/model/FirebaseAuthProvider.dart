import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';

class AuthResult {
  final User? user;
  final String? error;
  final String? type;

  AuthResult({this.user, this.error, this.type});
}

class FirebaseAuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirebaseAuth get auth => _auth;

  Future<String?> determineUserType() async {
    String userId = _auth.currentUser!.uid;

    CollectionReference consumersCollection =
        FirebaseFirestore.instance.collection("consumers");
    DocumentSnapshot snapshotConsumer =
        await consumersCollection.doc(userId).get();
    if (snapshotConsumer.exists) {
      return "consumer";
    } else {
      CollectionReference foodProviderCollection =
          FirebaseFirestore.instance.collection("providers");
      DocumentSnapshot snapshotFoodProvider =
          await foodProviderCollection.doc(userId).get();
      if (snapshotFoodProvider.exists) {
        return "provider";
      } else {
        CollectionReference adminCollection =
            FirebaseFirestore.instance.collection("admins");
        DocumentSnapshot snapshotAdmin =
            await adminCollection.doc(userId).get();
        if (snapshotAdmin.exists) {
          return "admin";
        }
        if (snapshotAdmin.exists!) {
          return null;
        }
      }
    }
  }

  Future<AuthResult> registerConsumer(
      String name, String email, String password, String phoneNumber) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      await _auth.signOut();

      DocumentReference doc =
          _firestore.collection('consumers').doc(credential.user!.uid);

      Map<String, dynamic> consumerData = {
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber
      };

      await doc.set(consumerData);

      return AuthResult(user: credential.user);
    } catch (e) {
      if (e is FirebaseAuthException) {
        if (e.code == 'email-already-in-use') {
          return AuthResult(error: 'email sudah digunakan.');
        } else if (e.code == 'weak-password') {
          return AuthResult(error: 'password terlalu lemah.');
        } else {
          return AuthResult(error: 'error: ${e.code}');
        }
      } else {
        return AuthResult(error: 'error: $e');
      }
    }
  }

  Future<AuthResult> registerFoodProvider(String name, String email,
      String password, String phoneNumber, String address, String city) async {
    try {

      city = city.toLowerCase();
      city = city.substring(0, 1).toUpperCase() + city.substring(1);

      List<Location> checklocal = await locationFromAddress('$city');

      List<Location> checkLoc = await locationFromAddress('$address');

      List<Location> locations = await locationFromAddress('$address, $city');
      double lat = locations[0].latitude;
      double lng = locations[0].longitude;

      List<Placemark> placemarks = await placemarkFromCoordinates(lat,lng);
      String? postalcode= placemarks[0].postalCode;


      UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      await _auth.signOut();

      DocumentReference doc =
          _firestore.collection('providers').doc(credential.user!.uid);

      Map<String, dynamic> providerData = {
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'address': address,
        'latitude': lat,
        'longitude': lng,
        if(postalcode!=null) 'postalcode':postalcode,
        'city': city,
        'status': 'unverified'
      };

      await doc.set(providerData);

      return AuthResult(user: credential.user);
    } catch (e) {
      if (e is FirebaseAuthException) {
        if (e.code == 'email-already-in-use') {
          return AuthResult(error: 'email sudah digunakan.');
        } else if (e.code == 'weak-password') {
          return AuthResult(error: 'password terlalu lemah.');
        } else {
          return AuthResult(error: 'error: ${e.code}');
        }
      } else {
        if (e.toString() ==
            "Could not find any result for the supplied address or coordinates.") {
          return AuthResult(error: 'alamat/kota tidak sesuai.');
        }
        return AuthResult(error: 'error: $e');
      }
    }
  }

  Future<AuthResult> login(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      String userId = credential.user!.uid;
      CollectionReference consumersCollection =
          FirebaseFirestore.instance.collection("consumers");
      DocumentSnapshot snapshotConsumer =
          await consumersCollection.doc(userId).get();

      if (snapshotConsumer.exists) {
        notifyListeners();
        return AuthResult(user: credential.user, type: "consumer");
      } else {
        CollectionReference foodProviderCollection =
            FirebaseFirestore.instance.collection("providers");
        DocumentSnapshot snapshotFoodProvider =
            await foodProviderCollection.doc(userId).get();
        if (snapshotFoodProvider.exists) {
          notifyListeners();

          return AuthResult(user: credential.user, type: "provider");
        } else {
          CollectionReference adminCollection =
              FirebaseFirestore.instance.collection("admins");
          DocumentSnapshot snapshotAdmin =
              await adminCollection.doc(userId).get();
          if (snapshotAdmin.exists) {
            notifyListeners();

            return AuthResult(user: credential.user, type: "admin");
          }
          if (snapshotAdmin.exists) {
            return AuthResult(error: 'user tidak ditemukan');
          }
        }
      }

      return AuthResult(user: credential.user);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email' || e.code == 'invalid-credential') {
        return AuthResult(error: ' Email atau Password Salah');
      } else {
        return AuthResult(error: 'error: ${e.code}');
      }
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
