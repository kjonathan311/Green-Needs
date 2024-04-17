
import 'package:flutter/material.dart';
import 'package:greenneeds/ui/consumer/balance/add_balance_view_model.dart';

import 'package:greenneeds/ui/consumer/balance/payment_page.dart';
import 'package:greenneeds/ui/consumer/profile/consumer_profile_view_model.dart';
import 'package:greenneeds/ui/utils.dart';
import 'package:provider/provider.dart';

class AddBalancePage extends StatefulWidget {
  const AddBalancePage({super.key});

  @override
  State<AddBalancePage> createState() => _AddBalancePageState();
}

class _AddBalancePageState extends State<AddBalancePage> {
  @override
  Widget build(BuildContext context) {
    final balanceViewModel = Provider.of<AddBalanceViewModel>(context);
    final consumerViewModel = Provider.of<ConsumerProfileViewModel>(context);
    final TextEditingController _balanceController = TextEditingController();

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
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 25.0, vertical: 10),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment
                          .spaceBetween,
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
                              int balance = snapshot.data as int;
                              return Text("${formatCurrency(balance)}");
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  TextField(
                    controller: _balanceController,
                    decoration: const InputDecoration(
                      hintText: "Tambah Saldo",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 10),
                      child: const Text("Tambah saldo minimal Rp 10.000.")
                  ),
                  Container(
                    width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: ElevatedButton(onPressed: ()async{
                        if(_balanceController.text.isNotEmpty){
                        var url=await balanceViewModel.getInvoice(context,consumerViewModel.consumerProfile!,int.parse(_balanceController.text.trim()));
                        if(url!=null){;
                        await Navigator.of(context).push(MaterialPageRoute(builder: (context) => PaymentPage(url: url)));
                        }
                        }else{
                          showCustomSnackBar(context, "field harus diisi.", color: Colors.red);
                        }
                      }, child: Text("Tambah Saldo"))
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
      )
    )
    ;
  }
}
