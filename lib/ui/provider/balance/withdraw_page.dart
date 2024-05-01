
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:greenneeds/model/WithdrawBalance.dart';
import 'package:greenneeds/ui/provider/balance/provider_balance_view_model.dart';
import 'package:greenneeds/ui/provider/balance/web_withdraw_page.dart';
import 'package:provider/provider.dart';

import '../../utils.dart';
import '../profile/food_provider_profile_view_model.dart';

class WithdrawPage extends StatefulWidget {
  const WithdrawPage({Key? key});

  @override
  State<WithdrawPage> createState() => _WithdrawPageState();
}

class _WithdrawPageState extends State<WithdrawPage> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final TextEditingController _balanceController = TextEditingController();
    final balanceViewModel = Provider.of<ProviderBalanceViewModel>(context);
    final foodProviderProfileViewModel = Provider.of<FoodProviderProfileViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("Saldo"),
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: () async {
          // Perform the refresh action here
          setState(() {});
        },
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Saldo sekarang:"),
                          FutureBuilder(
                            future: balanceViewModel.getBalance(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text("${snapshot.error}");
                              } else {
                                _balanceController.text = balanceViewModel.balance.toString();
                                return Text("${formatCurrency(balanceViewModel.balance)}");
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    FutureBuilder<List<WithdrawBalance>>(
                      future: balanceViewModel.changeBalancesItems(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting && balanceViewModel.isLoading == false) {
                          return Container(
                            height: 500,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          List<WithdrawBalance> items = snapshot.data ?? [];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                  onPressed: () async {
                                    if (_balanceController.text.isNotEmpty) {
                                      await balanceViewModel.getInvoice(context, foodProviderProfileViewModel.foodProviderProfile!, int.parse(_balanceController.text.trim()));
                                    }
                                  },
                                  child: Text("Tarik Saldo", style: TextStyle(color: Colors.white)),
                                ),
                              ),
                              Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text("History Pegambilan saldo")),
                              Column(
                                children: items.map((item) => WithdrawBalanceListTile(withdrawBalance: item)).toList(),
                              ),
                            ],
                          );
                        }
                      },
                    )
                  ],
                ),
              ),
            ),
            if (balanceViewModel.isLoading)
              Container(
                color: Colors.black.withOpacity(0.1),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              )
          ],
        ),
      ),
    );
  }
}


class WithdrawBalanceListTile extends StatefulWidget {
  final WithdrawBalance withdrawBalance;
  const WithdrawBalanceListTile({super.key, required this.withdrawBalance});

  @override
  State<WithdrawBalanceListTile> createState() => _WithdrawBalanceListTileState();
}

class _WithdrawBalanceListTileState extends State<WithdrawBalanceListTile> {

  @override
  Widget build(BuildContext context) {

    String status=widget.withdrawBalance.status;
    Color textStatusColor = statusWithdrawColor(status); // Default color

    // Set color based on status
    return GestureDetector(
      onTap: (){
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => WebWithdrawPage(
              url: widget.withdrawBalance.payout_url,
            ),
          ),
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
                        width:150,
                        child: Text("${formatCurrency(widget.withdrawBalance.amount)}",maxLines: 1,overflow: TextOverflow.ellipsis)
                    ),
                    Text("Exp Date: ${formatDateWithMonthAndTime(widget.withdrawBalance.expiration)}",style: TextStyle(color: Colors.grey))
                  ],
                ),
              ),
              Positioned(
                  top: 0,
                  right: 0,
                  child: Text("${widget.withdrawBalance.status}",style: TextStyle(color: textStatusColor))),
            ],
          )
      ),
    );
  }
}
