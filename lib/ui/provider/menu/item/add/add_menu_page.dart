import 'dart:io';

import 'package:flutter/material.dart';
import 'package:greenneeds/ui/provider/menu/item/add/add_menu_page_view_model.dart';
import 'package:provider/provider.dart';

import '../../../../utils.dart';

class AddMenuPage extends StatefulWidget {
  const AddMenuPage({super.key});

  @override
  State<AddMenuPage> createState() => _AddMenuPageState();
}

class _AddMenuPageState extends State<AddMenuPage> {
  late Future<List<String>> _categoriesFuture;
  String _selectedCategory = 'tidak dikategorikan';
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _discountedPriceController = TextEditingController();
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = context.read<AddMenuPageViewModel>().getCategories();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel=Provider.of<AddMenuPageViewModel>(context);
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
            await viewModel.addMenuItem(context, _nameController.text.trim(), _selectedCategory, _descriptionController.text.trim(),
                _priceController.text.trim(), _discountedPriceController.text.trim(), _imageFile);
          }, icon:Icon(Icons.add))
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
                padding: EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("gambar",style: Theme.of(context).textTheme.bodyLarge),
                  SizedBox(height: 5.0),
                  InkWell(
                    onTap: () async {
                      File? image = await getImageFromDevice(context);
                      setState(() {
                        _imageFile = image;
                      });
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: _imageFile != null
                                ? FileImage(_imageFile!)
                                : AssetImage('images/placeholder_food.png') as ImageProvider,
                          ),
                        ),
                      ),
                    ),
                  ),
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
                      hintText: "nama item",
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Text("kategori", style: Theme.of(context).textTheme.bodyLarge),
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
                    maxLines: null,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                      ),
                      hintText: "deskripsi item",
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Text("harga awal item", style: Theme.of(context).textTheme.bodyLarge),
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
                  Text("harga diskon item", style: Theme.of(context).textTheme.bodyLarge),
                  SizedBox(height: 5.0),
                  TextField(
                    controller: _discountedPriceController,
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
