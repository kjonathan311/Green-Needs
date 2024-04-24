
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:greenneeds/ui/consumer/food_delivery/address/address_view_model.dart';
import 'package:greenneeds/ui/consumer/food_delivery/search/category_search_view_page.dart';
import 'package:greenneeds/ui/consumer/food_delivery/search/search_view_model.dart';
import 'package:greenneeds/ui/consumer/food_delivery/search/search_view_page.dart';
import 'package:greenneeds/ui/consumer/profile/consumer_profile_popupwindow.dart';
import 'package:provider/provider.dart';

import '../../../model/Category.dart';
import 'address/address_page.dart';
import 'cart/cart_page.dart';

class HomeFoodDeliveryPage extends StatefulWidget {
  const HomeFoodDeliveryPage({super.key});

  @override
  State<HomeFoodDeliveryPage> createState() => _HomeFoodDeliveryPageState();
}

class _HomeFoodDeliveryPageState extends State<HomeFoodDeliveryPage> {

  @override
  Widget build(BuildContext context) {
    final addressViewModel = Provider.of<AddressViewModel>(context);
    final searchViewModel = Provider.of<SearchViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: (){
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => CartPage()));
          }, icon: Icon(Icons.shopping_cart),
        ),
        title: Text("Beli Food Waste",style: TextStyle(fontSize: 16)),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_2),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return ConsumerProfilePopUpWindow();
                  });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          GestureDetector(
            onTap: (){
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddressPage()));
            },
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20)
              ),
              padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
              margin: EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on,color: Colors.white),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text("${addressViewModel.selectedAddress!.address}",
                        style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,    
                        maxLines: 2),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: GestureDetector(
              onTap: (){
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => SearchViewPage()));
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Cari',style: TextStyle(fontSize: 16.0,color: Colors.grey)),
                    Icon(Icons.search,color: Colors.grey),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Align(
              alignment: Alignment.centerLeft,
                child: Text("Kategori",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20))
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: FutureBuilder<List<CategoryItem>?>(
                future: searchViewModel.categoryItems(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Text('Loading..'),
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    final categories = snapshot.data ?? [];
                    if(categories.isEmpty){
                      return Container(
                        height: 500,
                        child: Text("tidak ada kategori."),
                      );
                    }else {
                      return GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 1.5,
                        ),
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(builder: (context) => CategorySearchViewPage(category: category.name)));
                            },
                            child: GridTile(
                              footer: GridTileBar(
                                backgroundColor: Colors.black45,
                                title: Text(category.name, style: TextStyle(
                                    fontWeight: FontWeight.bold)),
                              ),
                              child: category.photoUrl != null
                                  ? Image.network(
                                category.photoUrl!,
                                fit: BoxFit.cover,
                              )
                                  : Image.asset(
                                "images/placeholder_food.png",
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      );
                    }
                  }
                },
              ),
            ),
          ),
          SizedBox(height: 100)
        ],
      ),
    );
  }
}
