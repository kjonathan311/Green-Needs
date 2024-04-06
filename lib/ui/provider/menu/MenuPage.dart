import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:greenneeds/model/MenuItem.dart';
import 'package:greenneeds/ui/provider/menu/MenuPageViewModel.dart';
import 'package:greenneeds/ui/provider/menu/item/detail/DetailMenuPage.dart';
import 'package:provider/provider.dart';
import '../../utils.dart';
import '../profile/FoodProviderProfilePopUpWindow.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
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
        body: const MenuLayout());
  }
}

class MenuLayout extends StatefulWidget {
  const MenuLayout({super.key});

  @override
  State<MenuLayout> createState() => _MenuLayoutState();
}

class _MenuLayoutState extends State<MenuLayout> with TickerProviderStateMixin {
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
    final viewModel = Provider.of<MenuPageViewModel>(context);
    return SingleChildScrollView(
      child: Column(
        children: [
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
                        List<String> categories = snapshot.data ??
                            ["Semua item", 'tidak dikategorikan'];
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
                              _selectedCategoryController
                                  .add(_selectedCategory);
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
                      Navigator.pushNamed(context, "/provider/menu/add");
                    },
                    child: Icon(Icons.add)),
              ],
            ),
          ),
          const SizedBox(height: 10.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: StreamBuilder<String>(
              stream: _selectedCategoryController.stream,
              builder: (context, snapshotCategory) {
                if (snapshotCategory.hasData && snapshotCategory.data != null) {
                  return StreamBuilder<List<MenuItem>>(
                    stream: viewModel.menuItems(snapshotCategory.data!),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Container(
                          height: 100,
                          child: Center(
                            child: Text('Error: ${snapshot.error}'),
                          ),
                        );
                      } else {
                        List<MenuItem>? items = snapshot.data;
                        if (snapshot.connectionState ==
                                ConnectionState.waiting ||
                            snapshot.hasError) {
                          return Container(
                            height: 500,
                            child: Center(
                              child: Text('Loading..'),
                            ),
                          );
                        } else if (items == null || items.isEmpty) {
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
                              return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DetailMenuPage(
                                          item: items[index],
                                        ),
                                      ),
                                    );
                                  },
                                  child: MenuListTile(
                                    item: items[index],
                                  ));
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
    );
  }
}

class MenuListTile extends StatelessWidget {
  final MenuItem item;
  final String placeholderImageUrl = 'images/placeholder_food.png';

  const MenuListTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Container(
        child: Row(
          children: [
            SizedBox(
              width: 100,
              height: 130,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  bottomLeft: Radius.circular(10.0),
                ),
                child: item.photoUrl != null
                    ? Image.network(
                        item.photoUrl!,
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
                    Text(item.name,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .copyWith(fontWeight: FontWeight.bold)),
                    Text(item.category),
                    Row(
                      children: [
                        Text(
                          formatCurrency(item.startPrice),
                          style: TextStyle(
                            decoration: TextDecoration.lineThrough,
                            decorationThickness: 2,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(formatCurrency(item.discountedPrice)),
                      ],
                    ),
                    Text(
                      item.description,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
