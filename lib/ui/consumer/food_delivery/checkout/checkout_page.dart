import 'package:flutter/material.dart';
import 'package:greenneeds/ui/consumer/food_delivery/cart/CartViewModel.dart';
import 'package:provider/provider.dart';

import '../../../utils.dart';
import '../cart/cart_page.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String _selectedOrderType = 'kurir';

  @override
  void initState() {
    super.initState();
    final cartViewModel = Provider.of<CartViewModel>(context, listen: false);
    cartViewModel.checkCartItemAvailability();
    cartViewModel.getTotalCost();
    _selectedOrderType = cartViewModel.selectedOrderType;
  }

  @override
  Widget build(BuildContext context) {
    final cartViewModel = Provider.of<CartViewModel>(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("Checkout"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 25.0, vertical: 10),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30.0, vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text("Alamat Pengiriman", style: TextStyle(
                                fontSize: 16)),
                            Text("${cartViewModel.selectedAddress?.address} , ${cartViewModel.selectedAddress?.postalcode} , "
                                "${cartViewModel.selectedAddress?.city}")
                          ],
                        ),
                      ),
                      const Divider(),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 20),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 10),
                        child:Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Daftar Pesanan", style: TextStyle(
                                fontSize: 16)),
                            ListView.builder(
                              shrinkWrap: true,
                              itemCount: cartViewModel.alaCarteCart.length,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                final item = cartViewModel.alaCarteCart[index];
                                return AlaCarteCartListTile(item: item);
                              },
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              itemCount: cartViewModel.paketCart.length,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                final paket = cartViewModel.paketCart[index];
                                return PaketCartListTile(paket: paket);
                              },
                            ),
                          ],
                        ),
                      ),
                      const Divider(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Jenis Pengiriman", style: TextStyle(
                                fontSize: 16)),
                            Row(
                              children: [
                                Row(
                                  children: [
                                    Radio(
                                      value: 'kurir',
                                      groupValue: _selectedOrderType,
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          _selectedOrderType = newValue!;
                                          cartViewModel.setSelectedOrderType(
                                              newValue);
                                        });
                                      },
                                    ),
                                    const Text('kurir'),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Radio(
                                      value: 'self pick up',
                                      groupValue: _selectedOrderType,
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          _selectedOrderType = newValue!;
                                          cartViewModel.setSelectedOrderType(
                                              newValue);
                                        });
                                      },
                                    ),
                                    const Text('self pick up'),
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment
                                        .spaceBetween,
                                    children: [
                                      const Text("saldo:"),
                                      FutureBuilder(
                                        future: cartViewModel.getBalance(),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasError) {
                                            return Text("${snapshot.error}");
                                          } else {
                                            return Text(formatCurrency(
                                                cartViewModel.balance));
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment
                                        .spaceBetween,
                                    children: [
                                      const Text("total harga:"),
                                      Text(formatCurrency(
                                          cartViewModel.totalPrice)),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment
                                        .spaceBetween,
                                    children: [
                                      const Text("biaya admin:"),
                                      FutureBuilder(
                                        future: cartViewModel.getTax(),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasError) {
                                            return Text("${snapshot.error}");
                                          } else {
                                            return Text(
                                                formatCurrencyWithDouble(
                                                    cartViewModel.taxAmount));
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                  if (_selectedOrderType == "kurir")
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment
                                          .spaceBetween,
                                      children: [
                                        const Text("ongkos kirim:"),
                                        FutureBuilder(
                                          future: cartViewModel.getCostPerKm(),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasError) {
                                              return Text("${snapshot.error}");
                                            } else {
                                              return Text(
                                                  formatCurrencyWithDouble(
                                                      cartViewModel
                                                          .costAmount));
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  const Divider(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment
                                        .spaceBetween,
                                    children: [
                                      const Text("total pembayaran:"),
                                      Text(formatCurrencyWithDouble(
                                          cartViewModel.totalPayment)),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                          ],
                        ),
                      )

                    ],
                  ),
                ),
              )
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15.0),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white),
              child: Text(
                "Bayar",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
