import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
                Tab(icon: Icon(Icons.menu), text: "Menu"),
                Tab(icon: Icon(Icons.wysiwyg), text: "Food Waste Harian"),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  MenuLayout(),
                  Center(child: Text('Food waste harian content')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
    _tabController = TabController(length: 3, vsync: this);
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
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Row(
              children: [
                Expanded(
                  child: TabBar(
                    isScrollable: true,
                    controller: _tabController,
                    tabs: [
                      Text("PlaceHolder1"),
                      Text("PlaceHolder2"),
                      Text("PlaceHolder3"),
                    ],
                    onTap: (index) {
                      setState(() {
                        // _selectedCategory = categories[index];
                        // _selectedCategoryController.add(_selectedCategory);
                      });
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
            child: ListView.builder(
              itemCount: 10,
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => DetailInventoryItemPage(
                      //       item: items[index],
                      //     ),
                      //   ),
                      // );
                    },
                    child: MenuListTile());
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MenuListTile extends StatelessWidget {
  final String? photoUrl;
  final String placeholderImageUrl = 'images/placeholder_food.pn';

  const MenuListTile({Key? key, this.photoUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Container(
        height: 130,
        child: Row(
          children: [
            SizedBox(
              width: 100,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  bottomLeft: Radius.circular(10.0),
                ),
                child: photoUrl != null
                    ? Image.network(
                        photoUrl!,
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
                    Text("name",
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .copyWith(fontWeight: FontWeight.bold)),
                    Text("category"),
                    Row(
                      children: [
                        Text(
                          "Rp. 10.000",
                          style: TextStyle(
                            decoration: TextDecoration.lineThrough,
                            decorationThickness: 2,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text("Rp. 5.000"),
                      ],
                    ),
                    Text(
                      "gjpasde'fgiojsdopgisjdogprijgwopeigjepwoigjweropij",
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
