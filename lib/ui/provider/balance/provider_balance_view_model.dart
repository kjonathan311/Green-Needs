
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:greenneeds/model/Profile.dart';
import 'package:greenneeds/model/WithdrawBalance.dart';
import 'package:xendit/xendit.dart';

import '../../../xendit_api_key.dart';
import '../../utils.dart';

class ProviderBalanceViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  Xendit xendit = Xendit(apiKey: xenditApiKey);
  int balance = 0;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<int> getBalance() async {
    User? user = _auth.currentUser;
    if (user != null) {
      final snapshot = await _firestore.collection('providers')
          .doc(user.uid)
          .get();
      if (snapshot.exists) {
        int bal = snapshot.data()?['balance'] ??
            0;
        balance = bal;
        return bal;
      }
    }
    return 0;
  }
  Future<void> getInvoice(BuildContext context,FoodProviderProfile currentUser,int payment) async{
    User? user = _auth.currentUser;
    _isLoading=true;
    notifyListeners();
    if (user != null) {
      if (payment < 10000) {
        showCustomSnackBar(
            context, "pengisian saldo minimal Rp 10.0000", color: Colors.red);
        _isLoading = false;
        notifyListeners();
        return null;
      }
      try {
        var res = await xendit.invoke(
          endpoint: "POST https://api.xendit.co/payouts",
          headers: {
            // "for-user-id": "",
          },
          parameters: {
            "external_id": currentUser.uid,
            "email": "kjonathan311@gmail.com",
            "amount": payment,
          },
        );
        print(res);
        if (res != null) {
          var status = res["status"];
          if (status != null && status == "PENDING") {
            Map<String, dynamic> payoutData = {
              'providerId': currentUser.uid,
              'id': res['id'],
              'amount': res['amount'],
              'created': res['created'],
              'expiration_timestamp': res['expiration_timestamp'],
              'status': res['status'],
              'payout_Url': res['payout_url'],
            };
            await _firestore.collection('change_balances').add(payoutData);

            int currentBal=0;
            final snapshot = await _firestore.collection('providers')
                .doc(user.uid)
                .get();
            if (snapshot.exists) {
              int bal = snapshot.data()?['balance'] ??
                  0;
              currentBal = bal;
            }

            await _firestore.collection('providers')
                .doc(user.uid)
                .set({
              'balance': currentBal - res['amount'],
              'returnBalance': true
            }, SetOptions(merge: true));

            _isLoading = false;
            notifyListeners();
          } else {
            showCustomSnackBar(
                context, "gagal withdraw saldo", color: Colors.red);
            _isLoading = false;
            notifyListeners();
            return null;
          }
        } else {
          showCustomSnackBar(
              context, "gagal withdraw saldo", color: Colors.red);
          _isLoading = false;
          notifyListeners();
          return null;
        }
      } catch (e) {
        print(e);
        _isLoading = false;
        notifyListeners();
        return null;
      }
    }
  }

  Future<List<WithdrawBalance>> changeBalancesItems() async {
    User? user = _auth.currentUser;
    if (user != null && user.email != null) {
      CollectionReference ref = _firestore.collection('change_balances');
      QuerySnapshot snapshot = await ref.get();

      List<WithdrawBalance> items = [];
      for (QueryDocumentSnapshot doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        if (data['providerId'] == user.uid && data['id'] != null) {
          var res = await xendit.invoke(
            endpoint: "GET https://api.xendit.co/payouts/${data['id']}",
            headers: {
              // "for-user-id": "",
            },
            parameters: {},
          );
          if (res['status'] != data['status']) {
            await _firestore.collection('change_balances')
                .doc(doc.id)
                .set({'status': res['status']}, SetOptions(merge: true));
          }
          if ((res['status'] == "FAILED" || res['status'] == "VOIDED") && data['returnBalance'] == null) {
            int currentBal = 0;
            final providerSnapshot = await _firestore.collection('providers')
                .doc(user.uid)
                .get();
            if (providerSnapshot.exists) {
              int bal = providerSnapshot.data()?['balance'] ?? 0;
              currentBal = bal;
            }
            await _firestore.collection('providers')
                .doc(user.uid)
                .set({'balance': currentBal + res['amount']}, SetOptions(merge: true));

            await _firestore.collection('change_balances')
                .doc(doc.id)
                .set({'returnBalance': true}, SetOptions(merge: true));
            notifyListeners();
          }

            WithdrawBalance item = WithdrawBalance(
              uid: doc.id,
              id: data['id'],
              providerId: data['providerId'],
              amount: data['amount'],
              created: DateTime.parse(data['created']),
              expiration: DateTime.parse(data['expiration_timestamp']),
              status: data['status'],
              payout_url: data['payout_Url'],
            );

            items.add(item);

        }
      }

      items.sort((a, b) => b.created.compareTo(a.created));
      return items;
    }
    return [];
  }

}