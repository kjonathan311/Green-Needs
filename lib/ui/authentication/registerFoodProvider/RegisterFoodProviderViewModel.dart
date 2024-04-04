import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:greenneeds/model/FirebaseAuthProvider.dart';
import 'package:greenneeds/ui/utils.dart';

class RegisterFoodProviderViewModel extends ChangeNotifier {
  final FirebaseAuthProvider authProvider;

  RegisterFoodProviderViewModel(this.authProvider);

  //loading
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> registerFoodProvider(BuildContext context,String name,String email,String password,String phoneNumber,String address,String city) async {
    _isLoading = true;
    notifyListeners();

    if (name.isEmpty || email.isEmpty || password.isEmpty ||phoneNumber.isEmpty || address.isEmpty || city.isEmpty) {
      showCustomSnackBar(context, "Semua field perlu diisi.", color: Colors.red);

      _isLoading = false;
      notifyListeners();
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      showCustomSnackBar(context, "Format email tidak valid.", color: Colors.red);

      _isLoading = false;
      notifyListeners();
      return;
    }

    if (!RegExp(r'(^[\+]?[(]?[0-9]{3}[)]?[-\s\.]?[0-9]{3}[-\s\.]?[0-9]{4,6}$)').hasMatch(phoneNumber)) {
      showCustomSnackBar(context, "Format nomor telepon tidak valid.", color: Colors.red);

      _isLoading = false;
      notifyListeners();
      return;
    }

    AuthResult result = await authProvider.registerFoodProvider(name,email, password,phoneNumber,address,city);

    if (result.user != null) {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Registrasi Sukses"),
            content: Text("sukses membuat akun penyedia makanan."),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
      Navigator.pushReplacementNamed(context, '/login');

    } else {
      String errorMessage = result.error ?? 'Register failed';
      showCustomSnackBar(context, errorMessage, color: Colors.red);
    }
    _isLoading = false;
    notifyListeners();
  }

}