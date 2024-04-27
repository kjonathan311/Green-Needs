import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:greenneeds/ui/consumer/food_delivery/address/address_view_model.dart';
import 'package:greenneeds/ui/consumer/inventory/inventory_page.dart';
import 'package:greenneeds/ui/consumer/order/consumer_order_page.dart';
import 'package:greenneeds/ui/forum/forum_page.dart';
import 'package:provider/provider.dart';

import 'food_delivery/address/address_page.dart';
import 'food_delivery/home_food_delivery_page.dart';

class ConsumerScreen extends StatefulWidget {
  const ConsumerScreen({Key? key}) : super(key: key);

  @override
  State<ConsumerScreen> createState() => _ConsumerScreenState();
}

class _ConsumerScreenState extends State<ConsumerScreen> {
  int _selectedTab = 0;
  late AddressViewModel addressViewModel;
  late List<Widget> _pages;
  bool _selectedAddressInitialized = false;

  @override
  void initState() {
    super.initState();
    addressViewModel = Provider.of<AddressViewModel>(context, listen: false);
    _updatePages();
    _listenToSelectedAddress();
  }

  @override
  void dispose() {
    addressViewModel.removeListener(_updatePages);
    super.dispose();
  }
  void _updatePages() {
    _pages = <Widget>[
      const InventoryPage(),
      if (_selectedAddressInitialized)
        HomeFoodDeliveryPage()
      else
        AddressPage(),
      ConsumerOrderPage(),
      ForumPage(),
    ];
  }

  void _listenToSelectedAddress() {
    addressViewModel.addListener(() {
      if (mounted) {
        setState(() {
          _selectedAddressInitialized = addressViewModel.selectedAddress != null;
          _updatePages();
        });
      }
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
