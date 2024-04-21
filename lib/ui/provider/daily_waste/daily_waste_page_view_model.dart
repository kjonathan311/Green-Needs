import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:greenneeds/model/MenuItem.dart';

class DailyWastePageViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Stream<List<Product>> alaCarteItems() async* {
    User? user = _auth.currentUser;
    if (user != null && user.email != null) {
      CollectionReference inventoryCollectionRef =
      _firestore.collection('providers').doc(user.uid).collection('products');
      await for (QuerySnapshot snapshot in inventoryCollectionRef.snapshots()) {
        List<Product> items = [];
        for (QueryDocumentSnapshot doc in snapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

          if(data['type']=="ala carte" && data['status']==1){
            Product item = Product(
              uid: doc.id,
                menuItem: MenuItem(
                  uid: data['menuUid'],
                  name: data['name'],
                  category: data['category'],
                  startPrice: data['startPrice'],
                  discountedPrice: data['discountedPrice'],
                  description: data['description'],
                  photoUrl: data['photoUrl'],
                ),quantity: data['quantity']);
            items.add(item);
          }
        }
        yield items;
      }
    } else {
      yield [];
    }
  }

  Stream<List<Paket>> PaketItems() async* {
    User? user = _auth.currentUser;
    if (user != null && user.email != null) {
      CollectionReference inventoryCollectionRef = _firestore.collection('providers').doc(user.uid).collection('products');
      await for (QuerySnapshot snapshot in inventoryCollectionRef.snapshots()) {
        List<Paket> packets = [];
        for (QueryDocumentSnapshot doc in snapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          print(data['type']=="paket");
          if (data['type'] == "paket" && data['status'] == 1) {
            QuerySnapshot itemsSnapshot = await doc.reference.collection('items').get();
            List<Product> products = [];
            itemsSnapshot.docs.forEach((itemDoc) {
              Map<String, dynamic> itemData = itemDoc.data() as Map<String, dynamic>;
              MenuItem menuItem = MenuItem(
                uid: itemData['menuUid'],
                name: itemData['name'],
                category: itemData['category'],
                description: itemData['description'],
                startPrice: itemData['startPrice'],
                discountedPrice: itemData['discountedPrice'],
                photoUrl: itemData['photoUrl'],
              );
              int quantity = itemData['quantity'];
              Product product = Product(uid:itemDoc.id,menuItem: menuItem, quantity: quantity);
              products.add(product);
            });
            Paket paket = Paket(
                uid:doc.id,
                name:data['name'],
                startPrice: data['startPrice'],
                discountedPrice: data['discountedPrice'],
                quantity: data['quantity'],
                products: products);
            packets.add(paket);
          }
        }
        yield packets;
      }
    } else {
      yield [];
    }
  }


  Future<void> deleteItem(BuildContext context, String uid) async {
    User? user = _auth.currentUser;
    if (user != null && user.email != null) {
      bool deleteConfirmed = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Delete'),
            content: Text('Apakah ingin delete item ini?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false); // Return false (cancel)
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true); // Return true (confirm)
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );

      if (deleteConfirmed == true) {
        await _firestore
            .collection('providers')
            .doc(user.uid)
            .collection('products')
            .doc(uid)
            .set({'status': 0}, SetOptions(merge: true));
      }
    }
  }

  Future<void> decreaseQuantity(String uid,int quantity) async{
    User? user = _auth.currentUser;
    if (user != null && user.email != null) {
      await _firestore.collection('providers').doc(user.uid).collection('products').doc(uid).set({
        'quantity':quantity-1
      }, SetOptions(merge: true));
    }
  }
  Future<void> increaseQuantity(String uid,int quantity) async{
    User? user = _auth.currentUser;
    print(uid);
    print(quantity);
    if (user != null && user.email != null) {
      await _firestore.collection('providers').doc(user.uid).collection('products').doc(uid).set({
        'quantity':quantity+1
      }, SetOptions(merge: true));
    }
  }


}
