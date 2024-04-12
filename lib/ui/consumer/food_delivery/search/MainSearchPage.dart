
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:greenneeds/ui/consumer/food_delivery/address/AddressViewModel.dart';
import 'package:greenneeds/ui/consumer/food_delivery/search/MainSearchViewModel.dart';
import 'package:greenneeds/ui/consumer/profile/ConsumerProfilePopUpWindow.dart';
import 'package:provider/provider.dart';

import '../../../../model/Category.dart';
import '../address/AddressPage.dart';

class MainSearchPage extends StatefulWidget {
  const MainSearchPage({super.key});

  @override
  State<MainSearchPage> createState() => _MainSearchPageState();
}

class _MainSearchPageState extends State<MainSearchPage> {

  @override
  Widget build(BuildContext context) {
    final addressViewModel = Provider.of<AddressViewModel>(context);
    final mainSearchViewModel = Provider.of<MainSearchViewModel>(context);

    return Scaffold(
      appBar: AppBar(
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
                  Icon(Icons.location_on,color: Colors.white,),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text("${addressViewModel.selectedAddress!.address}",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)
                        ,overflow: TextOverflow.ellipsis,    maxLines: 2),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: GestureDetector(
              onTap: (){},
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Search',style: TextStyle(fontSize: 16.0,color: Colors.grey)),
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
              child: StreamBuilder<List<CategoryItem>>(
                stream: mainSearchViewModel.categoryItems(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Text('Loading..'),
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    final categories = snapshot.data ?? [];
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return GestureDetector(
                          onTap: () {
                          },
                          child: GridTile(
                            footer: GridTileBar(
                              backgroundColor: Colors.black45,
                              title: Text(category.name,style: TextStyle(fontWeight: FontWeight.bold)),
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
                },
              ),
            ),
          )



        ],
      ),
    );
  }
}
