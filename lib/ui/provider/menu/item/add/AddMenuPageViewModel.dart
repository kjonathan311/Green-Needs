import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../utils.dart';

class AddMenuPageViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

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

  Future<void> addMenuItem(BuildContext context,String name,String category,String description,String startPrice,String discountedPrice, File? newImageFile)async{
    User? user = _auth.currentUser;
    _isLoading = true;
    notifyListeners();
    if (user != null && user.email != null) {
      if (name.isEmpty || category.isEmpty || description.isEmpty || startPrice.isEmpty || discountedPrice.isEmpty) {
        showCustomSnackBar(context, "Semua field perlu diisi.", color: Colors.red);

        _isLoading = false;
        notifyListeners();
        return;
      }

      int startPriceInteger=int.parse(startPrice);
      int discountedPriceInteger=int.parse(discountedPrice);

      if(discountedPriceInteger>=startPriceInteger){
        showCustomSnackBar(context, "harga diskon tidak boleh lebih tinggi dari pada harga awal.", color: Colors.red);

        _isLoading = false;
        notifyListeners();
        return;
      }

      DocumentReference documentRef = _firestore.collection('providers').doc(
          user.uid);


      try{
        Map<String, dynamic> menuData = {
          'name': name,
          'category':category,
          'description':description,
          'startPrice': int.parse(startPrice),
          'discountedPrice': int.parse(discountedPrice),
        };
        DocumentReference docRef =await documentRef.collection('menus').add(menuData);

        String? photoUrl;
        if (newImageFile != null) {
          photoUrl = await uploadMenuImage(newImageFile,docRef.id);

          await _firestore.collection('providers').doc(user.uid).collection('menus').doc(docRef.id).set({
            if (photoUrl != null) 'photoUrl': photoUrl,
          }, SetOptions(merge: true));
        }

      }catch(e){
        _isLoading = false;
        notifyListeners();
      }

      Navigator.pop(context);
    }
    _isLoading = false;
    notifyListeners();
  }
}
