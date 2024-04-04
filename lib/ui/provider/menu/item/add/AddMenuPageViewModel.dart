import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class AddMenuPageViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<String>> getCategories() async {
    User? user = _auth.currentUser;
    if (user != null && user.email != null) {
      final querySnapshot =
          await _firestore.collection('settings_food_waste_categories').get();

      List<String> result = ['tidak dikategorikan'];

      for (final doc in querySnapshot.docs) {
        String categoryName = doc.get('name');
        result.add(categoryName);
      }

      if (result.isEmpty) {
        return ['tidak dikategorikan'];
      } else {
        return result;
      }
    } else {
      return [];
    }
  }
}
