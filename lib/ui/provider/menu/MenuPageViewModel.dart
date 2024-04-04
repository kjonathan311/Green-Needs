
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class MenuPageViewModel extends ChangeNotifier{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Stream<List<String>> categoriesStream() async* {
    User? user = _auth.currentUser;
    if (user != null && user.email != null) {
      final querySnapshot = await _firestore
          .collection('settings_food_waste_categories')
          .get();

      List<String> result = ["Semua item", 'tidak dikategorikan'];

      for (final doc in querySnapshot.docs) {
        String categoryName = doc.get('name');
        result.add(categoryName);
      }

      if (result.isEmpty) {
        yield ["Semua item", 'tidak dikategorikan'];
      } else {
        yield result;
      }
    } else {
      yield [];
    }
  }

}