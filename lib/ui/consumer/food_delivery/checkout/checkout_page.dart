import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../model/MenuItem.dart';
import '../../../utils.dart';
import '../cart/cart_page.dart';
import '../cart/cart_view_model.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String _selectedOrderType = 'kurir';
  final TextEditingController _noteController = TextEditingController();

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
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25.0, vertical: 10),
                      child: Column(
                        children: [
                          if(cartViewModel.selectedOrderType=="kurir")
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30.0, vertical: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Text("Alamat Pengiriman", style: TextStyle(
                                    fontSize: 16)),
                                Text("${cartViewModel.selectedAddress?.address} , ${cartViewModel.selectedAddress?.postalcode} , "
                                    "${cartViewModel.selectedAddress?.city}"),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: _noteController,
                                  decoration: const InputDecoration(
                                    hintText: "catatan tambahan",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10.0),
                                      ),
                                    ),
                                  ),
                                ),
                                const Divider(),
                              ],
                            ),
                          ),
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
                                    return AlaCarteCheckoutListTile(item: item);
                                  },
                                ),
                                ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: cartViewModel.paketCart.length,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    final paket = cartViewModel.paketCart[index];
                                    return PaketCheckoutListTile(paket: paket);
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
                                      Divider(),
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
                                                    formatCurrency(
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
                                                      formatCurrency(
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
                                          Text(formatCurrency(
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
                  onPressed: () async{
                    if(cartViewModel.checkCartStatus()){
                      if(cartViewModel.checkBalance()){
                        await cartViewModel.order(context, _selectedOrderType, _noteController.text.trim());
                      }else{
                        showCustomSnackBar(context, "saldo tidak mencukupi.", color: Colors.red);
                      }
                    }else{
                      showCustomSnackBar(context, "Ada item yang pada cart yang tidak tersedia.", color: Colors.red);
                    }
                  },
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
          if (cartViewModel.isLoading)
            Container(
              color: Colors.black.withOpacity(0.1),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            )
        ],
      ),
    );
  }
}


class AlaCarteCheckoutListTile extends StatefulWidget {
  final Product item;

  const AlaCarteCheckoutListTile({super.key, required this.item});

  @override
  State<AlaCarteCheckoutListTile> createState() => _AlaCarteCheckoutListTileState();
}

class _AlaCarteCheckoutListTileState extends State<AlaCarteCheckoutListTile> {
  final String placeholderImageUrl = 'images/placeholder_food.png';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 120,
                    height: 130,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10.0),
                      ),
                      child: widget.item.menuItem.photoUrl != null
                          ? Image.network(
                        widget.item.menuItem.photoUrl!,
                        fit: BoxFit.cover,
                      )
                          : Image.asset(
                        placeholderImageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          width: 125,
                          child: Text(
                            widget.item.menuItem.name,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(widget.item.menuItem.category),
                        Row(
                          children: [
                            Text(
                              formatCurrency(widget.item.menuItem.startPrice),
                              style: const TextStyle(
                                decoration: TextDecoration.lineThrough,
                                decorationThickness: 2,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(formatCurrency(
                                widget.item.menuItem.discountedPrice)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Text(
                    "${widget.item.quantity}x",
                    style: Theme.of(context).textTheme.bodyLarge!,
                  ),
                ]),
              ),
            ],
          ),
          if(widget.item.status==false)
            const Positioned(
                top: 10,
                right: 10,
                child: Text("tidak tersedia",style: TextStyle(color: Colors.red,fontSize: 13,fontWeight: FontWeight.bold))
            )
        ],
      ),
    );
  }
}

class PaketCheckoutListTile extends StatefulWidget {
  final Paket paket;

  const PaketCheckoutListTile({super.key, required this.paket});

  @override
  State<PaketCheckoutListTile> createState() => _PaketCheckoutListTileState();
}

class _PaketCheckoutListTileState extends State<PaketCheckoutListTile> {

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 5.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    widget.paket.name,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text(
                        formatCurrency(widget.paket.startPrice),
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          decorationThickness: 2,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(formatCurrency(widget.paket.discountedPrice)),
                    ],
                  ),
                ),
                ListView.builder(
                  itemCount: widget.paket.products.length,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    return PaketItemCheckoutListTile(
                        item: widget.paket.products[index]);
                  },
                ),

                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    Text(
                      "${widget.paket.quantity}x",
                      style: Theme.of(context).textTheme.bodyLarge!,
                    ),
                  ]),
                ),

              ],
            ),
            if(widget.paket.status==false)
              const Positioned(
                  top: 10,
                  right: 10,
                  child: Text("item tidak tersedia",style: TextStyle(color: Colors.red))
              )
          ],
        )
    );
  }
}

class PaketItemCheckoutListTile extends StatelessWidget {
  final Product item;
  final String placeholderImageUrl = 'images/placeholder_food.png';

  const PaketItemCheckoutListTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Stack(
        children: [
          Row(
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10.0),
                  ),
                  child: item.menuItem.photoUrl != null
                      ? Image.network(
                    item.menuItem.photoUrl!,
                    fit: BoxFit.cover,
                  )
                      : Image.asset(
                    placeholderImageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.menuItem.name,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(fontWeight: FontWeight.bold)),
                    Text(item.menuItem.category,
                        style: Theme.of(context).textTheme.bodyMedium!),
                  ],
                ),
              ),
            ],
          ),
          Positioned(top: 10, right: 10, child: Text("${item.quantity}x")),
        ],
      ),
    );
  }
}
