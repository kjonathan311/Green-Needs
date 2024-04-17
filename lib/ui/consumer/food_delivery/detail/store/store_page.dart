import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:greenneeds/model/SearchFoodProvider.dart';
import 'package:greenneeds/ui/consumer/food_delivery/cart/cart_page.dart';
import 'package:provider/provider.dart';
import '../../../../../model/MenuItem.dart';
import '../../../../../model/Profile.dart';
import '../../../../utils.dart';
import '../../cart/cart_view_model.dart';
import '../item/detail_alacarte_item_page.dart';
import 'store_view_model.dart';

class StorePage extends StatefulWidget {
  final SearchFoodProvider searchDetail;

  const StorePage({Key? key, required this.searchDetail}) : super(key: key);

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  late Future<List<Product>?> _alaCarteItems;
  late Future<List<Paket>?> _paketItems;
  late String _selectedItemType;

  @override
  void initState() {
    super.initState();
    _fetchItems();
    _selectedItemType = 'Menu';
  }

  void _fetchItems() {
    _alaCarteItems = Provider.of<StoreViewModel>(context, listen: false)
        .alaCarteItems(widget.searchDetail.uid);
    _paketItems = Provider.of<StoreViewModel>(context, listen: false)
        .paketItems(widget.searchDetail.uid);
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
        title: Text("Detail Penyedia Makanan", style: TextStyle(fontSize: 16)),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StoreHeader(searchDetail: widget.searchDetail),
                  Divider(thickness: 4, color: Color(0xFF8AAB97)),
                  Container(
                    width: 130,
                    margin: EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(20)),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: DropdownButtonFormField<String>(
                      value: _selectedItemType,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedItemType = newValue ?? 'Menu';
                          _fetchItems();
                        });
                      },
                      items: ['Menu', 'Paket'].map((String option) {
                        return DropdownMenuItem<String>(
                          value: option,
                          child: Text(option),
                        );
                      }).toList(),
                    ),
                  ),
                  if (_selectedItemType == "Menu")
                    FutureBuilder<List<Product>?>(
                      future: _alaCarteItems,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container(
                              height: 500,
                              child: Center(
                                child: CircularProgressIndicator(),
                              ));
                        } else if (snapshot.hasError) {
                          return Text('${snapshot.error}');
                        } else if (snapshot.hasData) {
                          List<Product> data = snapshot.data ?? [];
                          if (data.isEmpty) {
                            return Container(
                                height: 500,
                                child: Center(
                                  child: Text("Tidak tersedia makanan"),
                                ));
                          } else {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: snapshot.data!.length,
                                  itemBuilder: (context, index) {
                                    final product = snapshot.data![index];
                                    return GestureDetector(
                                      onTap: (){
                                        Navigator.of(context).push(
                                            MaterialPageRoute(builder: (context) =>
                                                DetailAlaCarteItemPage(
                                                  item: product,
                                                    distance: widget.searchDetail.distance
                                                ))
                                        );
                                      },
                                        child: AlaCarteStoreListTile(
                                            item: product,
                                            distance: widget.searchDetail.distance)
                                    );
                                  },
                                ),
                              ],
                            );
                          }
                        } else {
                          return Container(
                              height: 500,
                              child: Center(
                                child: Text("Tidak tersedia makanan"),
                              ));
                        }
                      },
                    ),
                  if (_selectedItemType == "Paket")
                    FutureBuilder<List<Paket>?>(
                      future: _paketItems,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container(
                              height: 500,
                              child: Center(
                                child: CircularProgressIndicator(),
                              ));
                        } else if (snapshot.hasError) {
                          return Text('${snapshot.error}');
                        } else if (snapshot.hasData) {
                          List<Paket> data = snapshot.data ?? [];
                          if (data.isEmpty) {
                            return Container(
                                height: 500,
                                child: Center(
                                  child: Text("Tidak tersedia makanan"),
                                ));
                          } else {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: snapshot.data!.length,
                                  itemBuilder: (context, index) {
                                    final paket = snapshot.data![index];
                                    return PaketListTile(paket: paket,distance: widget.searchDetail.distance);
                                  },
                                ),
                              ],
                            );
                          }
                        } else {
                          return Container(
                              height: 500,
                              child: Center(
                                child: Text("Tidak tersedia Makanan"),
                              ));
                        }
                      },
                    ),
                  const SizedBox(height: 100)
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: cartViewModel.getAllItemsLength() > 0
          ? Container(
              margin: const EdgeInsets.all(20.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => CartPage()));
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: CupertinoColors.systemGreen),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text("${cartViewModel.currentFoodProvider?.name}",
                            style: TextStyle(
                                color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                      Row(
                        children: [
                          Text("${cartViewModel.getAllItemsLength()} items", style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold)),
                          SizedBox(width: 10),
                          Icon(Icons.shopping_cart,color: Colors.white)
                        ],
                      )
                    ],
                  ),
                ),
              ),
            )
          : null,
    );
  }
}

