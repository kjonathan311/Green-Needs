
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:greenneeds/model/InventoryItem.dart';

class InventoryViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _inventoryItemCount = 0;
  int get inventoryItemCount => _inventoryItemCount;

  final _itemCountController = StreamController<int>.broadcast();
  Stream<int> get itemCountStream => _itemCountController.stream;

  void updateItemCount(int count) {
    _inventoryItemCount = count;
    _itemCountController.add(_inventoryItemCount);
  }


  Stream<List<String>> categoriesStream() async* {
    User? user = _auth.currentUser;
    if (user != null && user.email != null) {
      yield* _firestore
          .collection('consumers')
          .doc(user.uid)
          .snapshots()
          .map((snapshot) {
        List<String> result = ["Semua item", 'tidak dikategorikan'];
        if (snapshot.exists) {
          if (snapshot.data()!.containsKey('categories')) {
            List<dynamic>? categoriesData = snapshot.get('categories');
            if (categoriesData != null && categoriesData is List) {
              List<String> categories = categoriesData.map((category) => category.toString()).toList();
              result.addAll(categories);
            }
          }
        }
        if (result.isEmpty) {
          return ["Semua item", 'tidak dikategorikan'];
        } else {
          return result;
        }
      });
    } else {
      yield [];
    }
  }

  Stream<List<InventoryItem>> inventoryItems(String category) async* {
    User? user = _auth.currentUser;
    if (user != null && user.email != null) {
      CollectionReference inventoryCollectionRef = _firestore.collection('consumers').doc(user.uid).collection('inventory');
      int count = 0;
      await for (QuerySnapshot snapshot in inventoryCollectionRef.snapshots()) {
        List<InventoryItem> items = [];
        for (QueryDocumentSnapshot doc in snapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          if (category == "Semua item" || data['category'] == category) {
            InventoryItem item = InventoryItem(
              uid: doc.id,
              name: data['name'],
              category: data['category'],
              quantity: data['quantity'],
              purchaseDate: (data['purchase_date'] as Timestamp).toDate(),
              expirationDate: (data['expiration_date'] as Timestamp).toDate(),
            );
            items.add(item);
          }
        }
        updateItemCount(items.length);
        yield items;
      }
    } else {
      updateItemCount(0);
      yield [];
    }
  }

  Future<void> decreaseQuantity(String uid,int quantity) async{
    User? user = _auth.currentUser;
    if (user != null && user.email != null) {
      await _firestore.collection('consumers').doc(user.uid).collection('inventory').doc(uid).set({
        'quantity':quantity-1
      }, SetOptions(merge: true));
    }
  }
  Future<void> increaseQuantity(String uid,int quantity) async{
    User? user = _auth.currentUser;
    if (user != null && user.email != null) {
      await _firestore.collection('consumers').doc(user.uid).collection('inventory').doc(uid).set({
        'quantity':quantity+1
      }, SetOptions(merge: true));
    }
  }


}

