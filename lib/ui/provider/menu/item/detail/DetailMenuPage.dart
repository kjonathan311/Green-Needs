import 'package:flutter/material.dart';

class DetailMenuPage extends StatefulWidget {
  const DetailMenuPage({super.key});

  @override
  State<DetailMenuPage> createState() => _DetailMenuPageState();
}

class _DetailMenuPageState extends State<DetailMenuPage> {
  late Future<List<String>> _categoriesFuture;
  String _selectedCategory = 'tidak dikategorikan';
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _discountedPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // _categoriesFuture = context.read<AddInventoryItemPageViewModel>().getCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("Tambah menu"),
        actions: [
          IconButton(onPressed: ()async{

          }, icon:Icon(Icons.add))
        ],
      ),
      body: Stack(
        children: [

          Padding(
            padding: EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("nama", style: Theme.of(context).textTheme.bodyLarge),
                SizedBox(height: 5.0),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.0),
                Text("Kategori", style: Theme.of(context).textTheme.bodyLarge),
                SizedBox(height: 5.0),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                    ),
                    borderRadius: BorderRadius.circular(8.0), // Border radius
                  ),
                  child: FutureBuilder<List<String>>(
                    future: _categoriesFuture,
                    builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting || snapshot.hasError || snapshot.data == null || snapshot.data!.isEmpty) {
                        return DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          items: [
                            DropdownMenuItem<String>(
                              value: 'tidak dikategorikan',
                              child: Text('tidak dikategorikan'),
                            )
                          ],
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedCategory = newValue!;
                            });
                          },
                        );
                      } else {
                        List<String>? categories = snapshot.data;
                        return DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          items: categories!.map((String category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedCategory = newValue!;
                            });
                          },
                        );
                      }
                    },
                  ),
                ),
                SizedBox(height: 10.0),
                Text("deskripsi makanan", style: Theme.of(context).textTheme.bodyLarge),
                SizedBox(height: 5.0),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.0),
                Text("harga awal", style: Theme.of(context).textTheme.bodyLarge),
                SizedBox(height: 5.0),
                TextField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10.0),
                Text("harga diskon", style: Theme.of(context).textTheme.bodyLarge),
                SizedBox(height: 5.0),
                TextField(
                  controller: _discountedPriceController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10.0),

              ],
            ),
          )

          // if (viewModel.isLoading)
          //   Container(
          //     color: Colors.black.withOpacity(0.3),
          //     child: const Center(
          //       child: CircularProgressIndicator(),
          //     ),
          //   )
        ],
      ),
    );
  }
}
