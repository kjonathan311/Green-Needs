
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:greenneeds/model/Profile.dart';

import '../../../../../model/MenuItem.dart';

class StoreViewModel extends ChangeNotifier{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  FoodProviderProfile? foodProviderProfile;

  Future<List<Product>?> alaCarteItems(String uid) async{
    User? user = _auth.currentUser;
    if (user != null && user.email != null) {
      CollectionReference inventoryCollectionRef =
      _firestore.collection('providers').doc(uid).collection('products');
      await for (QuerySnapshot snapshot in inventoryCollectionRef.snapshots()) {
        List<Product> items = [];
        for (QueryDocumentSnapshot doc in snapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

          if(data['type']=="ala carte" && data['status']==1 && data['quantity']>0){
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
        return items;
      }
    } else {
      return [];
    }
  }

  Future<List<Paket>?> paketItems(String uid) async {
    User? user = _auth.currentUser;
    if (user != null && user.email != null) {
      CollectionReference inventoryCollectionRef = _firestore.collection('providers').doc(uid).collection('products');
      await for (QuerySnapshot snapshot in inventoryCollectionRef.snapshots()) {
        List<Paket> packets = [];
        for (QueryDocumentSnapshot doc in snapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          if (data['type'] == "paket" && data['status'] == 1 && data['quantity']>0) {
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
        return packets;
      }
    } else {
      return [];
    }
  }

  //fetch Food Provider Details
  Future<FoodProviderProfile?> foodProviderDetails(String uid) async {
    User? user = _auth.currentUser;
    if (user != null && user.email != null) {
      DocumentSnapshot snapshot =
      await _firestore.collection('providers').doc(uid).get();
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

        foodProviderProfile= FoodProviderProfile(
          uid: uid,
          name: data['name'],
          email: data['email'],
          phoneNumber: data['phoneNumber'],
          photoUrl: data['photoUrl'],
          city: data['city'],
          address: data['address'],
          rating: data['rating'],
          postalcode: data['postcode'],
          longitude: data['longitude'],
          latitude: data['latitude'],
          status: data['status'],
        );
        return foodProviderProfile;
      }
    }
    return null;
  }


}