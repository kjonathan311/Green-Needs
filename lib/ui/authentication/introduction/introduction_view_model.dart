import 'package:flutter/material.dart';
import 'package:greenneeds/model/FirebaseAuthProvider.dart';


class IntroductionPageViewModel extends ChangeNotifier  {
  final FirebaseAuthProvider authProvider;

  IntroductionPageViewModel(this.authProvider);

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<void> handleInitialRoute(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    final currentUser = authProvider.auth.currentUser;
    if (currentUser != null) {
      String? userType = await authProvider.determineUserType();
      if (userType != null) {
        switch (userType) {
          case "consumer":
            Navigator.of(context).pushNamedAndRemoveUntil("/consumer", (route) => false);
            break;
          case "provider":
            Navigator.of(context).pushNamedAndRemoveUntil("/provider", (route) => false);
            break;
          case "admin":
            Navigator.of(context).pushNamedAndRemoveUntil("/admin", (route) => false);
            break;
          default:
            break;
        }
      }else{
        await authProvider.logout();
        _isLoading = false;
        notifyListeners();
      }
    }
    _isLoading = false;
    notifyListeners();
  }
}
