import 'package:flutter/material.dart';
import 'package:greenneeds/ui/consumer/DailyWaste/DailyWastePage.dart';
import 'package:greenneeds/ui/provider/verification/UnverifiedScreen.dart';
import 'package:greenneeds/ui/provider/verification/VerificationFoodProviderViewModel.dart';
import 'package:provider/provider.dart';

import 'menu/MenuPage.dart';

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
    Center(
      child: Text("Orders"),
    ),
    Center(
      child: Text("Laporan"),
    ),
    Center(
      child: Text("Forum"),
    ),
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
                    label: "Menu",
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
            color: Colors.black.withOpacity(0.2),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}

