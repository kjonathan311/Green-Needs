import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:greenneeds/ui/consumer/inventory/InventoryPage.dart';
import 'package:greenneeds/ui/consumer/profile/ConsumerProfilePopUpWindow.dart';

class ConsumerScreen extends StatefulWidget {
  const ConsumerScreen({super.key});

  @override
  State<ConsumerScreen> createState() => _ConsumerScreenState();
}

class _ConsumerScreenState extends State<ConsumerScreen> {
  int _selectedTab = 0;

  final List _pages = [
    const InventoryPage(),
    const Center(
      child: Text("Beli Makanan"),
    ),
    const Center(
      child: Text("Orders"),
    ),
    const Center(
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
    return Scaffold(
      body: _pages[_selectedTab],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTab,
        onTap: (index) => _changeTab(index),
        unselectedItemColor: const Color.fromRGBO(214, 218, 200, 1.0),
        selectedItemColor: const Color.fromRGBO(156, 175, 170, 1.0),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.inventory), label: "Inventori"),
          BottomNavigationBarItem(
              icon: Icon(Icons.food_bank), label: "Beli Food Waste"),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag), label: "Orders"),
          BottomNavigationBarItem(icon: Icon(Icons.forum), label: "Forum"),
        ],
      ),
    );
  }
}

