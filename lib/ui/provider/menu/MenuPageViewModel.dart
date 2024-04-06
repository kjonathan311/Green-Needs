
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:greenneeds/model/MenuItem.dart';

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
  Stream<List<MenuItem>> menuItems(String category) async* {
    User? user = _auth.currentUser;
    if (user != null && user.email != null) {
      CollectionReference inventoryCollectionRef = _firestore.collection('providers').doc(user.uid).collection('menus');
      await for (QuerySnapshot snapshot in inventoryCollectionRef.snapshots()) {
        List<MenuItem> items = [];
        for (QueryDocumentSnapshot doc in snapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          if (category == "Semua item" || data['category'] == category) {
            MenuItem item = MenuItem(
              uid: doc.id,
              name: data['name'],
              category: data['category'],
              description: data['description'],
              startPrice: data['startPrice'],
              discountedPrice: data['discountedPrice'],
              photoUrl: data['photoUrl']
            );
            items.add(item);
          }
        }
        yield items;
      }
    } else {
      yield [];
    }
  }

}