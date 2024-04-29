import 'package:flutter/material.dart';
import 'package:greenneeds/ui/forum/forum_page.dart';
import 'package:greenneeds/ui/provider/order/provider_order_page.dart';
import 'package:greenneeds/ui/provider/revenue_report/provider_revenue_page.dart';
import 'package:greenneeds/ui/provider/verification/unverified_screen.dart';
import 'package:greenneeds/ui/provider/verification/food_provider_verification_view_model.dart';
import 'package:provider/provider.dart';
import 'daily_waste/daily_waste_page.dart';
import 'menu/menu_page.dart';

class ProviderScreen extends StatefulWidget {
  const ProviderScreen({super.key});

  @override
  State<ProviderScreen> createState() => _ProviderScreenState();
}

class _ProviderScreenState extends State<ProviderScreen> {
  int _selectedTab = 0;

  final List _pages = [
    MenuPage(),
    DailyWastePage(),
    ProviderOrderPage(),
    ProviderRevenuePage(),
    ForumPage(),
  ];

  _changeTab(int index) {
    setState(() {
      _selectedTab = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final verificationViewModel = Provider.of<FoodProviderVerificationViewModel>(context);
    return StreamBuilder<String>(
      stream: verificationViewModel.verificationStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final String status = snapshot.data!;
          if (status == "verified") {
            return Scaffold(
              body: _pages[_selectedTab],
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: _selectedTab,
                onTap: (index) => _changeTab(index),
                unselectedItemColor: Color.fromRGBO(214, 218, 200, 1.0),
                selectedItemColor: Color.fromRGBO(156, 175, 170, 1.0),
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.menu_book),
                    label: "Menu",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.wysiwyg),
                    label: "Jual",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.shopping_bag),
                    label: "Orders",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.money),
                    label: "Laporan",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.forum),
                    label: "Forum",
                  ),
                ],
              ),
            );
          }
          else {
            return Scaffold(
              body: UnverifiedScreen(
                verification: status,
              ),
            );
          }
        } else {
          return Container(
            color: Colors.white,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}

