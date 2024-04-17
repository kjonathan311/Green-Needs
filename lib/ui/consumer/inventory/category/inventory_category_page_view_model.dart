

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class InventoryCategoryPageViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<String>> categoriesStream() async* {
    User? user = _auth.currentUser;
    if (user != null && user.email != null) {
      Stream<DocumentSnapshot> snapshotStream = _firestore.collection(
          'consumers').doc(user.uid).snapshots();
      await for (DocumentSnapshot snapshot in snapshotStream) {
        if (snapshot.exists) {
          Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
          if (data.containsKey('categories') && data['categories'] is List) {
            List<dynamic> categoriesData = data['categories'];
            List<String> categories = categoriesData.map((category) =>
                category.toString()).toList();
            yield categories;
          } else {
            yield [];
          }
        } else {
          yield [];
        }
      }
    }
  }

  Future<void> addToCategories(String category) async {
    User? user = _auth.currentUser;
    if (user != null && user.email != null) {
      DocumentReference documentRef = _firestore.collection('consumers').doc(
          user.uid);
      List<String> currentCategories = [];
      DocumentSnapshot snapshot = await documentRef.get();
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        if (data.containsKey('categories') && data['categories'] is List) {
          currentCategories = List<String>.from(data['categories']);
        }
      }
      if (!currentCategories.any((existingCategory) =>
      existingCategory.toLowerCase() == category.toLowerCase())) {
        currentCategories.add(category);

        await documentRef.set(
            {'categories': currentCategories}, SetOptions(merge: true));
      }
    }
  }

  Future<void> deleteCategory(String category) async {
    User? user = _auth.currentUser;
    if (user != null && user.email != null) {
      DocumentReference userDocRef = _firestore.collection('consumers').doc(user.uid);

      QuerySnapshot itemsSnapshot = await userDocRef.collection('inventory').where('category', isEqualTo: category).get();
      if (itemsSnapshot.docs.isNotEmpty) {
        WriteBatch batch = _firestore.batch();
        itemsSnapshot.docs.forEach((doc) {
          DocumentReference itemRef = userDocRef.collection('inventory').doc(doc.id);
          batch.update(itemRef, {'category': 'tidak dikategorikan'});
        });
        await batch.commit();
      }

      DocumentSnapshot userDocSnapshot = await userDocRef.get();
      if (userDocSnapshot.exists) {
        Map<String, dynamic> data = userDocSnapshot.data() as Map<String, dynamic>;
        if (data.containsKey('categories') && data['categories'] is List) {
          List<String> currentCategories = List<String>.from(data['categories']);

          currentCategories.remove(category);

          await userDocRef.set({'categories': currentCategories}, SetOptions(merge: true));
        }
      }
    }
  }

}