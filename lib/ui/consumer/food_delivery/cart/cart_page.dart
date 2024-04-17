import 'package:flutter/material.dart';
import 'package:greenneeds/ui/consumer/food_delivery/checkout/checkout_page.dart';
import 'package:provider/provider.dart';

import '../../../../model/MenuItem.dart';
import '../../../utils.dart';
import 'cart_view_model.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  String _selectedOrderType = 'kurir';

  @override
  void initState() {
    super.initState();
    final cartViewModel = Provider.of<CartViewModel>(context,listen: false);
    cartViewModel.checkCartItemAvailability();
    cartViewModel.getTotalCost();
    _selectedOrderType='kurir';
    cartViewModel.setSelectedOrderType(_selectedOrderType);
  }

  @override
  Widget build(BuildContext context) {
    final cartViewModel = Provider.of<CartViewModel>(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading:  IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("Keranjang"),
      ),
      body:
      cartViewModel.getAllItemsLength() > 0 ?
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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
            ),
          ),
          // Order Details
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 30,vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Jenis Pengiriman",style: TextStyle(fontSize: 16)),
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
                              cartViewModel.setSelectedOrderType(newValue);
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
                              cartViewModel.setSelectedOrderType(newValue);
                            });
                          },
                        ),
                        const Text('self pickup'),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("total harga:"),
                          Text(formatCurrency(cartViewModel.totalPrice)),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("biaya admin:"),
                          FutureBuilder(
                            future: cartViewModel.getTax(),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return Text("${snapshot.error}");
                              } else {
                                return Text(formatCurrency(cartViewModel.taxAmount));
                              }
                            },
                          ),
                        ],
                      ),
                      if (_selectedOrderType == "kurir")
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("ongkos kirim:"),
                            FutureBuilder(
                              future: cartViewModel.getCostPerKm(),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return Text("${snapshot.error}");
                                } else {
                                  return Text(formatCurrency(cartViewModel.costAmount));
                                }
                              },
                            ),
                          ],
                        ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("total pembayaran:"),
                          Text(formatCurrency(cartViewModel.totalPayment)),
                        ],
                      ),
                    ],
                  ),
                ),

                Container(
                  width: double.infinity,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: ElevatedButton(onPressed: ()async{
                      if(cartViewModel.checkCartStatus()){
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) =>
                                CheckoutPage()
                            )
                        );
                      }else{
                          showCustomSnackBar(context, "ada item yang pada cart yang tidak tersedia", color: Colors.red);
                      }
                    }, child: const Text("Order",style: TextStyle(fontWeight: FontWeight.bold)))
                )
              ],
            ),
          ),
        ],
      ) :SingleChildScrollView(
        child: Container(
          height: 500,
          child: const Center(child: Text("Tidak ada item dalam cart.")),
        ),
      )
    );
  }
}


class AlaCarteCartListTile extends StatefulWidget {
  final Product item;

  const AlaCarteCartListTile({super.key, required this.item});

  @override
  State<AlaCarteCartListTile> createState() => _AlaCarteCartListTileState();
}

class _AlaCarteCartListTileState extends State<AlaCarteCartListTile> {
  final String placeholderImageUrl = 'images/placeholder_food.png';

  @override
  Widget build(BuildContext context) {
    final cartViewModel = Provider.of<CartViewModel>(context);
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
                  TextButton(
                    onPressed: () async {
                      if(widget.item.quantity>=1){
                        cartViewModel.decreaseQuantityAlaCarte(widget.item.quantity, widget.item);
                      }
                    },
                    child: const Text("-"),
                  ),
                  Text(
                    "${widget.item.quantity}",
                    style: Theme.of(context).textTheme.bodyLarge!,
                  ),
                  TextButton(
                    onPressed: () async {
                      await cartViewModel.increaseQuantityAlaCarte(context,widget.item.quantity, widget.item);
                    },
                    child: const Text("+"),
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

class PaketCartListTile extends StatefulWidget {
  final Paket paket;

  const PaketCartListTile({super.key, required this.paket});

  @override
  State<PaketCartListTile> createState() => _PaketCartListTileState();
}

class _PaketCartListTileState extends State<PaketCartListTile> {
  int quantity = 0;

  @override
  Widget build(BuildContext context) {
    final cartViewModel = Provider.of<CartViewModel>(context);
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
                    return PaketItemCartListTile(
                        item: widget.paket.products[index]);
                  },
                ),

                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    TextButton(
                      onPressed: () async {
                        if(widget.paket.quantity>=1){
                          cartViewModel.decreaseQuantityPaket(widget.paket.quantity, widget.paket);
                        }
                      },
                      child: const Text("-"),
                    ),
                    Text(
                      "${widget.paket.quantity}",
                      style: Theme.of(context).textTheme.bodyLarge!,
                    ),
                    TextButton(
                      onPressed: () async {
                        await cartViewModel.increaseQuantityPaket(context,widget.paket.quantity, widget.paket);
                      },
                      child: const Text("+"),
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

class PaketItemCartListTile extends StatelessWidget {
  final Product item;
  final String placeholderImageUrl = 'images/placeholder_food.png';

  const PaketItemCartListTile({super.key, required this.item});

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
