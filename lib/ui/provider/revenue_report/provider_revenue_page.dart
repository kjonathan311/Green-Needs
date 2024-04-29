
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:greenneeds/ui/admin/revenue_report/admin_revenue_view_model.dart';
import 'package:greenneeds/ui/provider/profile/food_provider_profile_popupwindow.dart';
import 'package:greenneeds/ui/provider/revenue_report/provider_revenue_view_model.dart';
import 'package:provider/provider.dart';

import '../../utils.dart';

class ProviderRevenuePage extends StatefulWidget {
  const ProviderRevenuePage({super.key});

  @override
  State<ProviderRevenuePage> createState() => _ProviderRevenuePageState();
}

class _ProviderRevenuePageState extends State<ProviderRevenuePage> {
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _startDateController.text = formatDate(startDate);
    _endDateController.text = formatDate(endDate);
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != startDate) {
      setState(() {
        startDate = picked;
        _startDateController.text = formatDate(startDate);
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != endDate) {
      setState(() {
        endDate = picked;
        _endDateController.text = formatDate(endDate);
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    final providerRevenueViewModel =
    Provider.of<ProviderRevenueViewModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Riwayat Pendapatan"),
        actions: [
          IconButton(
            icon: Icon(Icons.person_2),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return FoodProviderProfilePopUpWindow();
                },
              );
            },
          ),
        ],
      ),
      body:Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            TextField(
              controller: _startDateController,
              readOnly: true,
              onTap: () => _selectStartDate(context),
              decoration: InputDecoration(
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.0),
                  ),
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _selectStartDate(context),
                ),
                contentPadding:
                EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _endDateController,
              readOnly: true,
              onTap: () => _selectEndDate(context),
              decoration: InputDecoration(
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.0),
                  ),
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _selectEndDate(context),
                ),
                contentPadding:
                EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
              ),
            ),
            const SizedBox(height: 20),

            StreamBuilder<Map<String, dynamic>>(
              stream: providerRevenueViewModel.reportRevenueStream(startDate, endDate),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  Map<String, dynamic> data = snapshot.data!;
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Total Transaksi :", style: TextStyle(fontSize: 18)),
                              Text("Total Transaksi sukses :", style: TextStyle(fontSize: 18)),
                              Text("Total Transaksi dibatalkan :", style: TextStyle(fontSize: 18)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text("${data['totalTransactions']}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              Text("${data['successfulTransactions']}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              Text("${data['canceledTransactions']}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          )
                        ],
                      ),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Total Penjualan :", style: TextStyle(fontSize: 18)),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text("${formatCurrencyWithDouble(data['totalSell'])}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Total Biaya :", style: TextStyle(fontSize: 18)),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text("${formatCurrencyWithDouble(data['totalCost'])}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Total Pendapatan :", style: TextStyle(fontSize: 18)),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text("${formatCurrencyWithDouble(data['totalRevenue'])}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          )
                        ],
                      ),
                    ],
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return CircularProgressIndicator(); // Or any other loading indicator
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
