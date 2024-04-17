
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class InventoryNotificationPopUpWindowViewModel extends ChangeNotifier{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<int> getNotificationDuration() async {
    User? user = _auth.currentUser;
    if (user != null && user.email != null) {
      DocumentSnapshot snapshot =
      await _firestore.collection('consumers').doc(user.uid).get();
      if (snapshot.exists && snapshot.data() != null) {
        Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>;
        if (userData.containsKey('notificationDuration')) {
          return userData['notificationDuration'] as int;
        }
      }
    }
    return 14;
  }

  Future<void> addDuration(int duration) async {
    User? user = _auth.currentUser;
    if (user != null && user.email != null) {
      await _firestore.collection('consumers').doc(user.uid).set({
        'notificationDuration': duration,
      }, SetOptions(merge: true));
    }
  }

}