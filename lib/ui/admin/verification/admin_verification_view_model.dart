import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../model/Profile.dart';
import '../../utils.dart';

class AdminVerificationViewModel extends ChangeNotifier{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<FoodProviderProfile>> unverifiedFoodProvidersStream(String status) async* {
    User? user = _auth.currentUser;
    if (user != null && user.email != null) {
      yield* _firestore
          .collection('providers')
          .where('status', isEqualTo: status)
          .snapshots()
          .map((snapshot) {
        List<FoodProviderProfile> unverifiedProviders = [];
        snapshot.docs.forEach((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          FoodProviderProfile profile = FoodProviderProfile(
            uid: doc.id,
            name: data['name'],
            email: data['email'],
            phoneNumber: data['phoneNumber'],
            address: data['address'],
            city: data['city'],
            status: data['status'],
            postalcode: data['postalcode'],
            photoUrl: data['photoUrl'],
          );
          unverifiedProviders.add(profile);
        });
        return unverifiedProviders;
      });
    } else {
      yield [];
    }
  }

  Stream<List<ConsumerProfile>> consumerProfilesStream(bool status) async* {
    User? user = _auth.currentUser;
    if (user != null && user.email != null) {
      yield* _firestore
          .collection('consumers')
          .where('status',isEqualTo: status)
          .snapshots()
          .map((snapshot) {
        List<ConsumerProfile> consumerProfiles = [];
        snapshot.docs.forEach((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          ConsumerProfile profile = ConsumerProfile(
            uid: doc.id,
            name: data['name'],
            email: data['email'],
            phoneNumber: data['phoneNumber'],
            photoUrl: data['photoUrl'],
          );
          consumerProfiles.add(profile);
        });
        return consumerProfiles;
      });
    } else {
      yield [];
    }
  }


  Future<int> getTotalPostsForUser(String uid) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('posts')
        .where('uidUser', isEqualTo: uid)
        .where('status',isEqualTo: true)
        .get();
    return snapshot.size;
  }

  Stream<Map<String, dynamic>> reportRevenueStream(DateTime startDate, DateTime endDate,FoodProviderProfile provider) {
    User? user = _auth.currentUser;
    if (user != null && user.email != null) {
      CollectionReference transactionCollectionRef = _firestore.collection('transactions');

      return transactionCollectionRef.snapshots().asyncMap((snapshot) async {
        double totalSell = 0;
        double totalCost=0;
        int successfulTransactions = 0;
        int canceledTransactions = 0;

        for (DocumentSnapshot doc in snapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          DateTime transactionDate = (data['date'] as Timestamp).toDate();


          if(data['providerId']==provider.uid) {
            if (transactionDate.isAfter(startDate) ||
                transactionDate.isAtSameMomentAs(startDate)) {
              if (transactionDate.isBefore(endDate) ||
                  transactionDate.isAtSameMomentAs(endDate)) {
                if (data['status'] == "order selesai") {
                  successfulTransactions++;
                  totalSell += data['totalPrice'];
                  if(data['shippingFee']!=null){
                    totalCost+=data['shippingFee'];
                  }
                } else if (data['status'] == 'order dibatalkan') {
                  canceledTransactions++;
                }
              }
            }
          }
        }

        return {
          'totalTransactions': successfulTransactions + canceledTransactions,
          'successfulTransactions': successfulTransactions,
          'canceledTransactions': canceledTransactions,
          'totalSell':totalSell,
          'totalCost':totalCost,
          'totalRevenue': totalSell-totalCost,
        };
      });
    } else {
      return Stream.value({});
    }
  }


  Stream<Map<String, dynamic>> reportTransactionStream(DateTime startDate, DateTime endDate,ConsumerProfile consumer) {
    User? user = _auth.currentUser;
    if (user != null && user.email != null) {
      CollectionReference transactionCollectionRef = _firestore.collection('transactions');

      return transactionCollectionRef.snapshots().asyncMap((snapshot) async {
        int successfulTransactions = 0;
        int canceledTransactions = 0;

        for (DocumentSnapshot doc in snapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          DateTime transactionDate = (data['date'] as Timestamp).toDate();


          if(data['consumerId']==consumer.uid) {
            if (transactionDate.isAfter(startDate) ||
                transactionDate.isAtSameMomentAs(startDate)) {
              if (transactionDate.isBefore(endDate) ||
                  transactionDate.isAtSameMomentAs(endDate)) {
                if (data['status'] == "order selesai") {
                  successfulTransactions++;
                } else if (data['status'] == 'order dibatalkan') {
                  canceledTransactions++;
                }
              }
            }
          }
        }

        return {
          'totalTransactions': successfulTransactions + canceledTransactions,
          'successfulTransactions': successfulTransactions,
          'canceledTransactions': canceledTransactions,
        };
      });
    } else {
      return Stream.value({});
    }
  }

  Future<void> verifyFoodProvider(BuildContext context,String uid) async {
    try {
      await _firestore.collection('providers').doc(uid).update({
        'status': 'verified',
      });
    } catch (error) {
      showCustomSnackBar(context, "gagal verifikasi user.", color: Colors.red);
    }
  }

  Future<void> denyFoodProvider(BuildContext context,String uid) async {
    try {
      await _firestore.collection('providers').doc(uid).update({
        'status': 'denied',
      });
    } catch (error) {
      showCustomSnackBar(context, "gagal menolak user.", color: Colors.red);
    }
  }

  Future<void> reinstateConsumer(BuildContext context,String uid) async {
    try {
      await _firestore.collection('consumers').doc(uid).update({
        'status': true,
      });
    } catch (error) {
      showCustomSnackBar(context, "gagal menolak user.", color: Colors.red);
    }
  }

  Future<void> blockConsumer(BuildContext context,String uid) async {
    try {
      await _firestore.collection('consumers').doc(uid).update({
        'status': false,
      });
    } catch (error) {
      showCustomSnackBar(context, "gagal menolak user.", color: Colors.red);
    }
  }


}