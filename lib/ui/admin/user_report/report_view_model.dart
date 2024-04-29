
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../model/Address.dart';
import '../../../model/MenuItem.dart';
import '../../../model/OrderItem.dart';
import '../../../model/Profile.dart';

class ReportViewModel extends ChangeNotifier{

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Stream<List<OrderItemWithProviderAndConsumer>> reportOrdersStream() {
    User? user = _auth.currentUser;
    if (user != null && user.email != null) {
      CollectionReference transactionCollectionRef =
      _firestore.collection('transactions');

      return transactionCollectionRef.snapshots().asyncMap((snapshot) async {
        List<OrderItemWithProviderAndConsumer> orders = [];

        for (DocumentSnapshot doc in snapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          if (data['status'] == "order selesai" && data['reportPhoto']!=null && data['reportReason']!=null) {
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

  Future<Address?> getAddress(String consumerId, String addressDestinationId) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot addressSnapshot = await _firestore
            .collection('consumers')
            .doc(consumerId)
            .collection('addresses')
            .doc(addressDestinationId)
            .get();

        if (addressSnapshot.exists) {
          Map<String, dynamic> addressData =
          addressSnapshot.data() as Map<String, dynamic>;
          print(addressData['address']);
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



}