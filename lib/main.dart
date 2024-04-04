import 'package:flutter/material.dart';
import 'package:greenneeds/ui/admin/AdminScreen.dart';
import 'package:greenneeds/ui/admin/verification/AdminVerificationViewModel.dart';
import 'package:greenneeds/ui/authentication/introduction/IntroductionPage.dart';
import 'package:greenneeds/ui/authentication/login/LoginPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:greenneeds/ui/authentication/registerConsumer/RegisterConsumerPage.dart';
import 'package:greenneeds/ui/authentication/registerFoodProvider/RegisterFoodProviderPage.dart';
import 'package:greenneeds/ui/consumer/ConsumerScreen.dart';
import 'package:greenneeds/ui/consumer/inventory/InventoryViewModel.dart';
import 'package:greenneeds/ui/consumer/inventory/category/InventoryCategoryPage.dart';
import 'package:greenneeds/ui/consumer/inventory/category/InventoryCategoryPageViewModel.dart';
import 'package:greenneeds/ui/consumer/inventory/item/add/AddInventoryItemPage.dart';
import 'package:greenneeds/ui/consumer/inventory/item/add/AddInventoryItemPageViewModel.dart';
import 'package:greenneeds/ui/consumer/inventory/item/detail/DetailInventoryItemPageViewModel.dart';
import 'package:greenneeds/ui/consumer/profile/ConsumerEditProfilePage.dart';
import 'package:greenneeds/ui/consumer/profile/ConsumerProfileViewModel.dart';
import 'package:greenneeds/ui/provider/ProviderScreen.dart';
import 'package:greenneeds/ui/provider/menu/MenuPageViewModel.dart';
import 'package:greenneeds/ui/provider/menu/item/add/AddMenuPage.dart';
import 'package:greenneeds/ui/provider/menu/item/add/AddMenuPageViewModel.dart';
import 'package:greenneeds/ui/provider/profile/FoodProviderEditProfilePage.dart';
import 'package:greenneeds/ui/provider/profile/FoodProviderProfileViewModel.dart';
import 'package:greenneeds/ui/provider/verification/VerificationFoodProviderViewModel.dart';
import 'package:provider/provider.dart';
import '/firebase_options.dart';
import 'model/FirebaseAuthProvider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<FirebaseAuthProvider>(
            create: (context) => FirebaseAuthProvider(),
          ),
          ChangeNotifierProvider<ConsumerProfileViewModel>(
            create: (context) => ConsumerProfileViewModel(),
          ),
          ChangeNotifierProvider<FoodProviderProfileViewModel>(
            create: (context) => FoodProviderProfileViewModel(),
          ),
          ChangeNotifierProvider<FoodProviderVerificationViewModel>(
            create: (context) => FoodProviderVerificationViewModel(),
          ),
          ChangeNotifierProvider<AdminVerificationViewModel>(
            create: (context) => AdminVerificationViewModel(),
          ),
          ChangeNotifierProvider<InventoryCategoryPageViewModel>(
            create: (context) => InventoryCategoryPageViewModel(),
          ),
          ChangeNotifierProvider<AddInventoryItemPageViewModel>(
              create: (context) => AddInventoryItemPageViewModel()),
          ChangeNotifierProvider<DetailInventoryItemPageViewModel>(
              create: (context) => DetailInventoryItemPageViewModel()),
          ChangeNotifierProvider<InventoryViewModel>(
              create: (context) => InventoryViewModel()),
          ChangeNotifierProvider<MenuPageViewModel>(
              create: (context) => MenuPageViewModel()),
          ChangeNotifierProvider<AddMenuPageViewModel>(
              create: (context) => AddMenuPageViewModel()),
        ],
        child: MaterialApp(
          title: 'Green Needs',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF7A779E), // primary color
              secondary: Colors.green, // accent color
            ),
            fontFamily: 'Poppins',
            scaffoldBackgroundColor: Colors.white,
            textTheme: TextTheme(),
            useMaterial3: true,
          ),
          initialRoute: "/introduction",
          routes: {
            "/introduction": (context) => IntroductionPage(),
            "/login": (context) => LoginPage(),
            "/register/consumer": (context) => RegisterConsumerPage(),
            "/register/foodprovider": (context) => RegisterFoodProviderPage(),
            "/consumer": (context) => ConsumerScreen(),
            "/consumer/inventory/add": (context) => AddInventoryItemPage(),
            "/consumer/inventory/category": (context) =>
                InventoryCategoryPage(),
            "/consumer/edit/profile": (context) => ConsumerEditProfilePage(),
            "/provider": (context) => ProviderScreen(),
            "/provider/edit/profile": (context) =>
                FoodProviderEditProfilePage(),
            "/provider/menu/add": (context) => AddMenuPage(),
            "/admin": (context) => AdminScreen(),
          },
        ));
  }
}
