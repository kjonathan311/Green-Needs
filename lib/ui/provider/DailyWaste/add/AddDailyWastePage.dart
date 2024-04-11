import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:greenneeds/ui/provider/DailyWaste/add/AddDailyWasteViewModel.dart';
import 'package:greenneeds/ui/utils.dart';
import 'package:provider/provider.dart';

import '../../../../model/MenuItem.dart';

class AddDailyWastePage extends StatefulWidget {
  const AddDailyWastePage({Key? key}) : super(key: key);

  @override
  State<AddDailyWastePage> createState() => _AddDailyWastePageState();
}

class _AddDailyWastePageState extends State<AddDailyWastePage> {
  String _selectedType = 'ala carte';
  List<MenuItem> selectedItems = [];
  Map<String, int> itemQuantities = {};
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  int totalPrice = 0;
  int totalDiscountPrice = 0;
  int quantityPaket = 0;

  void handleQuantityChanged(String itemId, int quantity) {
    itemQuantities[itemId] = quantity;
  }

  void calculateTotalPrice() {
    List<Product> products = [];
    selectedItems.forEach((element) {
      if (itemQuantities[element.uid] != null) {
        int count=0;
        if(itemQuantities[element.uid]==0){
          count=1;
        }else{
          count=itemQuantities[element.uid]!;
        }
        Product product = Product(
            menuItem: element,
            quantity: count);
        products.add(product);
      } else {
        Product product = Product(menuItem: element, quantity: 1);
        products.add(product);
      }
    });

    totalPrice = products.fold<int>(
        0, (previousValue, element) => previousValue + (element.menuItem.startPrice*element.quantity));
    totalDiscountPrice = products.fold<int>(
        0, (previousValue, element) => previousValue + (element.menuItem.discountedPrice*element.quantity));
  }

  void _incrementQuantity() {
    setState(() {
      quantityPaket++;
    });
  }

  void _decrementQuantity() {
    setState(() {
      if (quantityPaket >= 1) {
        quantityPaket--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AddDailyWastePageViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("Tambah item"),
        actions: [
          IconButton(
            onPressed: () async {
              List<Product> products = [];
              selectedItems.forEach((element) {
                if (itemQuantities[element.uid] != null) {
                  Product product = Product(
                      menuItem: element,
                      quantity: itemQuantities[element.uid]!);
                  products.add(product);
                } else {
                  Product product = Product(menuItem: element, quantity: 0);
                  products.add(product);
                }
              });
              if (_selectedType == "ala carte") {
                await viewModel.addAlaCarteProducts(context, products);
              } else {
                await viewModel.addPaketProduct(
                    context,
                    _nameController.text.trim(),
                    quantityPaket,
                    _priceController.text.trim(),
                    products);
              }
            },
            icon: Icon(Icons.add),
          )
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        children: [
                          Radio(
                            value: 'ala carte',
                            groupValue: _selectedType,
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedType = newValue!;
                                selectedItems = [];
                                totalPrice = 0;
                                totalDiscountPrice = 0;
                                itemQuantities = {};
                                quantityPaket = 1;
                              });
                            },
                          ),
                          Text('ala carte'),
                        ],
                      ),
                      Row(
                        children: [
                          Radio(
                            value: 'paket',
                            groupValue: _selectedType,
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedType = newValue!;
                                selectedItems = [];
                                totalPrice = 0;
                                totalDiscountPrice = 0;
                                itemQuantities = {};
                                quantityPaket = 1;
                              });
                            },
                          ),
                          Text('paket'),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 10.0),
                  if (_selectedType == 'paket')
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10.0),
                        Text("nama paket",
                            style: Theme.of(context).textTheme.bodyText1),
                        SizedBox(height: 5.0),
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            hintText: "nama paket",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10.0),
                        Text("Jumlah",
                            style: Theme.of(context).textTheme.bodyLarge),
                        SizedBox(height: 5.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                border: Border.all(color: Colors.black),
                              ),
                              child: IconButton(
                                icon: Icon(Icons.remove),
                                onPressed: _decrementQuantity,
                              ),
                            ),
                            SizedBox(width: 3),
                            Expanded(
                              child: SizedBox(
                                width: 20.0,
                                child: TextFormField(
                                  readOnly: true,
                                  textAlign: TextAlign.center,
                                  decoration: const InputDecoration(
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 8.0),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10.0),
                                      ),
                                    ),
                                  ),
                                  controller: TextEditingController(
                                      text: quantityPaket.toString()),
                                ),
                              ),
                            ),
                            SizedBox(width: 3),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                border: Border.all(color: Colors.black),
                              ),
                              child: IconButton(
                                icon: Icon(Icons.add),
                                onPressed: _incrementQuantity,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.0),
                        Text("harga paket",
                            style: Theme.of(context).textTheme.bodyText1),
                        SizedBox(height: 5.0),
                        TextField(
                          controller: _priceController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                            ),
                            hintText: "0",
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: 10.0),
                        Text(
                            "total harga awal     : ${formatCurrency(totalPrice)}",
                            style: Theme.of(context).textTheme.bodyText2),
                        Text(
                            "total harga diskon   : ${formatCurrency(totalDiscountPrice)}",
                            style: Theme.of(context).textTheme.bodyText2),
                        SizedBox(height: 10.0),
                        Text("items",
                            style: Theme.of(context).textTheme.bodyText1),
                        SizedBox(height: 5.0),
                        StreamBuilder<List<MenuItem>>(
                          stream: viewModel.menuItems(),
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
                              List<MenuItem>? items = snapshot.data;
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
                                    return MenuCheckListTile(
                                      key: ValueKey(items[index].uid),
                                      item: items[index],
                                      onCheckboxChanged: (isSelected) {
                                        setState(() {
                                          if (isSelected!) {
                                            if (!selectedItems
                                                .contains(items[index])) {
                                              selectedItems.add(items[index]);
                                            }
                                          } else {
                                            selectedItems.removeWhere((item) =>
                                                item.uid == items[index].uid);
                                          }
                                          calculateTotalPrice();
                                        });
                                      },
                                      onQuantityChanged: (quantity) {
                                        setState(() {
                                          handleQuantityChanged(
                                              items[index].uid, quantity);
                                          calculateTotalPrice();
                                        });
                                      },
                                    );
                                  },
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  if (_selectedType == 'ala carte')
                    StreamBuilder<List<MenuItem>>(
                      stream: viewModel.menuItems(),
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
                          List<MenuItem>? items = snapshot.data;
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
                              itemBuilder: (BuildContext context, int index) {
                                return MenuCheckListTile(
                                  key: ValueKey(items[index].uid),
                                  item: items[index],
                                  onCheckboxChanged: (isSelected) {
                                    setState(() {
                                      if (isSelected!) {
                                        if (!selectedItems
                                            .contains(items[index])) {
                                          selectedItems.add(items[index]);
                                        }
                                      } else {
                                        selectedItems.removeWhere((item) =>
                                            item.uid == items[index].uid);
                                      }
                                    });
                                  },
                                  onQuantityChanged: (quantity) {
                                      handleQuantityChanged(
                                          items[index].uid, quantity);
                                  },
                                );
                              },
                            );
                          }
                        }
                      },
                    ),
                ],
              ),
            ),
          ),
          if (viewModel.isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            )
        ],
      ),
    );
  }
}

