
import 'package:flutter/material.dart';
import 'package:greenneeds/model/OrderItem.dart';
import 'package:greenneeds/ui/provider/order/provider_order_detail_page.dart';
import 'package:greenneeds/ui/provider/order/provider_order_view_model.dart';
import 'package:provider/provider.dart';

import '../../../model/Address.dart';
import '../../../services/notification_service.dart';
import '../../utils.dart';
import '../profile/food_provider_profile_popupwindow.dart';

class ProviderOrderPage extends StatefulWidget {
  const ProviderOrderPage({super.key});

  @override
  State<ProviderOrderPage> createState() => _ProviderOrderPageState();
}

class _ProviderOrderPageState extends State<ProviderOrderPage> {
  final notificationService=NotificationService();


  @override
  void initState() {
    super.initState();
    notificationService.firebaseNotification(context);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Riwayat Order"),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
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
      body: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              TabBar(
                tabs: [
                  Tab(text: "Orders"),
                  Tab(text: "History"),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    OrderLayout(),
                    HistoryLayout(),
                  ],
                ),
              ),
            ],
          )),
    );
  }
}

class OrderLayout extends StatefulWidget {
  const OrderLayout({super.key});

  @override
  State<OrderLayout> createState() => _OrderLayoutState();
}

class _OrderLayoutState extends State<OrderLayout> {
  @override
  Widget build(BuildContext context) {
    final providerOrderViewModel = Provider.of<ProviderOrderViewModel>(context);
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 10),
        child: StreamBuilder<List<OrderItemWithProviderAndConsumer>>(
          stream: providerOrderViewModel.ordersStream(1),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                  height: 500,
                  child: Center(child: CircularProgressIndicator())
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              List<OrderItemWithProviderAndConsumer> orders = snapshot.data ??
                  [];
              if (orders.isEmpty) {
                return Container(
                    height: 500,
                    child: Center(child: Text("Tidak ada order aktif."))
                );
              } else {
                return Column(
                  children: orders.map((order) =>
                      OrderListTile(transaction: order)).toList(),
                );
              }
            }
          },
        ),
      ),
    );
  }
}
class HistoryLayout extends StatefulWidget {
  const HistoryLayout({super.key});

  @override
  State<HistoryLayout> createState() => _HistoryLayoutState();
}

class _HistoryLayoutState extends State<HistoryLayout> {
  @override
  Widget build(BuildContext context) {
    final providerOrderViewModel = Provider.of<ProviderOrderViewModel>(context);
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 10),
        child: StreamBuilder<List<OrderItemWithProviderAndConsumer>>(
          stream: providerOrderViewModel.ordersStream(2),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                  height: 500,
                  child: Center(child: CircularProgressIndicator())
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              List<OrderItemWithProviderAndConsumer> orders = snapshot.data ??
                  [];
              if (orders.isEmpty) {
                return Container(
                    height: 500,
                    child: Center(child: Text("Tidak ada order aktif."))
                );
              } else {
                return Column(
                  children: orders.map((order) =>
                      OrderListTile(transaction: order)).toList(),
                );
              }
            }
          },
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
                ProviderOrderDetailPage(
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
                            Text("Tipe order : ${widget.transaction.order.type}",maxLines: 1,overflow: TextOverflow.ellipsis),
                            Text("${widget.transaction.itemCount} items"),
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

              Positioned(
                  bottom: 0,
                  right: 0,
                  child: Text("${widget.transaction.order.status}",style: TextStyle(color: textStatusColor)),
                  )
            ],
          )
      ),
    );
  }
}
