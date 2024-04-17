import 'package:flutter/material.dart';
import 'package:greenneeds/ui/consumer/inventory/category/inventory_category_page_view_model.dart';
import 'package:greenneeds/ui/utils.dart';
import 'package:provider/provider.dart';

class InventoryCategoryPage extends StatefulWidget {
  const InventoryCategoryPage({Key? key}) : super(key: key);

  @override
  State<InventoryCategoryPage> createState() => _InventoryCategoryPageState();
}

class _InventoryCategoryPageState extends State<InventoryCategoryPage> {
  @override
  Widget build(BuildContext context) {
    final viewModel =
    Provider.of<InventoryCategoryPageViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("Kategori"),
        actions: [
          IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return const AddCategoryPopUpWindow();
                    });
              },
              icon: Icon(Icons.add))
        ],
      ),
      body: StreamBuilder<List<String>>(
        stream: viewModel.categoriesStream(),
        builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<String>? categories = snapshot.data;
            if (categories != null && categories.isNotEmpty) {
              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      ListView.builder(
                        itemCount: categories.length,
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, int index) {
                          String category = categories[index];
                          return Container(
                              margin: EdgeInsets.symmetric(vertical: 10.0),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: ListTile(
                                title: Text(category),
                                trailing: IconButton(
                                  icon: Icon(Icons.close),
                                  onPressed: () async {
                                    bool confirmDelete = await showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          icon:  Icon(Icons.warning,color: Colors.red),
                                          title: Text("Peringatan",style: TextStyle(fontWeight: FontWeight.bold)),
                                          content: Container(
                                            width: double.infinity,
                                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                            margin: EdgeInsets.symmetric(vertical: 10),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(8.0),
                                            ),
                                            child: Text("Mendelete kategori menyebabkan item dikategorikan menjadi ${'"tidak dikategorikan"'}",textAlign: TextAlign.center,),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop(false);
                                              },
                                              child: Text("Cancel"),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop(true);
                                              },
                                              child: Text("OK"),
                                            ),
                                          ],
                                        );
                                      },
                                    );

                                    if (confirmDelete ?? false) {
                                      // User confirmed deletion
                                      await viewModel.deleteCategory(category);
                                    }                                  },
                                ),
                              ),
                            );
                        },
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return Center(
                child: Text("Belum Ada Kategori"),
              );
            }
          }
        },
      ),
    );
  }
}

class AddCategoryPopUpWindow extends StatefulWidget {
  const AddCategoryPopUpWindow({Key? key}) : super(key: key);

  @override
  State<AddCategoryPopUpWindow> createState() => _AddCategoryPopUpWindowState();
}

class _AddCategoryPopUpWindowState extends State<AddCategoryPopUpWindow> {
  final TextEditingController _nameController = TextEditingController();

  void addCategory(BuildContext context) {
    String categoryName = _nameController.text.trim();
    if (categoryName.isNotEmpty) {
      Provider.of<InventoryCategoryPageViewModel>(context, listen: false)
          .addToCategories(categoryName);
      Navigator.of(context).pop();
    } else {
      showCustomSnackBar(context, "Field harus diisi.", color: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text("Tambah Kategori",
                      style: Theme.of(context).textTheme.titleLarge!),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    contentPadding:
                    EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                    hintText: "nama kategori",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      addCategory(context); // Call addCategory function
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          const Color(0xFF7A779E)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    child: Text(
                      'Tambah',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge!
                          .copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
