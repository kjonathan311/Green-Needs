
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminRevenueViewModel extends ChangeNotifier{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<Map<String, dynamic>> reportRevenueStream(DateTime startDate, DateTime endDate) {
    User? user = _auth.currentUser;
    if (user != null && user.email != null) {
      CollectionReference transactionCollectionRef = _firestore.collection('transactions');

      return transactionCollectionRef.snapshots().asyncMap((snapshot) async {
        double totalRevenue = 0;
        int successfulTransactions = 0;
        int canceledTransactions = 0;

        for (DocumentSnapshot doc in snapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          DateTime transactionDate = (data['date'] as Timestamp).toDate();

          int transactionYear = transactionDate.year;
          int transactionMonth = transactionDate.month;
          int transactionDay = transactionDate.day;

          int startYear = startDate.year;
          int startMonth = startDate.month;
          int startDay = startDate.day;

          int endYear = endDate.year;
          int endMonth = endDate.month;
          int endDay = endDate.day;


          if ((transactionYear > startYear || (transactionYear == startYear && transactionMonth > startMonth) || (transactionYear == startYear && transactionMonth == startMonth && transactionDay >= startDay)) &&
              (transactionYear < endYear || (transactionYear == endYear && transactionMonth < endMonth) || (transactionYear == endYear && transactionMonth == endMonth && transactionDay <= endDay))) {
              if (data['status'] == "order selesai") {
                successfulTransactions++;
                totalRevenue += data['adminFee'];
              } else if (data['status'] == 'order dibatalkan') {
                canceledTransactions++;
              }
          }
        }

        return {
          'totalTransactions': successfulTransactions + canceledTransactions,
          'successfulTransactions': successfulTransactions,
          'canceledTransactions': canceledTransactions,
          'totalRevenue': totalRevenue,
        };
      });
    } else {
      return Stream.value({});
    }
  }


}