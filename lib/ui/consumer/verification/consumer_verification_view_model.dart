import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class ConsumerVerificationViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<bool> get verificationStream async* {
    User? user = _auth.currentUser;
    if (user != null && user.email != null) {
      yield* _firestore
          .collection('consumers')
          .doc(user.uid)
          .snapshots()
          .map((snapshot) {
        if (snapshot.exists) {
          Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
          return data['status'] ;
        } else {
          return false;
        }
      });
    } else {
      yield false;
    }
  }
}