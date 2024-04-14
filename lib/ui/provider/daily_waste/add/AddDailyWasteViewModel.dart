import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:greenneeds/ui/utils.dart';
import '../../../../model/MenuItem.dart';

class AddDailyWastePageViewModel extends ChangeNotifier{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Stream<List<MenuItem>> menuItems() async* {
    User? user = _auth.currentUser;
    if (user != null && user.email != null) {
      CollectionReference inventoryCollectionRef =
      _firestore.collection('providers').doc(user.uid).collection('menus');
      await for (QuerySnapshot snapshot in inventoryCollectionRef.snapshots()) {
        List<MenuItem> items = [];
        for (QueryDocumentSnapshot doc in snapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

          MenuItem item = MenuItem(
              uid: doc.id,
              name: data['name'],
              category: data['category'],
              description: data['description'],
              startPrice: data['startPrice'],
              discountedPrice: data['discountedPrice'],
              photoUrl: data['photoUrl']);
          items.add(item);
        }

        yield items;
      }
    } else {
      yield [];
    }
  }


  Future<void> addAlaCarteProduct(BuildContext context,List<Product> products)async{
    User? user = _auth.currentUser;
    _isLoading = true;
    notifyListeners();
    if (user != null && user.email != null) {

      if(products.isEmpty){
        showCustomSnackBar(context, "Salah satu item perlu dicentang.", color: Colors.red);
        _isLoading = false;
        notifyListeners();
        return;
      }

      DocumentReference documentRef = _firestore.collection('providers').doc(
          user.uid);


      try{
        products.forEach((element) async{
          Map<String, dynamic> productData = {
            'menuUid':element.uid,
            'name': element.menuItem.name,
            'type':"ala carte",
            'category':element.menuItem.category,
            'description':element.menuItem.description,
            'startPrice': element.menuItem.startPrice,
            'discountedPrice':element.menuItem.discountedPrice,
            'status':1,
            if (element.menuItem.photoUrl != null) 'photoUrl': element.menuItem.photoUrl,
            'quantity':element.quantity
          };
          DocumentReference docRef =await documentRef.collection('products').add(productData);
        });

      }catch(e){
        print(e);
        _isLoading = false;
        notifyListeners();
        return;
      }

      Navigator.pop(context);
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addPaketProduct(BuildContext context,String name,int quantity,int startPrice,String discountedPrice,List<Product> products)async{
    User? user = _auth.currentUser;
    _isLoading = true;
    notifyListeners();

    if (user != null && user.email != null) {

      if(products.isEmpty){
        showCustomSnackBar(context, "Salah satu item perlu dicentang.", color: Colors.red);
        _isLoading = false;
        notifyListeners();
        return;
      }
      if(name.isEmpty || discountedPrice.isEmpty){
        showCustomSnackBar(context, "Semua field harus diisi.", color: Colors.red);
        _isLoading = false;
        notifyListeners();
        return;
      }

      bool hasZeroQuantity = false;
      products.forEach((element) async {
        if (element.quantity <= 0) {
          showCustomSnackBar(
              context, "item pada paket harus memiliki jumlah lebih dari satu.",
              color: Colors.red);
          _isLoading = false;
          notifyListeners();
          hasZeroQuantity=true;
          return;
        }
      });
      if (hasZeroQuantity) {
        return;
      }

      try{
        DocumentReference documentRef = _firestore.collection('providers').doc(
            user.uid);

        Map<String, dynamic> paketData = {
          'name':name,
          'type':"paket",
          'startPrice':startPrice,
          'discountedPrice':int.parse(discountedPrice),
          'status': 1,
          'quantity':quantity
        };
        DocumentReference paketRef =await documentRef.collection('products').add(paketData);

        products.forEach((element) async{
          Map<String, dynamic> productData = {
            'menuUid':element.uid,
            'name': element.menuItem.name,
            'category':element.menuItem.category,
            'description':element.menuItem.description,
            'startPrice': element.menuItem.startPrice,
            'discountedPrice':element.menuItem.discountedPrice,
            if (element.menuItem.photoUrl != null) 'photoUrl': element.menuItem.photoUrl,
            'quantity':element.quantity
          };
          DocumentReference productRef =await paketRef.collection('items').add(productData);
        });

      }catch(e){
        print(e);
        _isLoading = false;
        notifyListeners();
        return;
      }

      Navigator.pop(context);
    }

    _isLoading = false;
    notifyListeners();
  }
}