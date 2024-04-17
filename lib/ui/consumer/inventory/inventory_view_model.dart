
import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:greenneeds/model/InventoryItem.dart';
import 'package:greenneeds/services/notification_service.dart';

class InventoryViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  int _inventoryItemCount = 0;
  int get inventoryItemCount => _inventoryItemCount;

  int _nearingExpirationItemCount = 0;
  int get nearingExpirationItemCount => _nearingExpirationItemCount;

  final _itemCountController = StreamController<int>.broadcast();
  Stream<int> get itemCountStream => _itemCountController.stream;

  final _nearingExpirationItemCountController =
  StreamController<int>.broadcast();
  Stream<int> get nearingExpirationItemCountStream =>
      _nearingExpirationItemCountController.stream;

  int durationExp=0;

  void updateItemCount(int count) {
    _inventoryItemCount = count;
    _itemCountController.add(_inventoryItemCount);
  }

  void updateNearingExpirationItemCount(int count) {
    _nearingExpirationItemCount = count;
    _nearingExpirationItemCountController.add(_nearingExpirationItemCount);
  }

  DateTime getAheadDate(int duration) {
    return DateTime.now().add(Duration(days: duration));
  }
  bool isExpirationNear(DateTime expirationDate){
    final DateTime now = DateTime.now();
    final DateTime expirationThreshold = expirationDate.subtract(Duration(days: durationExp));
    return now.isBefore(expirationDate) && now.isAfter(expirationThreshold);
  }

  Future<int> getNotificationDuration() async {
    User? user = _auth.currentUser;
    if (user != null && user.email != null) {
      DocumentSnapshot snapshot =
      await _firestore.collection('consumers').doc(user.uid).get();
      if (snapshot.exists && snapshot.data() != null) {
        Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>;
        if (userData.containsKey('notificationDuration')) {
          return userData['notificationDuration'] as int;
        }
      }
    }
    return 14;
  }

  Stream<List<String>> categoriesStream() async* {
    User? user = _auth.currentUser;
    if (user != null && user.email != null) {
      yield* _firestore
          .collection('consumers')
          .doc(user.uid)
          .snapshots()
          .map((snapshot) {
        List<String> result = ["Semua item", 'tidak dikategorikan'];
        if (snapshot.exists) {
          if (snapshot.data()!.containsKey('categories')) {
            List<dynamic>? categoriesData = snapshot.get('categories');
            if (categoriesData != null && categoriesData is List) {
              List<String> categories = categoriesData.map((category) => category.toString()).toList();

              result.addAll(categories);
            }
          }
        }
        if (result.isEmpty) {
          return ["Semua item", 'tidak dikategorikan'];
        } else {
          return result;
        }
      });
    } else {
      yield [];
    }
  }

  Stream<List<InventoryItem>> inventoryItems(String category) async* {
    User? user = _auth.currentUser;
    int duration = await getNotificationDuration();
    durationExp=duration;
    if (user != null && user.email != null) {
      CollectionReference inventoryCollectionRef = _firestore.collection('consumers').doc(user.uid).collection('inventory');
      await for (QuerySnapshot snapshot in inventoryCollectionRef.snapshots()) {
        int nearingExpirationCount = 0;
        List<InventoryItem> items = [];
        for (QueryDocumentSnapshot doc in snapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          if (category == "Semua item" || data['category'] == category) {
            InventoryItem item = InventoryItem(
              uid: doc.id,
              name: data['name'],
              category: data['category'],
              quantity: data['quantity'],
              purchaseDate: (data['purchase_date'] as Timestamp).toDate(),
              expirationDate: (data['expiration_date'] as Timestamp).toDate(),
            );
            if (item.expirationDate.isBefore(getAheadDate(duration))) {
              nearingExpirationCount++;
            }
            items.add(item);
          }
        }
        updateNearingExpirationItemCount(nearingExpirationCount);
        updateItemCount(items.length);
        yield items;
      }
    } else {
      updateItemCount(0);
      updateNearingExpirationItemCount(0);
      yield [];
    }
  }

  Future<void> decreaseQuantity(String uid,int quantity) async{
    User? user = _auth.currentUser;
    if (user != null && user.email != null) {
      await _firestore.collection('consumers').doc(user.uid).collection('inventory').doc(uid).set({
        'quantity':quantity-1
      }, SetOptions(merge: true));
    }
  }
  Future<void> increaseQuantity(String uid,int quantity) async{
    User? user = _auth.currentUser;
    if (user != null && user.email != null) {
      await _firestore.collection('consumers').doc(user.uid).collection('inventory').doc(uid).set({
        'quantity':quantity+1
      }, SetOptions(merge: true));
    }
  }

  Future<void> notifyNearingExpiration() async {
    final int duration = await getNotificationDuration();
    final DateTime now = DateTime.now();
    final DateTime aheadDate = now.add(Duration(days: duration));

    User? user = _auth.currentUser;
    if (user != null && user.email != null) {
      CollectionReference inventoryCollectionRef = _firestore
          .collection('consumers')
          .doc(user.uid)
          .collection('inventory');
      QuerySnapshot snapshot = await inventoryCollectionRef.get();
      for (QueryDocumentSnapshot doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        DateTime expirationDate =
        (data['expiration_date'] as Timestamp).toDate();

        if (data['isAlerted'] != true &&
            expirationDate.isBefore(aheadDate) &&
            expirationDate.isAfter(now)) {
          NotificationService().showNotification(
            title: "Peringatan Item Inventory",
            body: "item ${data['name']} dekat tanggal expire.",
          );
          await inventoryCollectionRef.doc(doc.id).set(
              {'isAlerted': true}, SetOptions(merge: true));
        }

        if (data['isExpired'] != true &&
            (expirationDate.isBefore(DateTime.now()) ||
                (expirationDate.year == DateTime.now().year &&
                    expirationDate.month == DateTime.now().month &&
                    expirationDate.day == DateTime.now().day))) {
          NotificationService().showNotification(
            title: "Peringatan Item Inventory",
            body: "item ${data['name']} telah expire.",
          );
          await inventoryCollectionRef.doc(doc.id).set(
              {'isExpired': true}, SetOptions(merge: true));
        }
      }
    }
  }


  StreamSubscription<DocumentSnapshot>? _subscription;

  void subscribeToFirestoreChanges() {
    User? user = _auth.currentUser;
    if (user != null && user.email != null) {
      _subscription = _firestore
          .collection('consumers')
          .doc(user.uid)
          .snapshots()
          .listen((snapshot) {
        notifyNearingExpiration();
      });
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }


}

