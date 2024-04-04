import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../model/Profile.dart';
import '../../utils.dart';

class AdminVerificationViewModel extends ChangeNotifier{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<FoodProviderProfile>> unverifiedFoodProvidersStream(String status) async* {
    User? user = _auth.currentUser;
    if (user != null && user.email != null) {
      yield* _firestore
          .collection('providers')
          .where('status', isEqualTo: status)
          .snapshots()
          .map((snapshot) {
        List<FoodProviderProfile> unverifiedProviders = [];
        snapshot.docs.forEach((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          FoodProviderProfile profile = FoodProviderProfile(
            uid: doc.id,
            name: data['name'],
            email: data['email'],
            phoneNumber: data['phoneNumber'],
            address: data['address'],
            city: data['city'],
            status: data['status'],
            photoUrl: data['photoUrl'],
          );
          unverifiedProviders.add(profile);
        });
        return unverifiedProviders;
      });
    } else {
      yield [];
    }
  }

  Future<void> verifyFoodProvider(BuildContext context,String uid) async {
    try {
      await _firestore.collection('providers').doc(uid).update({
        'status': 'verified',
      });
    } catch (error) {
      showCustomSnackBar(context, "gagal verifikasi user.", color: Colors.red);
    }
  }

  Future<void> denyFoodProvider(BuildContext context,String uid) async {
    try {
      await _firestore.collection('providers').doc(uid).update({
        'status': 'denied',
      });
    } catch (error) {
      showCustomSnackBar(context, "gagal menolak user.", color: Colors.red);
    }
  }


}