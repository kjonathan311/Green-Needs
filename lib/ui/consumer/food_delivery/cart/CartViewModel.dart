
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:greenneeds/ui/utils.dart';
import '../../../../model/MenuItem.dart';
import '../../../../model/Profile.dart';

class CartViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Product> alaCarteCart=[];
  List<Paket> paketCart=[];
  FoodProviderProfile? currentFoodProvider;
  int totalPrice=0;
  double totalPayment=0;
  double currentDistance=0.0;
  double taxAmount=0.0;
  double costAmount=0.0;
  StreamSubscription<QuerySnapshot>? _subscription;


  String _selectedOrderType = 'kurir';
  String get selectedOrderType => _selectedOrderType;


  void setSelectedOrderType(String orderType) {
    _selectedOrderType = orderType;
    notifyListeners();
  }


  void addAlaCarteItemToCart(BuildContext context, FoodProviderProfile foodProvider,double distance, Product item) async {
    if (currentFoodProvider == null) {
      currentFoodProvider = foodProvider;
      currentDistance=distance;
      Product newItem=Product(uid:item.uid,menuItem: item.menuItem,quantity: 1);
      alaCarteCart.add(newItem);
      notifyListeners();
    } else if (currentFoodProvider?.uid != foodProvider.uid) {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Order di Toko Lain?'),
            content: Text('Cart akan dibersihkan dari toko sebelumnya.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  clearAll();
                  currentFoodProvider = foodProvider;
                  Navigator.of(context).pop();

                  Product newItem=Product(uid:item.uid,menuItem: item.menuItem,quantity: 1);
                  alaCarteCart.add(newItem);
                  notifyListeners();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      Product newItem=Product(uid:item.uid,menuItem: item.menuItem,quantity: 1);
      alaCarteCart.add(newItem);
      notifyListeners();
    }
  }



  void addPaketToCart(BuildContext context, FoodProviderProfile foodProvider,double distance, Paket item) async {
    if (currentFoodProvider == null) {
      currentFoodProvider = foodProvider;
      currentDistance=distance;
      Paket newPaket=Paket(uid: item.uid, products: item.products,
          name: item.name, startPrice: item.startPrice, discountedPrice: item.discountedPrice,quantity: 1);
      paketCart.add(newPaket);
      notifyListeners();
    } else if (currentFoodProvider?.uid != foodProvider.uid) {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Order di Toko Lain?'),
            content: Text('Cart akan dibersihkan dari toko sebelumnya.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  clearAll();
                  currentFoodProvider = foodProvider;
                  Navigator.of(context).pop();

                  Paket newPaket=Paket(uid: item.uid, products: item.products,
                      name: item.name, startPrice: item.startPrice, discountedPrice: item.discountedPrice,quantity: 1);
                  paketCart.add(newPaket);
                  notifyListeners();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      Paket newPaket=Paket(uid: item.uid, products: item.products,
          name: item.name, startPrice: item.startPrice, discountedPrice: item.discountedPrice,quantity: 1);
      paketCart.add(newPaket);
      notifyListeners();
    }
  }

  int getAllItemsLength(){
    return alaCarteCart.length+paketCart.length;
  }

  void decreaseQuantityAlaCarte(int quantity,Product item){
    if(quantity-1 <= 0){
      int index = alaCarteCart.indexWhere((cartItem) => cartItem.uid == item.uid);
      alaCarteCart.removeAt(index);
      checkCartIsEmpty();
    }else{
      int index = alaCarteCart.indexWhere((cartItem) => cartItem.uid == item.uid);
      alaCarteCart[index].quantity-=1;
    }
    getTotalCost();
    notifyListeners();
  }

  void decreaseQuantityPaket(int quantity,Paket item){
    if(quantity-1 <= 0){
      int index = paketCart.indexWhere((paket) => paket.uid == item.uid);
      paketCart.removeAt(index);
      checkCartIsEmpty();
    }else{
      int index = paketCart.indexWhere((paket) => paket.uid == item.uid);
      paketCart[index].quantity-=1;
    }
    getTotalCost();
    notifyListeners();
  }

  void checkCartIsEmpty(){
    if(paketCart.isEmpty && alaCarteCart.isEmpty){
      currentFoodProvider=null;
    }
  }

  Future<void> increaseQuantityPaket(BuildContext context,int quantity,Paket item)async{
    User? user = _auth.currentUser;
    if (user != null && user.email != null) {
      final snapshot = await _firestore
          .collection('providers').doc(currentFoodProvider?.uid).get();
      if(snapshot.exists){
        final itemSnapshot=await snapshot.reference.collection('products').doc(item.uid).get();
        if(itemSnapshot.exists){
          int itemQuantity = itemSnapshot.data()?['quantity'];
          if (quantity + 1 > itemQuantity) {
            showCustomSnackBar(context, "item tidak tersedia", color: Colors.red);
          } else {
            int index = paketCart.indexWhere((paket) => paket.uid == item.uid);
            paketCart[index].quantity+=1;
          }
        }
      }
    }
    getTotalCost();
    notifyListeners();
  }

  Future<void> increaseQuantityAlaCarte(BuildContext context,int quantity,Product item)async{
    User? user = _auth.currentUser;
    if (user != null && user.email != null) {
      final snapshot = await _firestore
          .collection('providers').doc(currentFoodProvider?.uid).get();
        if(snapshot.exists){
        final itemSnapshot=await snapshot.reference.collection('products').doc(item.uid).get();
          if(itemSnapshot.exists){
            int itemQuantity = itemSnapshot.data()?['quantity'];
            if (quantity + 1 > itemQuantity) {
              showCustomSnackBar(context, "item tidak tersedia", color: Colors.red);
            } else {
              int index = alaCarteCart.indexWhere((cartItem) => cartItem.uid == item.uid);
              alaCarteCart[index].quantity+=1;
            }
          }
        }
    }
    getTotalCost();
    notifyListeners();
  }

  bool checkItemInCart(String uid) {
    if (alaCarteCart != []) {
      for (var product in alaCarteCart!) {
        if (product.uid == uid) {
          return true;
        }
      }
    }
    if (paketCart != []) {
      for (var paket in paketCart!) {
        if(paket.uid==uid){
          return true;
        }
      }
    }
    return false;
  }

  void clearAll(){
    alaCarteCart.clear();
    paketCart.clear();
    checkCartIsEmpty();
    totalPrice=0;
    currentDistance=0.0;
    notifyListeners();
  }


  void getTotalCost(){
    int total=0;
    alaCarteCart.forEach((element) {
      total+=element.menuItem.discountedPrice*element.quantity;
    });
    paketCart.forEach((element) {
      total+=element.discountedPrice*element.quantity;
    });
    totalPrice=total;
    totalPayment=totalPrice.toDouble();
    totalPayment+=taxAmount;
    if (_selectedOrderType == 'kurir') {
      totalPayment += costAmount;
    }
  }

  Future<void> getTax() async {
    final snapshot = await _firestore.collection('main_settings').doc("1").get();
    if (snapshot.exists) {
      double tax = snapshot.data()?['tax'];
      taxAmount = tax * totalPrice;
      getTotalCost();
      notifyListeners();
    }
  }

  Future<void> getCostPerKm() async {
    final snapshot = await _firestore.collection('main_settings').doc("1").get();
    if (snapshot.exists) {
      int costPerKm = snapshot.data()?['costPerKm'];
      costAmount = costPerKm * currentDistance;
      getTotalCost();
      notifyListeners();
    }
  }

  void checkCartItemAvailability() {
    if (currentFoodProvider != null) {
      _subscription = FirebaseFirestore.instance.collection('providers').doc(
          currentFoodProvider?.uid).collection('products').snapshots().listen((
          snapshot) {

        for (var item in alaCarteCart) {
          final itemDoc = snapshot.docs.firstWhere((doc) => doc.id == item.uid);
          if (itemDoc != null) {
            int status = itemDoc['status'];
            int availability = itemDoc['quantity'];
            if (status == 0 || availability <= 0) {
              // Update the status of the item in the cart to false
              item.status = false;
              // Remove the item from the cart
            } else if (item.quantity > availability) {
              // Update the quantity of the item in the cart to match availability
              item.quantity = availability;
            }else if(status==1){
              item.status=true;
            }
          }
        }

        for (var paket in paketCart) {
          for (var item in paket.products) {
            final itemDoc = snapshot.docs.firstWhere((doc) => doc.id == item.uid);
            if (itemDoc != null) {
              int status = itemDoc['status'];
              int availability = itemDoc['quantity'];
              if (status == 0 || availability <= 0) {
                // Update the status of the item in the cart to false
                item.status = false;
                // Remove the item from the cart
              } else if (item.quantity > availability) {
                // Update the quantity of the item in the cart to match availability
                item.quantity = availability;
              }
              if(status == 1){
                item.status=true;
              }
            }
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}