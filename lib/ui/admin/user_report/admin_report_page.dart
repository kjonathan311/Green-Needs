
import 'package:flutter/material.dart';
import 'package:greenneeds/ui/admin/user_report/report_detail_page.dart';
import 'package:greenneeds/ui/admin/user_report/report_view_model.dart';
import 'package:provider/provider.dart';
import '../../../model/OrderItem.dart';
import '../../utils.dart';
import '../admin_screen.dart';

class AdminReportPage extends StatefulWidget {
  const AdminReportPage({super.key});

  @override
  State<AdminReportPage> createState() => _AdminReportPageState();
}

class _AdminReportPageState extends State<AdminReportPage> {
  @override
  Widget build(BuildContext context) {
    final reportViewModel = Provider.of<ReportViewModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Laporan Order User"),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 10),
          child: StreamBuilder<List<OrderItemWithProviderAndConsumer>>(
            stream: reportViewModel.reportOrdersStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                    height: 500,
                    child: Center(child: CircularProgressIndicator())
                );
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                List<OrderItemWithProviderAndConsumer> orders = snapshot.data ?? [];
                return Column(
                  children: orders.map((order) => OrderListTile(transaction: order)).toList(),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}



class OrderListTile extends StatefulWidget {
  final OrderItemWithProviderAndConsumer transaction;
  const OrderListTile({super.key,required this.transaction});

  @override
  State<OrderListTile> createState() => _OrderListTileState();
}

class _OrderListTileState extends State<OrderListTile> {

  @override
  Widget build(BuildContext context) {
    String status=widget.transaction.order.status;
    Color textStatusColor = statusColor(status);

    return GestureDetector(
      onTap: (){
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) =>
                ReportDetailPage(
                  transaction: widget.transaction,
                ))
        );
      },
      child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10.0),
          padding: EdgeInsets.all(15),
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Stack(
            children: [
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        width:250,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(width:150,child: Text("${widget.transaction.order.uid}",maxLines: 1,overflow: TextOverflow.ellipsis)),
                            Text("Alasan Laporan:",style: TextStyle(fontWeight: FontWeight.bold)),
                            Container(width:150,child: Text("${widget.transaction.order.reportReason}",maxLines: 2,overflow: TextOverflow.ellipsis)),
                            if(widget.transaction.order.rating!=null)
                              Row(
                                children: [
                                  Text("Rating : "),
                                  Icon(Icons.star,color: Colors.orange),
                                  Text("${widget.transaction.order.rating}")
                                ],
                              )
                          ],
                        )
                    ),
                    Text("${formatDateWithMonthAndTime(widget.transaction.order.date)}",style: TextStyle(color: Colors.grey),)
                  ],
                ),
              ),
              Positioned(
                  top: 0,
                  right: 0,
                  child: Text("${formatCurrency(widget.transaction.order.totalPayment)}")),
            ],
          )
      ),
    );
  }
}
