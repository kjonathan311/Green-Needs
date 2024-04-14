import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../../../model/MenuItem.dart';
import '../../../utils.dart';
import 'CartViewModel.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    final cartViewModel = Provider.of<CartViewModel>(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading:  IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("Keranjang"),
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
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final item = cartViewModel.alaCarteCart[index];
                        return AlaCarteCartListTile(item: item);
                      },
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: cartViewModel.paketCart.length,
                      physics: NeverScrollableScrollPhysics(),
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
          //Order Buy
          Container(
            padding: EdgeInsets.symmetric(horizontal: 30,vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white, // You might want to set a background color for the card
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3), // Adjust the shadow color and opacity
                  spreadRadius: 2, // Adjust the spread radius
                  blurRadius: 5, // Adjust the blur radius
                  offset: Offset(0, 2), // Adjust the offset
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
                        Text('kurir'),
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
                        Text('self pick up'),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
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
                          Text("total harga:"),
                          Text(formatCurrency(cartViewModel.totalPrice)),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("biaya admin:"),
                          FutureBuilder(
                            future: cartViewModel.getTax(),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return Text("${snapshot.error}");
                              } else {
                                return Text(formatCurrencyWithDouble(cartViewModel.taxAmount));
                              }
                            },
                          ),
                        ],
                      ),
                      if (_selectedOrderType == "kurir")
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("ongkos kirim:"),
                            FutureBuilder(
                              future: cartViewModel.getCostPerKm(),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return Text("${snapshot.error}");
                                } else {
                                  return Text(formatCurrencyWithDouble(cartViewModel.costAmount));
                                }
                              },
                            ),
                          ],
                        ),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("total pembayaran:"),
                          Text(formatCurrencyWithDouble(cartViewModel.totalPayment)),
                        ],
                      ),
                    ],
                  ),
                ),

                Container(
                  width: double.infinity,
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: ElevatedButton(onPressed: (){}, child: const Text("Order",style: TextStyle(fontWeight: FontWeight.bold)))
                )
              ],
            ),
          ),
        ],
      ) :SingleChildScrollView(
        child: Container(
          height: 500,
          child: Center(child: Text("Tidak ada item dalam cart.")),
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
      margin: EdgeInsets.symmetric(vertical: 10.0),
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
                      borderRadius: BorderRadius.only(
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
                          padding: EdgeInsets.symmetric(vertical: 5),
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
                              style: TextStyle(
                                decoration: TextDecoration.lineThrough,
                                decorationThickness: 2,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(width: 5),
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
                    child: Text("-"),
                  ),
                  Text(
                    "${widget.item.quantity}",
                    style: Theme.of(context).textTheme.bodyLarge!,
                  ),
                  TextButton(
                    onPressed: () async {
                      await cartViewModel.increaseQuantityAlaCarte(context,widget.item.quantity, widget.item);
                    },
                    child: Text("+"),
                  ),
                ]),
              ),
            ],
          ),
          if(widget.item.status==false)
          Positioned(
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
        margin: EdgeInsets.symmetric(vertical: 5.0),
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
                        style: TextStyle(
                          decoration: TextDecoration.lineThrough,
                          decorationThickness: 2,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(formatCurrency(widget.paket.discountedPrice)),
                    ],
                  ),
                ),
                ListView.builder(
                  itemCount: widget.paket.products.length,
                  physics: NeverScrollableScrollPhysics(),
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
                      child: Text("-"),
                    ),
                    Text(
                      "${widget.paket.quantity}",
                      style: Theme.of(context).textTheme.bodyLarge!,
                    ),
                    TextButton(
                      onPressed: () async {
                        await cartViewModel.increaseQuantityPaket(context,widget.paket.quantity, widget.paket);
                      },
                      child: Text("+"),
                    ),
                  ]),
                ),

              ],
            ),
            if(widget.paket.status==false)
              Positioned(
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
      margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
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
                  borderRadius: BorderRadius.only(
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
