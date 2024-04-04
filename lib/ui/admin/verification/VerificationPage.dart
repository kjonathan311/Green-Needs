import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:greenneeds/model/Profile.dart';
import 'package:greenneeds/ui/admin/verification/AdminVerificationViewModel.dart';
import 'package:provider/provider.dart';

class VerificationPage extends StatefulWidget {
  const VerificationPage({super.key});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  String _selectedStatus = 'unverified';

  @override
  Widget build(BuildContext context) {
    final adminVerificationViewModel =
        Provider.of<AdminVerificationViewModel>(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: DropdownButton<String>(
                  value: _selectedStatus,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedStatus = newValue!;
                    });
                  },
                  items: <String>['unverified', 'verified', 'denied']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        Expanded(
            child: StreamBuilder<List<FoodProviderProfile>>(
          stream: adminVerificationViewModel
              .unverifiedFoodProvidersStream(_selectedStatus),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              List<FoodProviderProfile> data = snapshot.data ?? [];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    FoodProviderProfile provider = data[index];
                    List<Widget> trailingIcons = [];
                    if (_selectedStatus == 'unverified') {
                      trailingIcons = [
                        IconButton(
                          icon: Icon(Icons.check),
                          onPressed: () async {
                            await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('verify akun?'),
                                  content: const Text("aksi ini tidak dapat kembali."),
                                  actions: [
                                    TextButton(
                                      child: const Text('Cancel'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: Text(
                                        'Ok',
                                        style: TextStyle(
                                          color: Colors.blue,
                                        ),
                                      ),
                                      onPressed: () async {
                                        Navigator.of(context).pop(); // Close the dialog
                                        await adminVerificationViewModel.verifyFoodProvider(
                                            context, provider.uid);
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),

                        IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () async {
                            await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('tolak akun?'),
                                  content: const Text("aksi ini tidak dapat kembali."),
                                  actions: [
                                    TextButton(
                                      child: const Text('Cancel'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: Text(
                                        'Deny',
                                        style: TextStyle(
                                          color: Colors.red,
                                        ),
                                      ),
                                      onPressed: () async {
                                        Navigator.of(context).pop(); // Close the dialog
                                        await adminVerificationViewModel.denyFoodProvider(
                                            context, provider.uid);
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),

                      ];
                    }
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          // Add border
                          borderRadius: BorderRadius.circular(
                              8.0),

                        ),
                        child: ListTile(
                          title: Text(provider.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('UID: ${provider.uid}'),
                              Text('Email: ${provider.email}'),
                              Text('Phone Number: ${provider.phoneNumber}'),
                              Text('Address: ${provider.address}'),
                              Text('City: ${provider.city}'),
                              Text('Status: ${provider.status}'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: trailingIcons,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }
          },
        ))
      ],
    );
  }
}
