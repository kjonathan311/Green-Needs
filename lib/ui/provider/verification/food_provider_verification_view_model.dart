
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FoodProviderVerificationViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<String> get verificationStream async* {
    User? user = _auth.currentUser;
    if (user != null && user.email != null) {
      yield* _firestore
          .collection('providers')
          .doc(user.uid)
          .snapshots()
          .map((snapshot) {
        if (snapshot.exists) {
          Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
          return data['status'] as String;
        } else {
          return 'unverified';
        }
      });
    } else {
      yield 'unverified';
    }
  }
}