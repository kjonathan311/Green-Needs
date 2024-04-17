import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:greenneeds/ui/consumer/inventory/item/add/add_inventory_item_page_view_model.dart';
import 'package:provider/provider.dart';

import '../../../../utils.dart';

class AddInventoryItemPage extends StatefulWidget {
  const AddInventoryItemPage({super.key});

  @override
  State<AddInventoryItemPage> createState() => _AddInventoryItemPageState();
}

class _AddInventoryItemPageState extends State<AddInventoryItemPage> {
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(Duration(days: 7));
  late Future<List<String>> _categoriesFuture;
  String _selectedCategory = 'tidak dikategorikan';

  int quantity = 1;
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _startDateController.text = formatDate(startDate);
    _endDateController.text = formatDate(endDate);
    _categoriesFuture = context.read<AddInventoryItemPageViewModel>().getCategories();
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != startDate) {
      setState(() {
        startDate = picked;
        _startDateController.text = formatDate(startDate);
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != endDate) {
      setState(() {
        endDate = picked;
        _endDateController.text = formatDate(endDate);
      });
    }
  }

  void _incrementQuantity() {
    setState(() {
      quantity++;
    });
  }

  void _decrementQuantity() {
    setState(() {
      if (quantity > 1) {
        quantity--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel =
    Provider.of<AddInventoryItemPageViewModel>(context);

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
          IconButton(onPressed: ()async{
            await viewModel.addInventoryItem(
                context, _nameController.text.trim(),
                startDate,
                endDate,
                _selectedCategory,
                quantity);
          }, icon:Icon(Icons.add))
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
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
                      hintText: "nama item",
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
                  Text("Tanggal Beli/Tambah Item",
                      style: Theme.of(context).textTheme.bodyLarge),
                  SizedBox(height: 5.0),
                  TextField(
                    controller: _startDateController,
                    readOnly: true,
                    onTap: () => _selectStartDate(context),
                    decoration: InputDecoration(
                      hintText: 'Pilih Tanggal awal',
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: () => _selectStartDate(context),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
                    ),
                  ),
                  SizedBox(height: 10.0),


                  Text("Tanggal Expire Item",
                      style: Theme.of(context).textTheme.bodyLarge),
                  SizedBox(height: 5.0),
                  TextField(
                    controller: _endDateController,
                    readOnly: true,
                    onTap: () => _selectEndDate(context),
                    decoration: InputDecoration(
                      hintText: 'Pilih tanggal expire',
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: () => _selectEndDate(context),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
                    ),
                  ),
                  SizedBox(height: 10.0),


                  Text("Jumlah",
                      style: Theme.of(context).textTheme.bodyLarge),
                  SizedBox(height: 5.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
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
                                  text: quantity.toString()),
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
