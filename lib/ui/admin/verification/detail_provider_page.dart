import 'package:flutter/material.dart';
import 'package:greenneeds/model/Profile.dart';
import 'package:provider/provider.dart';

import '../../provider/revenue_report/provider_revenue_view_model.dart';
import '../../utils.dart';
import 'admin_verification_view_model.dart';

class DetailProviderPage extends StatefulWidget {
  FoodProviderProfile provider;
  DetailProviderPage({super.key, required this.provider});

  @override
  State<DetailProviderPage> createState() => _DetailProviderPageState();
}

class _DetailProviderPageState extends State<DetailProviderPage> {
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
    final adminVerificationViewModel =
    Provider.of<AdminVerificationViewModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Detail Penyedia Makanan"),
      ),
      body: SingleChildScrollView(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30, vertical: 10),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: widget.provider.photoUrl != null
                                  ? NetworkImage(widget.provider.photoUrl!)
                                  : const AssetImage('images/placeholder_profile.jpg')
                              as ImageProvider<Object>?,
                              radius: 20,
                            ),
                            SizedBox(width: 10),
                            Text(widget.provider.name,style: TextStyle(fontSize: 18)),
                          ],
                        ),
                        Text(widget.provider.email),
                        Text(widget.provider.phoneNumber),
                        Text("${widget.provider.address},${widget.provider.postalcode},${widget.provider.city}"),
                      ]),
                ),

                const Divider(thickness: 10, color: Colors.black12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  child: FutureBuilder<int>(
                    future: adminVerificationViewModel.getTotalPostsForUser(widget.provider.uid),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        int postCount = snapshot.data ?? 0;
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Total Post Forum:"),
                            Text("$postCount")
                          ],
                        );
                      }
                    },
                  ),
                ),
                const Divider(thickness: 10, color: Colors.black12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Riwayat Transaksi",
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 10),
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
                        stream: adminVerificationViewModel.reportRevenueStream(startDate, endDate,widget.provider),
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
                                        Text("Total Transaksi :"),
                                        Text("Total Transaksi sukses :"),
                                        Text("Total Transaksi dibatalkan :"),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text("${data['totalTransactions']}", style: TextStyle(fontWeight: FontWeight.bold)),
                                        Text("${data['successfulTransactions']}", style: TextStyle(fontWeight: FontWeight.bold)),
                                        Text("${data['canceledTransactions']}", style: TextStyle(fontWeight: FontWeight.bold)),
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
                                          Text("Total Penjualan :"),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text("${formatCurrencyWithDouble(data['totalSell'])}", style: TextStyle(fontWeight: FontWeight.bold)),
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
                                          Text("Total Biaya :"),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text("${formatCurrencyWithDouble(data['totalCost'])}", style: TextStyle(fontWeight: FontWeight.bold)),
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
                                          Text("Total Pendapatan :"),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text("${formatCurrencyWithDouble(data['totalRevenue'])}", style: TextStyle(fontWeight: FontWeight.bold)),
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

              ]
          )
      ),
    );
  }
}
