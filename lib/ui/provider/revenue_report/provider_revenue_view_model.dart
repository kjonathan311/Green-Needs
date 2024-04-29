
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProviderRevenueViewModel extends ChangeNotifier{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<Map<String, dynamic>> reportRevenueStream(DateTime startDate, DateTime endDate) {
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


          if(data['providerId']==user.uid) {
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


}