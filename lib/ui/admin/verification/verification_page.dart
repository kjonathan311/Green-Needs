import 'package:flutter/material.dart';
import 'package:greenneeds/model/Profile.dart';
import 'package:greenneeds/ui/admin/verification/admin_verification_view_model.dart';
import 'package:greenneeds/ui/admin/verification/detail_consumer_page.dart';
import 'package:greenneeds/ui/admin/verification/detail_provider_page.dart';
import 'package:provider/provider.dart';

import '../admin_screen.dart';

class VerificationPage extends StatefulWidget {
  const VerificationPage({super.key});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Verifikasi"),
        actions: [
          IconButton(
            icon: Icon(Icons.person_2),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AdminProfilePopUpWindow();
                },
              );
            },
          ),
        ],
      ),
      body: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              TabBar(
                tabs: [
                  Tab(text: "Penyedia Makanan"),
                  Tab(text: "Konsumen"),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    FoodProviderLayout(),
                    ConsumerLayout()
                  ],
                ),
              ),
            ],
          )),
    );

  }
}

class FoodProviderLayout extends StatefulWidget {
  const FoodProviderLayout({super.key});

  @override
  State<FoodProviderLayout> createState() => _FoodProviderLayoutState();
}

class _FoodProviderLayoutState extends State<FoodProviderLayout> {
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
                        }else if(_selectedStatus == 'verified'){
                          trailingIcons=[
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
                        }else if(_selectedStatus=="denied"){
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
                              title: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: provider.photoUrl != null
                                        ? NetworkImage(provider.photoUrl!)
                                        : const AssetImage('images/placeholder_profile.jpg')
                                    as ImageProvider<Object>?,
                                    radius: 20,
                                  ),
                                  SizedBox(width: 10),
                                  Text(provider.name),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${provider.email}'),
                                  Text('${provider.phoneNumber}'),
                                  Text('${provider.address}, ${provider.postalcode}, ${provider.city}'),
                                  Text('Status: ${provider.status}'),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: trailingIcons,
                              ),
                              onTap: (){
                                Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) =>
                                        DetailProviderPage(
                                          provider: provider,
                                        ))
                                );
                              },
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

class ConsumerLayout extends StatefulWidget {
  const ConsumerLayout({super.key});

  @override
  State<ConsumerLayout> createState() => _ConsumerLayoutState();
}

class _ConsumerLayoutState extends State<ConsumerLayout> {
  bool _selectedStatus = true;
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
                child: DropdownButton<bool>(
                  value: _selectedStatus,
                  onChanged: (bool? newValue) {
                    setState(() {
                      _selectedStatus = newValue!;
                    });
                  },
                  items: [
                    DropdownMenuItem<bool>(
                      value: true,
                      child: Text('Unblocked'),
                    ),
                    DropdownMenuItem<bool>(
                      value: false,
                      child: Text('Blocked'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
            child: StreamBuilder<List<ConsumerProfile>>(
              stream: adminVerificationViewModel.consumerProfilesStream(_selectedStatus),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  List<ConsumerProfile> data = snapshot.data ?? [];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        ConsumerProfile consumer = data[index];
                        List<Widget> trailingIcons = [];
                        if (_selectedStatus == false) {
                          trailingIcons = [
                            IconButton(
                              icon: Icon(Icons.check),
                              onPressed: () async {
                                await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('unblock akun?'),
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
                                            await adminVerificationViewModel.reinstateConsumer(
                                                context, consumer.uid);
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ];
                        }else if(_selectedStatus == true){
                          trailingIcons=[
                            IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: () async {
                                await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('block akun?'),
                                      actions: [
                                        TextButton(
                                          child: const Text('Cancel'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        TextButton(
                                          child: Text(
                                            'block',
                                            style: TextStyle(
                                              color: Colors.red,
                                            ),
                                          ),
                                          onPressed: () async {
                                            Navigator.of(context).pop(); // Close the dialog
                                            await adminVerificationViewModel.blockConsumer(
                                                context, consumer.uid);
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
                              title: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: consumer.photoUrl != null
                                        ? NetworkImage(consumer.photoUrl!)
                                        : const AssetImage('images/placeholder_profile.jpg')
                                    as ImageProvider<Object>?,
                                    radius: 20,
                                  ),
                                  SizedBox(width: 10),
                                  Text(consumer.name),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${consumer.email}'),
                                  Text('${consumer.phoneNumber}'),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: trailingIcons,
                              ),
                              onTap: (){
                                Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) =>
                                        DetailConsumerPage(
                                          consumer: consumer,
                                        ))
                                );
                              },
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
