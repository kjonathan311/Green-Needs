import 'package:flutter/material.dart';
import 'package:greenneeds/ui/admin/verification/VerificationPage.dart';
import 'package:provider/provider.dart';

import '../../model/FirebaseAuthProvider.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _selectedTab = 0;

  final List<Widget> _pages = [
    VerificationPage(),
    Center(
      child: Text("Laporan"),
    ),
    Center(
      child: Text("Laporan user"),
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
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.person_2),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AdminProfilePopUpWindow();
                },
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedTab,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTab,
        onTap: _changeTab,
        unselectedItemColor: Color.fromRGBO(214, 218, 200, 1.0),
        selectedItemColor: Color.fromRGBO(156, 175, 170, 1.0),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.verified),
            label: "Verifikasi",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.money),
            label: "Laporan",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_box_outlined),
            label: "Laporan User",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.forum),
            label: "Forum",
          ),
        ],
      ),
    );
  }
}


class AdminProfilePopUpWindow extends StatelessWidget {
  const AdminProfilePopUpWindow({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<FirebaseAuthProvider>(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Divider(),
            Align(
                alignment: Alignment.centerLeft,
                child: Text("Pengaturan",
                    style: Theme.of(context).textTheme.titleMedium)),
            const SizedBox(
              height: 10.0,
            ),
            const SizedBox(
              height: 10.0,
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text("logout"),
              onTap: () async {
                await authProvider.logout();
                Navigator.of(context)
                    .pushNamedAndRemoveUntil("/introduction", (route) => false);
                Navigator.pushReplacementNamed(context, "/introduction");
              },
            )
          ],
        ),
      ),
    );
  }
}