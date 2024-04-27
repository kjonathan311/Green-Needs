
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:greenneeds/model/MainSettings.dart';

import '../../utils.dart';

class SettingsViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<MainSettings?> fetchSettings()async{
    User? user = _auth.currentUser;
    if (user != null && user.email != null) {
      DocumentSnapshot snapshot =
      await _firestore.collection('main_settings').doc("1").get();
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

        final settings= MainSettings(
          costPerKm: (data['costPerKm']).toString(),
          tax: (data['tax']*100).round().toString(),
        );

        return settings;
      }
    }
    return null;
  }

  Future<void> editMainSettings(BuildContext context,String costPerKm,String tax)async {
    User? user = _auth.currentUser;
    _isLoading = true;
    notifyListeners();
    if (user != null && user.email != null) {

      if (costPerKm.isEmpty || tax.isEmpty) {
        showCustomSnackBar(context, "Semua field perlu diisi.", color: Colors.red);

        _isLoading = false;
        notifyListeners();
        return;
      }

      try {
        int costPerKmInt = int.tryParse(costPerKm) ?? 0;
        double taxDouble = double.tryParse(tax) ?? 0.0;

        if (costPerKmInt <= 0 || taxDouble <= 0) {
          showCustomSnackBar(context, "biaya per km dan biaya admin harus lebih dari 0.", color: Colors.red);
          _isLoading = false;
          notifyListeners();
          return;
        }

        taxDouble /= 100;

        await _firestore.collection('main_settings').doc("1").set({
          'costPerKm': costPerKmInt,
          'tax': taxDouble,
        }, SetOptions(merge: true));
      } catch (e) {
        print("Error: $e");
        showCustomSnackBar(context, "Tidak sukses update settings.", color: Colors.red);
        _isLoading = false;
        notifyListeners();
        return;
      }


      Navigator.pop(context);
    }
    _isLoading = false;
    notifyListeners();

  }


}