
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:greenneeds/ui/utils.dart';

class AddInventoryItemPageViewModel extends ChangeNotifier{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> addInventoryItem(BuildContext context,String name,DateTime startDate,DateTime endDate,String category,int quantity)async{
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

      DocumentReference documentRef = _firestore.collection('consumers').doc(
          user.uid);

      try{
        Map<String, dynamic> inventoryData = {
          'name': name,
          'quantity':quantity,
          'category':category,
          'purchase_date': Timestamp.fromDate(startDate),
          'expiration_date': Timestamp.fromDate(endDate),
        };
        await documentRef.collection('inventory').add(inventoryData);
      }catch(e){
        _isLoading = false;
        notifyListeners();
      }

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