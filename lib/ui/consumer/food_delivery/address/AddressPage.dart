
import 'package:flutter/material.dart';
import 'package:greenneeds/model/Address.dart';
import 'package:greenneeds/ui/consumer/food_delivery/cart/CartViewModel.dart';
import 'package:greenneeds/ui/consumer/food_delivery/search/SearchViewModel.dart';
import 'package:provider/provider.dart';

import 'AddressViewModel.dart';


class AddressPage extends StatefulWidget {
  const AddressPage({Key? key}) : super(key: key);

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AddressViewModel>(context);
    final searchViewModel = Provider.of<SearchViewModel>(context);
    final cartViewModel=Provider.of<CartViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: viewModel.selectedAddress != null
            ? IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        )
            : null,
        title: Text("Alamat"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const AddAddressPopUpWindow();
                  },
                );
              },
              child: Text("tambah alamat baru"),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Address>>(
              stream: viewModel.addressItems(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting || snapshot.hasError) {
                  return Center(
                    child: Text('Loading..'),
                  );
                } else {
                  final addresses = snapshot.data ?? [];
                  if (addresses.isEmpty) {
                    return Center(
                      child: Text('Tidak ada alamat.'),
                    );
                  } else {
                    return ListView.builder(
                      itemCount: addresses.length,
                      itemBuilder: (context, index) {
                        final address = addresses[index];
                        return Container(
                          margin: EdgeInsets.symmetric(vertical: 5,horizontal: 32),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: ListTile(
                            title: Text(address.address,style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text("${address.address}, ${address.city}, ${address.postalcode}"),
                            leading: Radio<int>(
                              value: index,
                              groupValue: viewModel.selectedIndex,
                              onChanged: (int? value) {
                                if (mounted) {
                                  setState(() {
                                    viewModel.setSelectedIndex(value!);
                                  });
                                }
                              },
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () async{
                                await viewModel.deleteAddress(context, address.uid);
                              },
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
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: ElevatedButton(
              onPressed: () {
                viewModel.selectAddress(context);
                searchViewModel.selectedAddress=viewModel.selectedAddress;
                cartViewModel.selectedAddress=viewModel.selectedAddress;
              },
              style: ButtonStyle(
                backgroundColor:
                MaterialStateProperty.all<Color>(const Color(0xFF7A779E)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Pilih alamat',
                  style: Theme.of(context).textTheme.headline6!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}




class AddAddressPopUpWindow extends StatefulWidget {
  const AddAddressPopUpWindow({Key? key}) : super(key: key);

  @override
  State<AddAddressPopUpWindow> createState() => _AddAddressPopUpWindowState();
}

class _AddAddressPopUpWindowState extends State<AddAddressPopUpWindow> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AddressViewModel>(context);
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
                  child: Text("Tambah Alamat",
                      style: Theme.of(context).textTheme.titleLarge!),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    contentPadding:
                    EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                    hintText: "alamat",
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
                child: TextField(
                  controller: _cityController,
                  decoration: const InputDecoration(
                    contentPadding:
                    EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                    hintText: "Kota",
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
                    onPressed: viewModel.isLoading
                        ? null
                        : () async {
                      await viewModel.addAddress(
                          context,
                          _addressController.text.trim(),
                          _cityController.text.trim());
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
