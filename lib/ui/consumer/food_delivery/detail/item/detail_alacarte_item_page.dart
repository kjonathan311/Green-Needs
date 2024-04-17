import 'package:flutter/material.dart';
import 'package:greenneeds/model/MenuItem.dart';
import 'package:greenneeds/ui/consumer/food_delivery/detail/store/store_view_model.dart';
import 'package:greenneeds/ui/utils.dart';
import 'package:provider/provider.dart';

import '../../cart/cart_page.dart';
import '../../cart/cart_view_model.dart';

class DetailAlaCarteItemPage extends StatefulWidget {
  final Product item;
  final double distance;

  const DetailAlaCarteItemPage(
      {super.key, required this.item, required this.distance});

  @override
  State<DetailAlaCarteItemPage> createState() => _DetailAlaCarteItemPageState();
}

class _DetailAlaCarteItemPageState extends State<DetailAlaCarteItemPage> {
  final String placeholderImageUrl = 'images/placeholder_food.png';

  @override
  Widget build(BuildContext context) {
    final cartViewModel = Provider.of<CartViewModel>(context);
    final storeViewModel = Provider.of<StoreViewModel>(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("Detail Makanan"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
              child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 10),
              child: Column(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 300,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(10.0),
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        width: 200,
                        child: Text(
                          widget.item.menuItem.name,
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge!
                              .copyWith(fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(widget.item.menuItem.category,
                            style: Theme.of(context).textTheme.titleMedium!),
                      ),
                      Row(
                        children: [
                          Text(
                            formatCurrency(widget.item.menuItem.startPrice),
                            style: const TextStyle(
                              decoration: TextDecoration.lineThrough,
                              decorationThickness: 2,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                              formatCurrency(
                                  widget.item.menuItem.discountedPrice),
                              style: TextStyle(fontSize: 16)),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: widget.item.menuItem.description != null
                            ? Text(
                                widget.item.menuItem.description!,
                                style: Theme.of(context).textTheme.titleSmall!,
                              )
                            : SizedBox(),
                      )
                    ],
                  ),
                ],
              ),
            ),
          )),
          if (cartViewModel.checkItemInCart(widget.item.uid) == false)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15.0),
              child: ElevatedButton(
                onPressed: () {
                  cartViewModel.addAlaCarteItemToCart(
                      context,
                      storeViewModel.foodProviderProfile!,
                      widget.distance,
                      widget.item);
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white),
                child: Text(
                  "Pesan",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          if (cartViewModel.checkItemInCart(widget.item.uid) == true)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => CartPage()));
                },
                child: Text(
                  "Lihat Keranjang",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