class StoreHeader extends StatelessWidget {
  final SearchFoodProvider searchDetail;
  final String placeholderImageUrl = 'images/placeholder_food.png';

  const StoreHeader({super.key, required this.searchDetail});

  @override
  Widget build(BuildContext context) {
    final storeViewModel = Provider.of<StoreViewModel>(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: FutureBuilder(
        future: storeViewModel.foodProviderDetails(searchDetail.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              height: 100,
                child: Center(
              child: CircularProgressIndicator(),
            ));
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          } else if (snapshot.hasData) {
            FoodProviderProfile? profile = snapshot.data;
            return Stack(
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20.0),
                        child: profile!.photoUrl != null
                            ? Image.network(
                                profile!.photoUrl!,
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                placeholderImageUrl,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 170,
                              child: Text(
                                profile.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1!
                                    .copyWith(fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                                maxLines: 1,
                              ),
                            ),
                            Container(
                              width: 170,
                              child: Text(
                                "${profile.address}",
                                style: Theme.of(context).textTheme.bodyText2!,
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                                maxLines: 2,
                              ),
                            ),
                            Text("${profile.phoneNumber}",
                                style: Theme.of(context).textTheme.bodyMedium),
                            Text("${searchDetail.distance} km",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(color: Colors.grey)),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: EdgeInsets.all(6),
                    child: Row(
                      children: [
                        Icon(Icons.star, color: Colors.orange),
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            profile.rating != null
                                ? "${profile.rating}"
                                : "0.0",
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else {
            return Center(child: Text('Error ambil profil'));
          }
        },
      ),
    );
  }
}

class AlaCarteStoreListTile extends StatelessWidget {
  final Product item;
  final double distance;

  const AlaCarteStoreListTile({super.key, required this.item, required this.distance});

  final String placeholderImageUrl = 'images/placeholder_food.png';

  @override
  Widget build(BuildContext context) {
    final cartViewModel = Provider.of<CartViewModel>(context);
    final storeViewModel = Provider.of<StoreViewModel>(context);

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
                    height: 145,
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
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 5),
                          width: 125,
                          child: Text(
                            item.menuItem.name,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(item.menuItem.category),
                        Row(
                          children: [
                            Text(
                              formatCurrency(item.menuItem.startPrice),
                              style: TextStyle(
                                decoration: TextDecoration.lineThrough,
                                decorationThickness: 2,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(width: 5),
                            Text(formatCurrency(
                                item.menuItem.discountedPrice)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (cartViewModel.checkItemInCart(item.uid) ==
                  false)
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: ElevatedButton(
                      onPressed: () {
                        cartViewModel.addAlaCarteItemToCart(context,
                            storeViewModel.foodProviderProfile!,
                            distance,
                            item);
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
                ),
              if (cartViewModel.checkItemInCart(item.uid) ==
                  true)
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
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
                )
            ],
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Text(
              "${item.quantity} tersedia",
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }
}

class PaketListTile extends StatelessWidget {
  final Paket paket;
  final double distance;
  PaketListTile({super.key, required this.paket, required this.distance});

  int quantity = 0;

  @override
  Widget build(BuildContext context) {
    final cartViewModel = Provider.of<CartViewModel>(context);
    final storeViewModel = Provider.of<StoreViewModel>(context);

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
                    paket.name,
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
                        formatCurrency(paket.startPrice),
                        style: TextStyle(
                          decoration: TextDecoration.lineThrough,
                          decorationThickness: 2,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(formatCurrency(paket.discountedPrice)),
                    ],
                  ),
                ),
                ListView.builder(
                  itemCount: paket.products.length,
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    return PaketItemListTile(
                        item: paket.products[index]);
                  },
                ),
                if (cartViewModel.checkItemInCart(paket.uid) == false)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: ElevatedButton(
                        onPressed: () {
                          cartViewModel.addPaketToCart(
                              context,
                              storeViewModel.foodProviderProfile!,
                              distance,
                              paket);
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
                  ),
                if (cartViewModel.checkItemInCart(paket.uid) == true)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
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
                  )
              ],
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Text(
                "${paket.quantity} tersedia",
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.green),
              ),
            ),
          ],
        ));
  }
}

class PaketItemListTile extends StatelessWidget {
  final Product item;
  final String placeholderImageUrl = 'images/placeholder_food.png';

  const PaketItemListTile({super.key, required this.item});

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
