import 'package:flutter/material.dart';
import 'package:greenneeds/model/SearchFoodProvider.dart';
import 'package:greenneeds/ui/consumer/food_delivery/detail/store/store_page.dart';
import 'package:greenneeds/ui/consumer/food_delivery/search/search_view_model.dart';
import 'package:provider/provider.dart';

class SearchViewPage extends StatefulWidget {
  const SearchViewPage({Key? key}) : super(key: key);

  @override
  _SearchViewPageState createState() => _SearchViewPageState();
}

class _SearchViewPageState extends State<SearchViewPage> {
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final viewModel = Provider.of<SearchViewModel>(context, listen: false);
    _searchController.addListener(_onSearchTextChanged);
    viewModel.allItems();
  }

  void _onSearchTextChanged() {
    final viewModel = Provider.of<SearchViewModel>(context, listen: false);
    viewModel.searchItems(_searchController.text);
  }


  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SearchViewModel>(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        title: Text("Cari Makanan")
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  contentPadding:
                  EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
                ),
              ),
            ),
            StreamBuilder<List<SearchFoodProvider>>(
              stream: viewModel.searchItemsStream,
              builder: (context, snapshot) {
                if (_searchController.text.isEmpty) {
                  viewModel.allItems();
                  // Show all items
                  return StreamBuilder<List<SearchFoodProvider>>(
                    stream: viewModel.allItemsStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          height: 500,
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Container(
                          height: 500,
                          child: Center(
                            child: Text('${snapshot.error}'),
                          ),
                        );
                      } else {
                        final allItems = snapshot.data ?? [];
                        if (allItems.isEmpty) {
                          return Container(
                            height: 500,
                            child: Center(
                              child: Text('Tidak ditemukan.'),
                            ),
                          );
                        } else {
                          String? prevChar;
                          return Column(
                            children: allItems
                                .map((result) {
                              final char = result.title[0].toUpperCase(); // Get the first character of the title
                              Widget listItem = GestureDetector(
                                  onTap: (){
                                    Navigator.of(context).push(MaterialPageRoute(
                                        builder: (context) =>
                                            StorePage(searchDetail: result)));
                                  },
                                  child: SearchResultListTile(item: result)
                              );
                              if (char != prevChar) {
                                // If the character changes, show the Text widget
                                listItem = Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 30,vertical: 10),
                                      child: Text(char, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                    ),
                                    listItem,
                                  ],
                                );
                                prevChar = char; // Update the previous character
                              }
                              return listItem;
                            })
                                .toList(),
                          );
                        }
                      }
                    },
                  );
                } else {
                  // Show search results differently
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      height: 500,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Container(
                      height: 500,
                      child: Center(
                        child: Text('${snapshot.error}'),
                      ),
                    );
                  } else {
                    final searchResults = snapshot.data ?? [];
                    if (searchResults.isEmpty) {
                      return Container(
                        height: 500,
                        child: Center(
                          child: Text('Tidak ditemukan.'),
                        ),
                      );
                    } else {
                      return Column(
                        children: searchResults
                            .map((result) => GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    StorePage(searchDetail: result)));
                          },
                          child: SearchResultListTile(item: result),
                        ))
                            .toList(),
                      );
                    }
                  }
                }
              },
            )

          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchTextChanged);
    _searchController.dispose();
    super.dispose();
  }
}

class SearchResultListTile extends StatelessWidget {
  final SearchFoodProvider item;
  final String placeholderImageUrl = 'images/placeholder_food.png';

  const SearchResultListTile({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 30.0),
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
                      Container(
                        width: 170,
                        child: Text(
                          item.title,
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1!
                              .copyWith(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          maxLines: 1,
                        ),
                      ),
                      Text("${item.distance} km",style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.grey)),
                    ],
                  ),
                ),
              )
            ],
          ),
          Positioned(
            top: 10,
            right: 10,
            child:
            Container(
              padding: EdgeInsets.all(6),
              child: Row(
                children: [
                  Icon(item.rating !=null ?Icons.star:null, color: Colors.orange),
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      item.rating != null ? "${item.rating?.toStringAsFixed(2)}" : "",
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
