import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:greenneeds/model/Profile.dart';
import 'package:greenneeds/ui/utils.dart';


class ConsumerProfileViewModel extends ChangeNotifier{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  ConsumerProfile? consumerProfile;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<ConsumerProfile?> fetchProfile() async {
    User? user = _auth.currentUser;
    if (user != null && user.email != null) {
      DocumentSnapshot snapshot =
      await _firestore.collection('consumers').doc(user.uid).get();
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

        consumerProfile= ConsumerProfile(
          uid: user.uid,
          name: data['name'],
          email: user.email!,
          phoneNumber: data['phoneNumber'],
          photoUrl: data['photoUrl'],
        );

        return consumerProfile;
      }
    }
    return null;
  }

  Future<void> updateProfile(BuildContext context,String name,String phoneNumber, File? newImageFile) async {
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


    User? user = _auth.currentUser;
    if (user != null) {
      try {
        String? photoUrl;
        if (newImageFile != null) {
          photoUrl = await uploadProfileImage(newImageFile);
        }

        await _firestore.collection('consumers').doc(user.uid).set({
          'name': name,
          'phoneNumber': phoneNumber,
          if (photoUrl != null) 'photoUrl': photoUrl,
        }, SetOptions(merge: true));

        QuerySnapshot postSnapshot = await _firestore.collection('posts').where('uidUser', isEqualTo: user.uid).get();

        WriteBatch batch = _firestore.batch();
        postSnapshot.docs.forEach((postDoc) {
          batch.update(postDoc.reference, {
            'name': name,
            if (photoUrl != null) 'photoUrl': photoUrl,
          });
        });
        await batch.commit();

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
    Navigator.pop(context);
  }

  void clearData(){
    consumerProfile=null;
  }
}