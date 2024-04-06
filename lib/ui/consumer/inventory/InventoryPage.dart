import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:greenneeds/model/InventoryItem.dart';
import 'package:greenneeds/ui/consumer/inventory/InventoryViewModel.dart';
import 'package:greenneeds/ui/consumer/inventory/item/detail/DetailInventoryItemPage.dart';
import 'package:greenneeds/ui/consumer/inventory/notification/InventoryNotificationPopUpWindow.dart';
import 'package:greenneeds/ui/consumer/profile/ConsumerProfilePopUpWindow.dart';
import 'package:greenneeds/ui/utils.dart';
import 'package:provider/provider.dart';

import '../../../model/NotificationService.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late StreamController<String> _selectedCategoryController;
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 0, vsync: this);
    _selectedCategoryController = StreamController<String>();
    _selectedCategory = '';
  }


  @override
  void dispose() {
    _selectedCategoryController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<InventoryViewModel>(context);

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      viewModel.notifyNearingExpiration();
      viewModel.subscribeToFirestoreChanges();
    });

    return Scaffold(
      appBar: AppBar(
        leading: PopupMenuButton(
          icon: Icon(Icons.settings),
          itemBuilder: (BuildContext context) {
            return [
              PopupMenuItem(
                value: 'option1',
                child: Text('Kategori'),
                onTap: () {
                  Navigator.pushNamed(context, "/consumer/inventory/category");
                },
              ),
              PopupMenuItem(
                value: 'option2',
                child: Text('Notifikasi'),
                onTap: () async{

                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return const InventoryNotificationPopUpWindow();
                      });
                },
              ),
            ];
          },
          onSelected: (value) {
            print('Selected: $value');
          },
        ),
        title: Text("Inventori"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_2),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const ConsumerProfilePopUpWindow();
                  });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            InventoryHeader(),
            const SizedBox(height: 10.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Row(
                children: [
                  Expanded(
                    child: StreamBuilder<List<String>>(
                      stream: viewModel.categoriesStream(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Container();
                        } else if (snapshot.hasError) {
                          return Text("Error: ${snapshot.error}");
                        } else {
                          List<String> categories = snapshot.data ?? ["Semua item", 'tidak dikategorikan'];
                          if (_tabController.length != categories.length) {
                            _tabController = TabController(
                              length: categories.length,
                              vsync: this,
                              initialIndex: _tabController.index,
                            );
                          }
                          if (_selectedCategory.isEmpty) {
                            _selectedCategory = categories.first;
                            _selectedCategoryController.add(_selectedCategory);
                          }
                          print("Selected category: $_selectedCategory");
                          return TabBar(
                            isScrollable: true,
                            controller: _tabController,
                            tabs: categories
                                .map((category) => Tab(text: category))
                                .toList(),
                            onTap: (index) {
                              setState(() {
                                _selectedCategory = categories[index];
                                _selectedCategoryController.add(_selectedCategory);
                              });
                            },
                          );
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 20.0),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, "/consumer/inventory/add");
                      },
                      child: Icon(Icons.add)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: StreamBuilder<String>(
                stream: _selectedCategoryController.stream,
                builder: (context, snapshotCategory) {
                  if (snapshotCategory.hasData && snapshotCategory.data != null) {
                    return StreamBuilder<List<InventoryItem>>(
                      stream: viewModel.inventoryItems(snapshotCategory.data!),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Container(
                            height: 100,
                            child: Center(
                              child: Text('Error: ${snapshot.error}'),
                            ),
                          );
                        } else {
                          List<InventoryItem>? items = snapshot.data;
                          if (snapshot.connectionState == ConnectionState.waiting || snapshot.hasError) {
                            return Container(
                              height: 500,
                              child: Center(
                                child: Text('Loading..'),
                              ),
                            );
                          }else if (items == null || items.isEmpty) {
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
                              itemBuilder: (BuildContext context, int index) {
                                return
                                  GestureDetector(
                                    onTap: (){
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => DetailInventoryItemPage(
                                            item: items[index],
                                          ),
                                        ),
                                      );
                                      },
                                    child:  InventoryListTile(
                                        uid: items[index].uid,
                                        name: items[index].name,
                                        category: items[index].category,
                                        expiration_date: items[index].expirationDate,
                                        quantity: items[index].quantity,
                                  )
                                );
                              },
                            );
                          }
                        }
                      },
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class InventoryHeader extends StatelessWidget {
  const InventoryHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<InventoryViewModel>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 10.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
              decoration: BoxDecoration(
                color: Color(0xFF8AAB97),
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Align(
                alignment: Alignment.center,
                child:
                StreamBuilder<int>(
                  stream: viewModel.itemCountStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      int itemCount = snapshot.data!;
                      return Text(
                        "${itemCount} items",
                        style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            overflow: TextOverflow.ellipsis),
                      );
                    } else{
                      return Text(
                        "0 items",
                        style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            overflow: TextOverflow.ellipsis),
                      );
                    }
                  },
                ),
              ),
            ),
          ),
          SizedBox(width: 10.0),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
              decoration: BoxDecoration(
                color: Color(0xFF7A779E),
                borderRadius: BorderRadius.circular(20.0),
              ),
              child:Align(
                alignment: Alignment.center,
                child: StreamBuilder<int>(
                  stream: viewModel.nearingExpirationItemCountStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      int itemCount = snapshot.data!;
                      return Text(
                        "${itemCount} near exp",
                        style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            overflow: TextOverflow.ellipsis),
                      );
                    } else{
                      return Text(
                        "0 near exp",
                        style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            overflow: TextOverflow.ellipsis),
                      );
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class InventoryListTile extends StatefulWidget {
  final String uid;
  final String name;
  final String category;
  final DateTime expiration_date;
  final int quantity;

  const InventoryListTile(
      {super.key,
        required this.uid,
      required this.name,
      required this.category,
      required this.expiration_date,
      required this.quantity});

  @override
  State<InventoryListTile> createState() => _InventoryListTileState();
}

class _InventoryListTileState extends State<InventoryListTile> {
  DateTime DateNow = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<InventoryViewModel>(context);
    bool isExpired = widget.expiration_date.isBefore(DateNow);
    bool isNearExpiration = viewModel.isExpirationNear(widget.expiration_date);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        children: [
          SizedBox(height: 10.0),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.name,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .copyWith(fontWeight: FontWeight.bold)),
                    Text(widget.category),
                  ],
                ),

                Text(
                  isExpired ? "Expired" : "exp.\n${formatDateWithMonth(widget.expiration_date)}",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: isExpired ? Colors.red : isNearExpiration ? Colors.orange : null,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFF8AAB97)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text("Jumlah"),
              ),
              Row(
                children: [
                  TextButton(onPressed: () async{
                    if(widget.quantity>=1){
                      await viewModel.decreaseQuantity(widget.uid, widget.quantity);
                    }
                  }, child: Text("-")),
                  Text("${widget.quantity}",
                      style: Theme.of(context).textTheme.bodyLarge!),
                  TextButton(onPressed: () async{
                    await viewModel.increaseQuantity(widget.uid, widget.quantity);
                  }, child: Text("+")),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
