
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:greenneeds/model/Profile.dart';
import 'package:xendit/xendit.dart';

import '../../../xendit_api_key.dart';
import '../../utils.dart';

class AddBalanceViewModel extends ChangeNotifier{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Xendit xendit = Xendit(apiKey: xenditApiKey);
  int balance = 0;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String invoice_id="";

  Future<int> getBalance() async {
    User? user = _auth.currentUser;
    if (user != null) {
      final snapshot = await _firestore.collection('consumers').doc(user.uid).get();
      if (snapshot.exists) {
        int bal = snapshot.data()?['balance'] ?? 0; // Provide a default value if balance is not found
        balance=bal;
        return bal;
      }
    }
    return 0;
  }

  Future<String?> getInvoice(BuildContext context,ConsumerProfile currentUser,int payment) async{
    _isLoading=true;
    notifyListeners();
    if(payment<10000){
      showCustomSnackBar(context, "pengisian saldo minimal Rp 10.0000", color: Colors.red);
      _isLoading=false;
      notifyListeners();
      return null;
    }
    try {
      var res = await xendit.invoke(
        endpoint: "POST https://api.xendit.co/v2/invoices",
        headers: {
          // "for-user-id": "",
        },
        parameters: {
          "external_id": currentUser.uid,
          "payer_email": currentUser.email,
          "amount": payment,
        },
      );
      print(res);
      print(balance);
      if (res != null) {
        var status = res["status"];
        var invoiceUrl = res["invoice_url"];
        if(status!=null && status=="PENDING"){
          _isLoading=false;
          notifyListeners();
          invoice_id=res["id"];
          return invoiceUrl;
        }else{
          showCustomSnackBar(context, "gagal pengisian saldo", color: Colors.red);
          _isLoading=false;
          notifyListeners();
          return null;
        }
      }else{
        showCustomSnackBar(context, "gagal pengisian saldo", color: Colors.red);
        _isLoading=false;
        notifyListeners();
        return null;
      }
    }catch(e){
      print(e);
      _isLoading=false;
      notifyListeners();
      return null;
    }
  }
  Future<void> getPaymentStatus(BuildContext context) async{
    _isLoading=true;
    notifyListeners();
    User? user = _auth.currentUser;
    if(invoice_id.isNotEmpty && user!=null){
      try{
        var res = await xendit.invoke(
          endpoint: "GET https://api.xendit.co/v2/invoices/${invoice_id}",
          headers: {
            // "for-user-id": "",
          },
        );
        if(res["status"]=="SETTLED"){
          var paidAmount=res["paid_amount"];
          await _firestore.collection('consumers').doc(user.uid).set({
            "balance": balance+paidAmount,
          }, SetOptions(merge: true));
          _isLoading=false;
          notifyListeners();
          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Tambah Saldo Sukses"),
                content: Text("Sukses menambahkan saldo user"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context); // Proceed
                    },
                    child: Text("OK"),
                  ),
                ],
              );
            },
          );

        }else{
          _isLoading=false;
          notifyListeners();
          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Pembayaran belum selesai"),
                content: Text("Apakah ingin keluar dari halaman ini?"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Proceed
                    },
                    child: Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Proceed
                      Navigator.pop(context); // Proceed

                    },
                    child: Text("OK"),
                  ),
                ],
              );
            },
          );
        }
      }catch(e){
        print(e);
        _isLoading=false;
        notifyListeners();
      }
    }
  }
}