import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../model/Profile.dart';
import '../../utils.dart';
import 'admin_verification_view_model.dart';

class DetailConsumerPage extends StatefulWidget {
  ConsumerProfile consumer;
  DetailConsumerPage({super.key,required this.consumer});

  @override
  State<DetailConsumerPage> createState() => _DetailConsumerPageState();
}

class _DetailConsumerPageState extends State<DetailConsumerPage> {
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
        title: Text("Detail Konsumen"),
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
                              backgroundImage: widget.consumer.photoUrl != null
                                  ? NetworkImage(widget.consumer.photoUrl!)
                                  : const AssetImage('images/placeholder_profile.jpg')
                              as ImageProvider<Object>?,
                              radius: 20,
                            ),
                            SizedBox(width: 10),
                            Text(widget.consumer.name,style: TextStyle(fontSize: 18)),
                          ],
                        ),
                        Text(widget.consumer.email),
                        Text(widget.consumer.phoneNumber),
                      ]),
                ),

                const Divider(thickness: 10, color: Colors.black12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  child: FutureBuilder<int>(
                    future: adminVerificationViewModel.getTotalPostsForUser(widget.consumer.uid),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text("Loading..");
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
                        stream: adminVerificationViewModel.reportTransactionStream(startDate, endDate,widget.consumer),
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
