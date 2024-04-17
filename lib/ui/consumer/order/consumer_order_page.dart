import 'package:flutter/material.dart';
import 'package:greenneeds/model/OrderItem.dart';
import 'package:greenneeds/ui/consumer/order/consumer_order_detail_page.dart';
import 'package:greenneeds/ui/consumer/order/consumer_order_view_model.dart';
import 'package:greenneeds/ui/utils.dart';
import 'package:provider/provider.dart';

class ConsumerOrderPage extends StatefulWidget {
  const ConsumerOrderPage({super.key});

  @override
  State<ConsumerOrderPage> createState() => _ConsumerOrderPageState();
}

class _ConsumerOrderPageState extends State<ConsumerOrderPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
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
                    OrderLayout(),
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
    final consumerOrderViewModel = Provider.of<ConsumerOrderViewModel>(context);
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 10),
        child: StreamBuilder<List<OrderItemWithProvider>>(
          stream: consumerOrderViewModel.ordersStream(1),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                height: 500,
                  child: Center(child: CircularProgressIndicator())
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              List<OrderItemWithProvider> orders = snapshot.data ?? [];
              return Column(
                children: orders.map((order) => OrderListTile(transaction: order)).toList(),
              );
            }
          },
        ),
      ),
    );
  }
}


class OrderListTile extends StatefulWidget {
  final OrderItemWithProvider transaction;
  const OrderListTile({super.key,required this.transaction});

  @override
  State<OrderListTile> createState() => _OrderListTileState();
}

class _OrderListTileState extends State<OrderListTile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) =>
                ConsumerOrderDetailPage(
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
                        height: 35,
                        child: Text("${widget.transaction.provider.name}",maxLines: 1,overflow: TextOverflow.ellipsis)
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
                  child: Text("${widget.transaction.order.status}"))
            ],
          )
      ),
    );
  }
}
