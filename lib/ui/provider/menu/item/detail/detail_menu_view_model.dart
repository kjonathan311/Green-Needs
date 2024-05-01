
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../utils.dart';

class DetailMenuViewModel extends ChangeNotifier{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;


  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> editMenuitem(BuildContext context,String uid,String name,String startPrice,String discountedPrice,String category,File? newImageFile,String description)async {
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

      try{
        String? photoUrl;
        if (newImageFile != null) {
          photoUrl = await uploadMenuImage(newImageFile,uid);
        }

        await _firestore.collection('providers').doc(user.uid).collection('menus').doc(uid).set({
          'name': name,
          'category':category,
          'description':description,
          'startPrice': int.parse(startPrice),
          'discountedPrice': int.parse(discountedPrice),
          if (photoUrl != null) 'photoUrl': photoUrl,
        }, SetOptions(merge: true));

        await _firestore.collection('providers').doc(user.uid).collection('products')
            .where('menuUid', isEqualTo: uid)
            .get()
            .then((QuerySnapshot querySnapshot) {
          querySnapshot.docs.forEach((doc) async {
            await doc.reference.update({
              'name': name,
              'category': category,
              'description': description,
              'startPrice': int.parse(startPrice),
              'discountedPrice': int.parse(discountedPrice),
              if (photoUrl != null) 'photoUrl': photoUrl,
            });
          });
        });

        final paketProductsSnapshot = await _firestore
            .collection('providers')
            .doc(user.uid)
            .collection('products')
            .where('type', isEqualTo: 'paket')
            .get();

        for (final productDoc in paketProductsSnapshot.docs) {
          await productDoc.reference.collection('items').where('menuUid', isEqualTo: uid).get().then((QuerySnapshot querySnapshot) {
            querySnapshot.docs.forEach((doc) async {
              await doc.reference.update({
                'name': name,
                'category': category,
                'description': description,
                'startPrice': int.parse(startPrice),
                'discountedPrice': int.parse(discountedPrice),
                if (photoUrl != null) 'photoUrl': photoUrl,
              });
            });
        });
        }

      }catch(e){
        _isLoading = false;
        notifyListeners();
      }


    }
    Navigator.pop(context);
    _isLoading = false;
    notifyListeners();

  }

  Future<void> deleteMenuItem(BuildContext context, String uid, String? photoUrl) async {
    User? user = _auth.currentUser;
    _isLoading = true;
    notifyListeners();

    if (user != null && user.email != null) {
      try {
        bool checkItemForDelete = true;

        // Check if the menu item is associated with any 'ala carte' product
        final alaCarteProductsSnapshot = await _firestore
            .collection('providers')
            .doc(user.uid)
            .collection('products')
            .where('type', isEqualTo: 'ala carte')
            .where('menuUid', isEqualTo: uid)
            .where('status', isEqualTo: 1)
            .get();

        if (alaCarteProductsSnapshot.docs.isNotEmpty) {
          checkItemForDelete = false;
        } else {
          // Check if the menu item is associated with any 'paket' product
          final paketProductsSnapshot = await _firestore
              .collection('providers')
              .doc(user.uid)
              .collection('products')
              .where('type', isEqualTo: 'paket')
              .where('status',isEqualTo: 1)
              .get();

          for (final productDoc in paketProductsSnapshot.docs) {
            final itemsSnapshot = await productDoc.reference.collection('items').where('menuUid', isEqualTo: uid).get();
            if (itemsSnapshot.docs.isNotEmpty) {
              checkItemForDelete = false;
              break;
            }
          }
        }

        if (checkItemForDelete) {
          // No associated product found, proceed with deletion
          await _firestore.collection('providers').doc(user.uid).collection('menus').doc(uid).delete();

          // Delete the associated photoUrl if exists
          if (photoUrl != null) {
            try {
              await storage.refFromURL(photoUrl).delete();
            } catch (e) {
              print('Error deleting image: $e');
            }
          }
          Navigator.pop(context);
        } else {
          showCustomSnackBar(context, "Menu tidak dapat didelete karena masih dijual.", color: Colors.red);
        }
      } catch (e) {
        print('Error deleting menu item: $e');
        showCustomSnackBar(context, "error pada saat delete item.", color: Colors.red);
      }
    }

    _isLoading = false;
    notifyListeners();
  }

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