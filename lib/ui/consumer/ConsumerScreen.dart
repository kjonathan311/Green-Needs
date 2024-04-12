import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:greenneeds/ui/consumer/food_delivery/address/AddressViewModel.dart';
import 'package:greenneeds/ui/consumer/inventory/InventoryPage.dart';
import 'package:provider/provider.dart';

import 'food_delivery/address/AddressPage.dart';
import 'food_delivery/search/MainSearchPage.dart';

class ConsumerScreen extends StatefulWidget {
  const ConsumerScreen({Key? key}) : super(key: key);

  @override
  State<ConsumerScreen> createState() => _ConsumerScreenState();
}

class _ConsumerScreenState extends State<ConsumerScreen> {
  int _selectedTab = 0;
  late AddressViewModel addressViewModel;
  bool _selectedAddressInitialized = false;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    addressViewModel = Provider.of<AddressViewModel>(context, listen: false);

    _updatePages();
    _listenToSelectedAddress();
  }

  void _updatePages() {
    _pages = <Widget>[
      const InventoryPage(),
      if (_selectedAddressInitialized)
        MainSearchPage()
      else
        AddressPage(),
      const Center(
        child: Text("Orders"),
      ),
      const Center(
        child: Text("Forum"),
      ),
    ];
  }

  void _listenToSelectedAddress() {
    addressViewModel.addListener(() {
      setState(() {
        _selectedAddressInitialized = addressViewModel.selectedAddress != null;
        _updatePages();
      });
    });
  }

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
          BottomNavigationBarItem(icon: Icon(Icons.inventory), label: "Inventori"),
          BottomNavigationBarItem(icon: Icon(Icons.food_bank), label: "Beli Food Waste"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: "Orders"),
          BottomNavigationBarItem(icon: Icon(Icons.forum), label: "Forum"),
        ],
      ),
    );
  }
}



