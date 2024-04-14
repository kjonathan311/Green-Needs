import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:greenneeds/model/MenuItem.dart';
import 'package:greenneeds/ui/provider/menu/item/detail/DetailMenuViewModel.dart';
import 'package:provider/provider.dart';

import '../../../../utils.dart';

class DetailMenuPage extends StatefulWidget {
  final MenuItem item;
  const DetailMenuPage({super.key, required this.item});

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
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _nameController.text=widget.item.name;
    if(widget.item.description!=null){
      _descriptionController.text=widget.item.description!;
    }
    _priceController.text=widget.item.startPrice.toString();
    _discountedPriceController.text=widget.item.discountedPrice.toString();
    _categoriesFuture = context.read<DetailMenuViewModel>().getCategories();
    if (_selectedCategory == 'tidak dikategorikan') {
      _selectedCategory = widget.item.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel =
    Provider.of<DetailMenuViewModel>(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("Detail menu"),
        actions: [
          IconButton(onPressed: ()async{
            await viewModel.deleteMenuItem(context,widget.item.uid,widget.item.photoUrl);
          }, icon:Icon(Icons.delete)),
          IconButton(onPressed: ()async{
            await viewModel.editMenuitem(context, widget.item.uid, _nameController.text.trim(), _priceController.text.trim(),
                _discountedPriceController.text.trim(), _selectedCategory, _imageFile, _descriptionController.text.trim());
          }, icon:Icon(Icons.edit)
          )
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
                                : (widget.item.photoUrl != null
                                ? NetworkImage(widget.item.photoUrl!)
                                : AssetImage('images/placeholder_food.png')) as ImageProvider<Object>,
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
                          return Text("..Loading");
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
                    maxLines: null,
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
