
import 'package:flutter/material.dart';

class DailyWastePage extends StatefulWidget {
  const DailyWastePage({super.key});

  @override
  State<DailyWastePage> createState() => _DailyWastePageState();
}

class _DailyWastePageState extends State<DailyWastePage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(text: "Ala Carte"),
              Tab(text: "Paket"),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                Center(child: Text('Ala Carte')),
                Center(child: Text('Paket')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
