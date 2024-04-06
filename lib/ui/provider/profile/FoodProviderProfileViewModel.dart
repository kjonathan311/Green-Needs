

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:greenneeds/model/Profile.dart';

import '../../utils.dart';

class FoodProviderProfileViewModel extends ChangeNotifier{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FoodProviderProfile? foodProviderProfile;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<FoodProviderProfile?> fetchProfile() async {
    User? user = _auth.currentUser;
    if (user != null && user.email != null) {
      DocumentSnapshot snapshot =
      await _firestore.collection('providers').doc(user.uid).get();
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

        foodProviderProfile= FoodProviderProfile(
          uid: user.uid,
          name: data['name'],
          email: user.email!,
          phoneNumber: data['phoneNumber'],
          photoUrl: data['photoUrl'],
          city: data['city'],
          address: data['address'],
          status: data['status'],
        );
        return foodProviderProfile;
      }
    }
    return null;
  }

  Future<void> updateProfile(BuildContext context,String name,
      String phoneNumber,String address,String city, File? newImageFile) async {
    User? user = _auth.currentUser;
    _isLoading = true;
    notifyListeners();

    if (name.isEmpty || phoneNumber.isEmpty) {
      showCustomSnackBar(context, "Semua field perlu diisi.", color: Colors.red);

      _isLoading = false;
      notifyListeners();
      return;
    }


    if (!RegExp(r'(^[\+]?[(]?[0-9]{3}[)]?[-\s\.]?[0-9]{3}[-\s\.]?[0-9]{4,6}$)').hasMatch(phoneNumber)) {
      showCustomSnackBar(context, "Format nomor telepon tidak valid.", color: Colors.red);

      _isLoading = false;
      notifyListeners();
      return;
    }
    double lat=0;
    double lng=0;

    try {
      //check city
      List<Location> checklocal = await locationFromAddress('$city');
      //check address
      List<Location> checkLoc = await locationFromAddress('$address');
      //get location of both
      List<Location> locations = await locationFromAddress('$address, $city');
      lat = locations[0].latitude;
      lng = locations[0].longitude;
    }catch(e){
      if(e.toString()=="Could not find any result for the supplied address or coordinates."){
        showCustomSnackBar(context, "alamat tidak sesuai.", color: Colors.red);
      }
      _isLoading = false;
      notifyListeners();
      return;
    }

    if (user != null) {
      try {
        String? photoUrl;
        if (newImageFile != null) {
          photoUrl = await uploadProfileImage(newImageFile);
        }

        await _firestore.collection('providers').doc(user.uid).set({
          'name': name,
          'phoneNumber': phoneNumber,
          'latitude':lat,
          'longitude':lng,
          'city':city,
          'address':address,
          if (photoUrl != null) 'photoUrl': photoUrl,
        }, SetOptions(merge: true));

      }catch(e){
        showCustomSnackBar(context, "${e}", color: Colors.red);
      }
    }
    _isLoading = false;
    notifyListeners();

    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Edit Profile Sukses"),
            content: Text("sukses edit profile."),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("OK"),
              ),
            ],
          );
        });

    clearData();
    Navigator.of(context).pushNamedAndRemoveUntil("/provider", (route) => false);
    Navigator.pushReplacementNamed(context, '/provider');
  }

  void clearData(){
    foodProviderProfile=null;
  }

}