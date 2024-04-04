
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:greenneeds/model/Profile.dart';
import 'package:greenneeds/ui/utils.dart';
import 'package:provider/provider.dart';
import 'ConsumerProfileViewModel.dart';

class ConsumerEditProfilePage extends StatefulWidget {
  const ConsumerEditProfilePage({super.key});

  @override
  State<ConsumerEditProfilePage> createState() => _ConsumerEditProfilePageState();
}

class _ConsumerEditProfilePageState extends State<ConsumerEditProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  File? _imageFile;

  @override
  Widget build(BuildContext context) {
    final consumerProfileViewModel = Provider.of<ConsumerProfileViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: consumerProfileViewModel.isLoading
            ? null
            : IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushNamedAndRemoveUntil("/consumer", (route) => false);
            Navigator.pushReplacementNamed(context, "/consumer");
          },
        ),
        title: Text("Edit Profile"),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () async{
              await consumerProfileViewModel.updateProfile(context, _nameController.text.trim(), _phoneNumberController.text.trim(),_imageFile);
            },
          ),
        ],
      ),
      body: Stack(
            children: [
              if(consumerProfileViewModel.isLoading==false)
              SingleChildScrollView(
                child: Center(
                  child: Column(
                    children: [
                      FutureBuilder(
                          future: consumerProfileViewModel.fetchProfile(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting ) {
                              return Container(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                              );
                            } else if (snapshot.hasData) {
                              ConsumerProfile? profile = snapshot.data;
                              _nameController.text = profile!.name;
                              _phoneNumberController.text = profile.phoneNumber;
                              return Padding(
                                padding: const EdgeInsets.all(40.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Ganti Profile",style: Theme.of(context).textTheme.bodyLarge),
                                    SizedBox(height: 5.0),
                                    InkWell(
                                      onTap: () async {
                                        File? image = await getImageFromDevice(context);
                                        setState(() {
                                          _imageFile = image;
                                        });
                                      },
                                      child: CircleAvatar(
                                        radius: 60,
                                        backgroundImage: _imageFile != null
                                            ? FileImage(_imageFile!)
                                            : profile?.photoUrl != null
                                            ? NetworkImage(profile.photoUrl!)
                                            : AssetImage('images/placeholder_profile.jpg') as ImageProvider<Object>?,
                                      ),
                                    ),
                                    SizedBox(height: 10.0),
                                    Text("Ganti Nama",style: Theme.of(context).textTheme.bodyLarge),
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
                                    SizedBox(height: 20.0),
                                    Text("Ganti No Telepon",style: Theme.of(context).textTheme.bodyLarge),
                                    SizedBox(height: 5.0),
                                    TextField(
                                      controller: _phoneNumberController,
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(10.0),
                                          ),
                                        ),
                                      ),
                                      keyboardType: TextInputType.number,
                                    ),
                                  ],
                                ),
                              );

                            } else {
                              return Center(child: Text('Error fetching profile'));
                            }
                          }),
                    ],
                  ),
                ),
              ),
              if (consumerProfileViewModel.isLoading)
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