class MenuCheckListTile extends StatefulWidget {
  final MenuItem item;
  final ValueChanged<bool?> onCheckboxChanged;
  final ValueChanged<int> onQuantityChanged;

  const MenuCheckListTile({
    Key? key,
    required this.item,
    required this.onCheckboxChanged,
    required this.onQuantityChanged,
  }) : super(key: key);

  @override
  _MenuCheckListTileState createState() => _MenuCheckListTileState();
}

class _MenuCheckListTileState extends State<MenuCheckListTile> {
  late bool _isSelected;
  int quantity = 0;

  @override
  void initState() {
    super.initState();
    _isSelected = false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 100,
                height: 130,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10.0),
                    bottomLeft: Radius.circular(10.0),
                  ),
                  child: widget.item.photoUrl != null
                      ? Image.network(
                          widget.item.photoUrl!,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          'images/placeholder_food.png',
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
                        widget.item.name,
                        style: Theme.of(context)
                            .textTheme
                            .bodyText1!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(widget.item.category),
                      Row(
                        children: [
                          Text(
                            formatCurrency(widget.item.startPrice),
                            style: TextStyle(
                              decoration: TextDecoration.lineThrough,
                              decorationThickness: 2,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(formatCurrency(widget.item.discountedPrice)),
                        ],
                      ),
                      Text(
                        widget.item.description,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ),
              Checkbox(
                value: _isSelected,
                onChanged: (isSelected) {
                  setState(() {
                    _isSelected = isSelected!;
                    widget.onCheckboxChanged(_isSelected);
                  });
                },
              )
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
                      if (quantity >= 1) {
                        setState(() {
                          quantity -= 1;
                          widget.onQuantityChanged(quantity);
                        });
                      }
                    },
                    child: Text("-"),
                  ),
                  Text(
                    "${quantity}",
                    style: Theme.of(context).textTheme.bodyLarge!,
                  ),
                  TextButton(
                    onPressed: () async {
                      setState(() {
                        quantity += 1;
                        widget.onQuantityChanged(quantity);
                      });
                    },
                    child: Text("+"),
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
