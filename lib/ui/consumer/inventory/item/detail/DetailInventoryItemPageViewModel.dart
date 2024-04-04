
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../utils.dart';

class DetailInventoryItemPageViewModel extends ChangeNotifier{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> editInventoryitem(BuildContext context,String uid,String name,DateTime startDate,DateTime endDate,String category,int quantity)async {
    User? user = _auth.currentUser;
    _isLoading = true;
    notifyListeners();
    if (user != null && user.email != null) {

      if (name.isEmpty || category.isEmpty) {
        showCustomSnackBar(context, "Semua field perlu diisi.", color: Colors.red);

        _isLoading = false;
        notifyListeners();
        return;
      }

      log(category);

      try{
        await _firestore.collection('consumers').doc(user.uid).collection('inventory').doc(uid).set({
          'name': name,
          'quantity':quantity,
          'category':category,
          'purchase_date': Timestamp.fromDate(startDate),
          'expiration_date': Timestamp.fromDate(endDate),
        }, SetOptions(merge: true));
      }catch(e){
        _isLoading = false;
        notifyListeners();
      }

      Navigator.pop(context);
    }
    _isLoading = false;
    notifyListeners();

  }

  Future<void> deleteInventoryitem(BuildContext context,String uid)async {
    User? user = _auth.currentUser;
    _isLoading = true;
    notifyListeners();
    if (user != null && user.email != null) {
      await _firestore.collection('consumers').doc(user.uid).collection('inventory').doc(uid).delete();
      Navigator.pop(context);
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<List<String>> getCategories() async {
    User? user = _auth.currentUser;
    List<String> result = [];
    result.add('tidak dikategorikan');
    if (user != null && user.email != null) {
      try {
        DocumentSnapshot snapshot = await _firestore
            .collection('consumers')
            .doc(user.uid)
            .get();
        if (snapshot.exists) {
          Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
          if (data.containsKey('categories') && data['categories'] is List) {
            List<dynamic> categoriesData = data['categories'];
            List<String> categories = categoriesData
                .map((category) => category.toString())
                .toList();
            result.addAll(categories);
          }
        }
      } catch (e) {
        print(e);
      }
    }
    return result;
  }
}