import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../../model/MenuItem.dart';
import '../../utils.dart';
import '../profile/FoodProviderProfilePopUpWindow.dart';
import 'DailyWastePageViewModel.dart';

class DailyWastePage extends StatefulWidget {
  const DailyWastePage({super.key});

  @override
  State<DailyWastePage> createState() => _DailyWastePageState();
}

class _DailyWastePageState extends State<DailyWastePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Menu"),
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
                Tab(text: "Ala Carte"),
                Tab(text: "Paket"),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  AlaCarteLayout(),
                  PacketLayout(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AlaCarteLayout extends StatefulWidget {
  const AlaCarteLayout({super.key});

  @override
  State<AlaCarteLayout> createState() => _AlaCarteLayoutState();
}

class _AlaCarteLayoutState extends State<AlaCarteLayout> {

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<DailyWastePageViewModel>(context);

    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: StreamBuilder<List<Product>>(
                  stream: viewModel.alaCarteItems(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Container(
                        height: 100,
                        child: Center(
                          child: Text('Error: ${snapshot.error}'),
                        ),
                      );
                    } else if (!snapshot.hasData) {
                      return Container(
                        height: 500,
                        child: Center(
                          child: Text('Loading..'),
                        ),
                      );
                    } else {
                      List<Product>? items = snapshot.data;
                      if (items == null || items.isEmpty) {
                        return Container(
                          height: 500,
                          child: Center(
                            child: Text('Tidak ada item.'),
                          ),
                        );
                      } else {
                        return ListView.builder(
                          itemCount: items.length,
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder:
                              (BuildContext context, int index) {
                            return AlaCarteListTile(
                                item: items[index]
                            );
                          },
                        );
                      }
                    }
                  },
                ),
                ),
            ],
          ),
        ),
        Positioned(
          bottom: 32.0,
          right: 32.0,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(context, "/provider/daily/add");
            },
            child: Icon(Icons.add),
            backgroundColor: Colors.grey,
          ),
        ),
      ],
    );
  }
}

class PacketLayout extends StatefulWidget {
  const PacketLayout({super.key});

  @override
  State<PacketLayout> createState() => _PacketLayoutState();
}

class _PacketLayoutState extends State<PacketLayout> {
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<DailyWastePageViewModel>(context);
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: StreamBuilder<List<Paket>>(
                  stream: viewModel.PaketItems(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Container(
                        height: 100,
                        child: Center(
                          child: Text('Error: ${snapshot.error}'),
                        ),
                      );
                    } else if (!snapshot.hasData) {
                      return Container(
                        height: 500,
                        child: Center(
                          child: Text('Loading..'),
                        ),
                      );
                    } else {
                      List<Paket>? pakets = snapshot.data;
                      if (pakets == null || pakets.isEmpty) {
                        return Container(
                          height: 500,
                          child: Center(
                            child: Text('Tidak ada item.'),
                          ),
                        );
                      } else {
                        return ListView.builder(
                          itemCount: pakets.length,
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder:
                              (BuildContext context, int index) {
                            return PaketListTile(
                                paket: pakets[index]
                            );
                          },
                        );
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 32.0,
          right: 32.0,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(context, "/provider/daily/add");
            },
            child: Icon(Icons.add),
            backgroundColor: Colors.grey,
          ),
        ),
      ],
    );
  }
}

class AlaCarteListTile extends StatefulWidget {
  final Product item;
  final String placeholderImageUrl = 'images/placeholder_food.png';

  const AlaCarteListTile({super.key, required this.item});

  @override
  State<AlaCarteListTile> createState() => _AlaCarteListTileState();
}

class _AlaCarteListTileState extends State<AlaCarteListTile> {
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<DailyWastePageViewModel>(context);
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                      child: widget.item.menuItem.photoUrl != null
                          ? Image.network(
                        widget.item.menuItem.photoUrl!,
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              widget.placeholderImageUrl,
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
                          Text(
                            widget.item.menuItem.name,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(widget.item.menuItem.category),
                          Row(
                            children: [
                              Text(
                                formatCurrency(widget.item.menuItem.startPrice),
                                style: TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  decorationThickness: 2,
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(formatCurrency(widget.item.menuItem.discountedPrice)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                height: 1.0,
                color: Color(0xFF8AAB97),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text("Jumlah"),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () async {
                          if(widget.item.quantity>=1){
                            await viewModel.decreaseQuantity(widget.item.menuItem.uid, widget.item.quantity);
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
                          await viewModel.increaseQuantity(widget.item.menuItem.uid, widget.item.quantity);
                        },
                        child: Text("+"),
                      ),
                    ],
                  )
                ],
              )
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              onPressed: () async{
                await viewModel.deleteItem(widget.item.menuItem.uid);
              },
              icon: Icon(Icons.close),
            ),
          ),
        ],
      ),
    );
  }
}

class PaketListTile extends StatefulWidget {
  final Paket paket;
  const PaketListTile({super.key, required this.paket});

  @override
  State<PaketListTile> createState() => _PaketListTileState();
}

class _PaketListTileState extends State<PaketListTile> {
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<DailyWastePageViewModel>(context);
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
                SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.all(8.0),
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
                  child:Text(formatCurrency(widget.paket.price)),
                ),
                Divider(color: Color(0xFF8AAB97)),
                ListView.builder(
                  itemCount: widget.paket.products.length,
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder:
                      (BuildContext context, int index) {
                    return PaketItemListTile(
                        item: widget.paket.products[index]
                    );
                  },
                ),
                Divider(color: Color(0xFF8AAB97)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text("Jumlah"),
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () async {
                            if(widget.paket.quantity>=1){
                              await viewModel.decreaseQuantity(widget.paket.uid, widget.paket.quantity);
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
                            await viewModel.increaseQuantity(widget.paket.uid, widget.paket.quantity);
                          },
                          child: Text("+"),
                        ),
                      ],
                    )
                  ],
                )
              ],
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                onPressed: () {},
                icon: Icon(Icons.close),
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
                    Text(item.menuItem.name, style: Theme.of(context).textTheme.bodyMedium!),
                    Text(item.menuItem.category,
                        style: Theme.of(context).textTheme.bodyMedium!),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
              top: 10,
              right: 10,
              child: Text("${item.quantity}x")
          ),
        ],
      ),
    );
  }
}
