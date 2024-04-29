import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:greenneeds/ui/admin/admin_screen.dart';
import 'package:greenneeds/ui/admin/revenue_report/admin_revenue_view_model.dart';
import 'package:greenneeds/ui/admin/settings/settings_view_model.dart';
import 'package:greenneeds/ui/admin/user_report/report_view_model.dart';
import 'package:greenneeds/ui/admin/verification/admin_verification_view_model.dart';
import 'package:greenneeds/ui/authentication/introduction/introduction_page.dart';
import 'package:greenneeds/ui/authentication/login/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:greenneeds/ui/authentication/registerConsumer/register_consumer_page.dart';
import 'package:greenneeds/ui/authentication/registerFoodProvider/register_food_provider_page.dart';
import 'package:greenneeds/ui/chat/chat_view_model.dart';
import 'package:greenneeds/ui/consumer/Balance/add_balance_page.dart';
import 'package:greenneeds/ui/consumer/consumer_screen.dart';
import 'package:greenneeds/ui/consumer/balance/consumer_balance_view_model.dart';
import 'package:greenneeds/ui/consumer/food_delivery/address/address_view_model.dart';
import 'package:greenneeds/ui/consumer/food_delivery/cart/cart_view_model.dart';
import 'package:greenneeds/ui/consumer/food_delivery/detail/store/store_view_model.dart';
import 'package:greenneeds/ui/consumer/food_delivery/search/search_view_model.dart';
import 'package:greenneeds/ui/consumer/inventory/inventory_view_model.dart';
import 'package:greenneeds/ui/consumer/inventory/category/inventory_category_page.dart';
import 'package:greenneeds/ui/consumer/inventory/category/inventory_category_page_view_model.dart';
import 'package:greenneeds/ui/consumer/inventory/item/add/add_inventory_item_page.dart';
import 'package:greenneeds/ui/consumer/inventory/item/add/add_inventory_item_page_view_model.dart';
import 'package:greenneeds/ui/consumer/inventory/item/detail/detail_inventory_item_page_viewmodel.dart';
import 'package:greenneeds/ui/consumer/inventory/notification/inventory_notification_popupwindow_view_model.dart';
import 'package:greenneeds/ui/consumer/order/consumer_order_view_model.dart';
import 'package:greenneeds/ui/consumer/profile/consumer_edit_profile_page.dart';
import 'package:greenneeds/ui/consumer/profile/consumer_profile_view_model.dart';
import 'package:greenneeds/ui/consumer/verification/consumer_verification_view_model.dart';
import 'package:greenneeds/ui/forum/add_post_page.dart';
import 'package:greenneeds/ui/forum/forum_view_model.dart';
import 'package:greenneeds/ui/provider/balance/provider_balance_view_model.dart';
import 'package:greenneeds/ui/provider/balance/withdraw_page.dart';
import 'package:greenneeds/ui/provider/food_provider_screen.dart';
import 'package:greenneeds/ui/provider/daily_waste/daily_waste_page_view_model.dart';
import 'package:greenneeds/ui/provider/daily_waste/add/add_daily_waste_page.dart';
import 'package:greenneeds/ui/provider/daily_waste/add/add_daily_waste_view_model.dart';
import 'package:greenneeds/ui/provider/menu/menu_page_view_model.dart';
import 'package:greenneeds/ui/provider/menu/item/add/add_menu_page.dart';
import 'package:greenneeds/ui/provider/menu/item/add/add_menu_page_view_model.dart';
import 'package:greenneeds/ui/provider/menu/item/detail/detail_menu_view_model.dart';
import 'package:greenneeds/ui/provider/order/provider_order_view_model.dart';
import 'package:greenneeds/ui/provider/profile/food_provider_edit_profile_page.dart';
import 'package:greenneeds/ui/provider/profile/food_provider_profile_view_model.dart';
import 'package:greenneeds/ui/provider/revenue_report/provider_revenue_view_model.dart';
import 'package:greenneeds/ui/provider/verification/food_provider_verification_view_model.dart';
import 'package:provider/provider.dart';
import '/firebase_options.dart';
import 'model/FirebaseAuthProvider.dart';
import 'services/notification_service.dart';

Future<void> _backgroundMessageHandler(
    RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  NotificationService().initNotifications();
  await FirebaseMessaging.instance.getInitialMessage();
  FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);
  runApp(const MyApp());
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
          ChangeNotifierProvider<ConsumerVerificationViewModel>(
            create: (context) => ConsumerVerificationViewModel(),
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
          ChangeNotifierProvider<DetailMenuViewModel>(
              create: (context) => DetailMenuViewModel()),
          ChangeNotifierProvider<InventoryNotificationPopUpWindowViewModel>(
              create: (context) => InventoryNotificationPopUpWindowViewModel()),
          ChangeNotifierProvider<AddDailyWastePageViewModel>(
              create: (context) => AddDailyWastePageViewModel()),
          ChangeNotifierProvider<DailyWastePageViewModel>(
              create: (context) => DailyWastePageViewModel()),
          ChangeNotifierProvider<AddressViewModel>(
              create: (context) => AddressViewModel()),
          ChangeNotifierProvider<SearchViewModel>(
              create: (context) => SearchViewModel()),
          ChangeNotifierProvider<StoreViewModel>(
              create: (context) => StoreViewModel()),
          ChangeNotifierProvider<CartViewModel>(
              create: (context) => CartViewModel()),
         ChangeNotifierProvider<ConsumerBalanceViewModel>(
             create: (context)=>ConsumerBalanceViewModel(),
         ),
          ChangeNotifierProvider<ProviderBalanceViewModel>(
            create: (context)=>ProviderBalanceViewModel(),
          ),
          ChangeNotifierProvider<ConsumerOrderViewModel>(
            create: (context)=>ConsumerOrderViewModel(),
          ),
          ChangeNotifierProvider<ProviderOrderViewModel>(
              create: (context)=>ProviderOrderViewModel(),
          ),
          ChangeNotifierProvider<ChatViewModel>(
            create: (context)=>ChatViewModel(),
          ),
          ChangeNotifierProvider<ForumViewModel>(
            create: (context)=>ForumViewModel(),
          ),
          ChangeNotifierProvider<SettingsViewModel>(
            create: (context)=>SettingsViewModel(),
          ),
          ChangeNotifierProvider<ReportViewModel>(
            create: (context)=>ReportViewModel(),
          ),
          ChangeNotifierProvider<AdminRevenueViewModel>(
            create: (context)=>AdminRevenueViewModel(),
          ),
          ChangeNotifierProvider<ProviderRevenueViewModel>(
            create: (context)=>ProviderRevenueViewModel(),
          )
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
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
            "/consumer/inventory/category": (context) => InventoryCategoryPage(),
            "/consumer/edit/profile": (context) => ConsumerEditProfilePage(),
            "/provider": (context) => ProviderScreen(),
            "/provider/edit/profile": (context) => FoodProviderEditProfilePage(),
            "/provider/menu/add": (context) => AddMenuPage(),
            "/provider/daily/add":(context)=>AddDailyWastePage(),
            "/admin": (context) => AdminScreen(),
            "/consumer/balance":(context)=>AddBalancePage(),
            "/provider/balance":(context)=>WithdrawPage(),
            "/forum/add":(context)=>AddPostPage(),
          },
        ));
  }
}
