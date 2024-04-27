import 'package:flutter/material.dart';
import 'package:greenneeds/model/FirebaseAuthProvider.dart';
import 'package:greenneeds/services/notification_service.dart';
import 'package:greenneeds/ui/utils.dart';

class LoginViewModel extends ChangeNotifier {
  final FirebaseAuthProvider authProvider;
  final notifications=NotificationService();

  LoginViewModel(this.authProvider);
  //loading
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> login(BuildContext context,String email,String password) async {
    _isLoading = true;
    notifyListeners();

    if (email.isEmpty || password.isEmpty) {
      showCustomSnackBar(context, "Semua field perlu diisi", color: Colors.red);

      _isLoading = false;
      notifyListeners();
      return;
    }

    AuthResult result = await authProvider.login(email, password);
    if(result.error==null && result.type!="admin"){
        await notifications.requestPermission();
        await notifications.getToken(result.type!);
    }

    if (result.user != null) {
      if(result.type=="consumer"){
        await Navigator.of(context).pushNamedAndRemoveUntil("/consumer", (route) => false);
      }else if(result.type=="provider"){
        await Navigator.of(context).pushNamedAndRemoveUntil("/provider", (route) => false);
      }else if(result.type=="admin"){
        await Navigator.of(context).pushNamedAndRemoveUntil("/admin", (route) => false);
      }else{
        showCustomSnackBar(context,"login gagal", color: Colors.red);
      }
    } else {
      String errorMessage = result.error ?? 'Login gagal';
      showCustomSnackBar(context, errorMessage, color: Colors.red);
    }
    _isLoading = false;
    notifyListeners();
  }

}