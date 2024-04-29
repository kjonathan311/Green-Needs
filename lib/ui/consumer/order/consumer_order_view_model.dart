import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:greenneeds/model/OrderItem.dart';
import 'package:greenneeds/ui/utils.dart';
import '../../../model/Address.dart';
import '../../../model/MenuItem.dart';
import '../../../model/Profile.dart';
import '../../../model/Rating.dart';

class ConsumerOrderViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Stream<List<OrderItemWithProviderAndConsumer>> ordersStream(int tab) {
    User? user = _auth.currentUser;
    if (user != null && user.email != null) {
      CollectionReference transactionCollectionRef =
      _firestore.collection('transactions');

      return transactionCollectionRef.snapshots().asyncMap((snapshot) async {
        List<OrderItemWithProviderAndConsumer> orders = [];

        for (DocumentSnapshot doc in snapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          String consumerId = data['consumerId'];
          if (consumerId == user.uid) {
            if (tab == 1) {
              if (data['status'] != "order selesai" && data['status'] != "order dibatalkan") {
                DocumentSnapshot providerDoc = await _firestore
                    .collection('providers')
                    .doc(data['providerId'])
                    .get();

                Map<String, dynamic> providerData =
                providerDoc.data() as Map<String, dynamic>;

                FoodProviderProfile provider = FoodProviderProfile(
                  uid: providerDoc.id,
                  name: providerData['name'],
                  email: providerData['email'],
                  phoneNumber: providerData['phoneNumber'],
                  address: providerData['address'],
                  city: providerData['city'],
                  status: providerData['status'],
                  postalcode: providerData['postalcode'],
                  rating: providerData['rating'],
                  photoUrl: providerData['photoUrl'],
                  longitude: providerData['longitude'],
                  latitude: providerData['latitude'],
                );

                DocumentSnapshot consumerDoc = await _firestore
                    .collection('consumers')
                    .doc(data['consumerId'])
                    .get();

                Map<String, dynamic> consumerData =
                consumerDoc.data() as Map<String, dynamic>;

                ConsumerProfile consumer= ConsumerProfile(
                  uid: user.uid,
                  name: consumerData['name'],
                  email: consumerData['email'],
                  phoneNumber: consumerData['phoneNumber'],
                  photoUrl: consumerData['photoUrl'],
                );

                OrderItem order = OrderItem(
                  uid: doc.id,
                  addressDestinationId: data['addressDestinationId'],
                  consumerId: data['consumerId'],
                  providerId: data['providerId'],
                  date: (data['date'] as Timestamp).toDate(),
                  totalPrice: data['totalPrice'],
                  adminFee: data['adminFee'],
                  shippingFee: data['shippingFee'],
                  status: data['status'],
                  type: data['type'],
                  consumerNote: data['consumerNote'],
                );

                int itemCount = (await _firestore
                    .collection('transactions')
                    .doc(doc.id)
                    .collection('items')
                    .get())
                    .size;

                orders
                    .add(
                    OrderItemWithProviderAndConsumer(order: order, provider: provider,consumer: consumer,itemCount:itemCount));
              }
            } else {
              if (data['status'] == "order selesai" ||
                  data['status'] == "order dibatalkan") {
                DocumentSnapshot providerDoc = await _firestore
                    .collection('providers')
                    .doc(data['providerId'])
                    .get();

                Map<String, dynamic> providerData =
                providerDoc.data() as Map<String, dynamic>;

                FoodProviderProfile provider = FoodProviderProfile(
                  uid: providerDoc.id,
                  name: providerData['name'],
                  email: providerData['email'],
                  phoneNumber: providerData['phoneNumber'],
                  address: providerData['address'],
                  city: providerData['city'],
                  status: providerData['status'],
                  postalcode: providerData['postalcode'],
                  rating: providerData['rating'],
                  photoUrl: providerData['photoUrl'],
                  longitude: providerData['longitude'],
                  latitude: providerData['latitude'],
                );

                DocumentSnapshot consumerDoc = await _firestore
                    .collection('consumers')
                    .doc(data['consumerId'])
                    .get();

                Map<String, dynamic> consumerData =
                consumerDoc.data() as Map<String, dynamic>;

                ConsumerProfile consumer= ConsumerProfile(
                  uid: consumerDoc.id,
                  name: consumerData['name'],
                  email: consumerData['email'],
                  phoneNumber: consumerData['phoneNumber'],
                  photoUrl: consumerData['photoUrl'],
                );

                OrderItem order = OrderItem(
                  uid: doc.id,
                  addressDestinationId: data['addressDestinationId'],
                  consumerId: data['consumerId'],
                  providerId: data['providerId'],
                  date: (data['date'] as Timestamp).toDate(),
                  totalPrice: data['totalPrice'],
                  adminFee: data['adminFee'],
                  shippingFee: data['shippingFee'],
                  status: data['status'],
                  type: data['type'],
                  consumerNote: data['consumerNote'],
                  rating:data['rating'],
                  reportPhoto: data['reportPhoto'],
                  reportReason: data['reportReason']
                );

                int itemCount = (await _firestore
                    .collection('transactions')
                    .doc(doc.id)
                    .collection('items')
                    .get())
                    .size;

                orders
                    .add(
                    OrderItemWithProviderAndConsumer(order: order, provider: provider,consumer: consumer,itemCount:itemCount));
              }
            }
          }
        }
        orders.sort((a, b) => b.order.date.compareTo(a.order.date));
        return orders;
      });
    } else {
      return Stream.value([]);
    }
  }


  Stream<String?> getStatus(String transactionId) {
    return _firestore.collection('transactions').doc(transactionId).snapshots().map((snapshot) {
      if (snapshot.exists) {
        String? status = snapshot.data()?['status'];
        return status;
      } else {
        return null;
      }
    });
  }

  Future<Address?> getAddress(String addressDestinationId) async {
    User? user = _auth.currentUser;
    if (user != null && user.uid.isNotEmpty) {
      try {
        DocumentSnapshot addressSnapshot = await _firestore
            .collection('consumers')
            .doc(user.uid)
            .collection('addresses')
            .doc(addressDestinationId)
            .get();

        if (addressSnapshot.exists) {
          Map<String, dynamic> addressData =
          addressSnapshot.data() as Map<String, dynamic>;
          return Address(
            uid: addressSnapshot.id,
            address: addressData['address'],
            longitude: addressData['longitude'],
            latitude: addressData['latitude'],
            postalcode: addressData['postalcode'],
            city: addressData['city'],
          );
        } else {
          return null;
        }
      } catch (e) {
        print('Error fetching address: $e');
        return null;
      }
    } else {
      return null;
    }
  }

  Future<List<Paket>?> getPaketItems(String providerId, String transactionId) async {
    User? user = _auth.currentUser;
    if (user != null && user.email != null) {
      DocumentSnapshot transactionSnapshot = await _firestore.collection('transactions').doc(transactionId).get();

      if (transactionSnapshot.exists) {
        CollectionReference itemsCollectionRef = _firestore.collection('transactions').doc(transactionId).collection('items');

        List<Paket> paketItems = [];

        QuerySnapshot itemsQuerySnapshot = await itemsCollectionRef.get();

        for (QueryDocumentSnapshot transactionItemDoc in itemsQuerySnapshot.docs) {
          String productUid = transactionItemDoc['productUid'];

          CollectionReference inventoryCollectionRef = _firestore.collection('providers').doc(providerId).collection('products');
          QuerySnapshot snapshot = await inventoryCollectionRef.snapshots().first;

          for (QueryDocumentSnapshot doc in snapshot.docs) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

            if (data['type'] == "paket" && doc.id == productUid) {
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

                Product product = Product(
                  uid: itemDoc.id,
                  menuItem: menuItem,
                  quantity: quantity,
                );

                products.add(product);
              });

              Paket paket = Paket(
                uid: doc.id,
                name: data['name'],
                startPrice: data['startPrice'],
                discountedPrice: data['discountedPrice'],
                quantity: transactionItemDoc['quantity'],
                products: products,
              );

              paketItems.add(paket);
            }
          }
        }

        return paketItems.isNotEmpty ? paketItems : null;
      }
    }
    return null;
  }

  Future<List<Product>?> getAlaCarteItems(String providerId, String transactionId) async {
    User? user = _auth.currentUser;
    if (user != null && user.email != null) {
      DocumentSnapshot transactionSnapshot = await _firestore.collection('transactions').doc(transactionId).get();

      if (transactionSnapshot.exists) {
        CollectionReference itemsCollectionRef = _firestore.collection('transactions').doc(transactionId).collection('items');

        List<Product> alaCarteItems = [];

        QuerySnapshot itemsQuerySnapshot = await itemsCollectionRef.get();

        for (QueryDocumentSnapshot transactionItemDoc in itemsQuerySnapshot.docs) {
          String productUid = transactionItemDoc['productUid'];

          CollectionReference inventoryCollectionRef = _firestore.collection('providers').doc(providerId).collection('products');
          QuerySnapshot snapshot = await inventoryCollectionRef.where('type', isEqualTo: 'ala carte').get();

          for (QueryDocumentSnapshot doc in snapshot.docs) {
            if (doc.id == productUid) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              MenuItem menuItem = MenuItem(
                uid: data['menuUid'],
                name: data['name'],
                category: data['category'],
                description: data['description'],
                startPrice: data['startPrice'],
                discountedPrice: data['discountedPrice'],
                photoUrl: data['photoUrl'],
              );

              int quantity = transactionItemDoc['quantity'];

              Product product = Product(
                uid: doc.id,
                menuItem: menuItem,
                quantity: quantity,
              );

              alaCarteItems.add(product);
            }
          }
        }

        print(alaCarteItems.length);
        return alaCarteItems.isNotEmpty ? alaCarteItems : null;
      }
    }
    return null;
  }
  Future<void> changeStatusOrder(OrderItemWithProviderAndConsumer transaction,String status)async {
    await _firestore.collection('transactions')
        .doc(transaction.order.uid)
        .set({
      'status': status
    }, SetOptions(merge: true));
  }

  Future<Rating?> getRating(OrderItemWithProviderAndConsumer transaction) async {
    try {
      DocumentSnapshot snapshot = await _firestore
          .collection('transactions')
          .doc(transaction.order.uid)
          .get();
      if (snapshot.exists) {
        Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
        if (data != null) {
          int? ratingValue = data['rating'];
          String? comment = data['comment'];

          if (ratingValue == null) {
            return null;
          } else {
            return Rating(
              rating: ratingValue,
              comment: comment ?? '',
            );
          }
        } else {
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      print('Error getting rating: $e');
      return null;
    }
  }


  Future<void>addRating(OrderItemWithProviderAndConsumer transaction,int rating,String comment)async{
    await _firestore.collection('transactions')
        .doc(transaction.order.uid)
        .set({
      'rating': rating,
      if(comment!=null)'comment':comment
    }, SetOptions(merge: true));

    QuerySnapshot ordersSnapshot = await _firestore
        .collection('transactions')
        .where('providerId', isEqualTo: transaction.order.providerId)
        .get();

    int totalRating = 0;
    int orderCount = 0;
    for (QueryDocumentSnapshot orderDoc in ordersSnapshot.docs) {
      Map<String, dynamic>? data = orderDoc.data() as Map<String, dynamic>?;
      if (data != null && data.containsKey('rating')) {
        int? rating = data['rating'];
        if (rating != null) {
          totalRating += rating;
          orderCount++;
        }
      }
    }
    double averageRating = orderCount > 0 ? totalRating / orderCount : 0;
    await _firestore.collection('providers').doc(transaction.order.providerId).set({
      'rating': averageRating,
    }, SetOptions(merge: true));
  }

  Future<void>cancelOrder(OrderItemWithProviderAndConsumer transaction)async{
    final providerBalanceSnapshot = await _firestore.collection('consumers')
        .doc(transaction.consumer.uid)
        .get();

    int bal = providerBalanceSnapshot.data()?['balance'] ?? 0;

    await _firestore.collection('consumers')
        .doc(transaction.consumer.uid)
        .set({
      'balance': bal + transaction.order.totalPayment
    }, SetOptions(merge: true));


    //bring back quantity items
    DocumentSnapshot transactionSnapshot = await _firestore.collection(
        'transactions').doc(transaction.order.uid).get();

    if (transactionSnapshot.exists) {
      CollectionReference itemsCollectionRef = _firestore.collection(
          'transactions').doc(transaction.order.uid).collection('items');

      QuerySnapshot itemsQuerySnapshot = await itemsCollectionRef.get();

      for (QueryDocumentSnapshot transactionItemDoc in itemsQuerySnapshot
          .docs) {
        String productUid = transactionItemDoc['productUid'];

        CollectionReference inventoryCollectionRef = _firestore.collection(
            'providers').doc(transaction.order.providerId).collection(
            'products');
        QuerySnapshot snapshot = await inventoryCollectionRef
            .snapshots()
            .first;

        for (QueryDocumentSnapshot doc in snapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          if (doc.id == productUid) {
            await _firestore.collection('providers').doc(
                transaction.order.providerId).collection('products').doc(
                doc.id).set({
              'quantity': transactionItemDoc['quantity'] + data['quantity']
            }, SetOptions(merge: true));
          }
        }
      }
    }
    await _firestore.collection('transactions')
        .doc(transaction.order.uid)
        .set({
      'status': "order dibatalkan"
    }, SetOptions(merge: true));
  }

  Future<void> reportOrder(OrderItemWithProviderAndConsumer transaction,File imageFile,String comment)async{
    User? user = _auth.currentUser;
    _isLoading = true;
    notifyListeners();
    if (user != null && user.email != null) {
      String? photoUrl = await uploadReportImage(imageFile, transaction.order.uid);
      await _firestore.collection('transactions').doc(transaction.order.uid).set({
        if (photoUrl != null) 'reportPhoto': photoUrl,
        'reportReason':comment,
      }, SetOptions(merge: true));
    }
    _isLoading = false;
    notifyListeners();
  }
}