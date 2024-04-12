import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
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
                menuItem: MenuItem(
                  uid: doc.id,
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
                uid: itemDoc.id,
                name: itemData['name'],
                category: itemData['category'],
                description: itemData['description'],
                startPrice: itemData['startPrice'],
                discountedPrice: itemData['discountedPrice'],
                photoUrl: itemData['photoUrl'],
              );
              int quantity = itemData['quantity'];
              Product product = Product(menuItem: menuItem, quantity: quantity);
              products.add(product);
            });
            Paket paket = Paket(
                uid:doc.id,
                name:data['name'],
                price: data['price'],
                quantity: data['quantity'],
                products: products);
            packets.add(paket);
          }
        }
        print(packets);
        yield packets;
      }
    } else {
      yield [];
    }
  }


  Future<void> deleteItem(String uid) async{
    User? user = _auth.currentUser;
    if (user != null && user.email != null) {
      await _firestore.collection('providers').doc(user.uid).collection('products').doc(uid).set({
        'status': 0
      }, SetOptions(merge: true));
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
    if (user != null && user.email != null) {
      await _firestore.collection('providers').doc(user.uid).collection('products').doc(uid).set({
        'quantity':quantity+1
      }, SetOptions(merge: true));
    }
  }


}
