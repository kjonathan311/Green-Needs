
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:greenneeds/model/Category.dart';

class MainSearchViewModel extends ChangeNotifier{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<CategoryItem>> categoryItems() async* {
    User? user = _auth.currentUser;
    if (user != null && user.email != null) {
      final querySnapshot = await _firestore
          .collection('settings_food_waste_categories');
      await for (QuerySnapshot snapshot in querySnapshot.snapshots()) {
        List<CategoryItem> items = [];
        for (QueryDocumentSnapshot doc in snapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            CategoryItem item = CategoryItem(
                uid: doc.id,
                name: data['name'],
                photoUrl: data['photoUrl']
            );
            items.add(item);
        }
        yield items;
      }
    } else {
      yield [];
    }
  }


}