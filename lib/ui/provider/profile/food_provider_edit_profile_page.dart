import 'dart:io';

import 'package:flutter/material.dart';
import 'package:greenneeds/model/Profile.dart';
import 'package:greenneeds/ui/provider/profile/food_provider_profile_view_model.dart';
import 'package:greenneeds/ui/utils.dart';
import 'package:provider/provider.dart';


class FoodProviderEditProfilePage extends StatefulWidget {
  const FoodProviderEditProfilePage({super.key});

  @override
  State<FoodProviderEditProfilePage> createState() => _FoodProviderEditProfilePageState();
}

class _FoodProviderEditProfilePageState extends State<FoodProviderEditProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  File? _imageFile;

  @override
  Widget build(BuildContext context) {
    final foodProviderProfileViewModel = Provider.of<FoodProviderProfileViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: foodProviderProfileViewModel.isLoading
        ? null
        :IconButton(icon: Icon(Icons.arrow_back),onPressed: (){
          Navigator.of(context).pushNamedAndRemoveUntil("/provider", (route) => false);
          Navigator.pushReplacementNamed(context, "/provider");
        }),
        title: Text("Edit Profile"),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () async{
              await foodProviderProfileViewModel.updateProfile(context, _nameController.text.trim(), _phoneNumberController.text.trim()
                  ,_addressController.text.trim(),_cityController.text.trim(),_imageFile);
            },
          ),
        ],
      ),
      body: ChangeNotifierProvider(
        create: (context)=>foodProviderProfileViewModel,
        child: Consumer(
          builder: (context,viewModel,_)=>Stack(
            children: [
              if (foodProviderProfileViewModel.isLoading==false)
                SingleChildScrollView(
                child: Center(
                  child: Column(
                    children: [
                      FutureBuilder(future: foodProviderProfileViewModel.fetchProfile(),
                          builder: (context,snapshot){
                            if(snapshot.connectionState==ConnectionState.waiting){
                              return Container(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                              );
                            }else if(snapshot.hasData){
                              FoodProviderProfile? profile = snapshot.data;
                              _nameController.text = profile!.name;
                              _phoneNumberController.text = profile.phoneNumber;
                              _addressController.text = profile.address!;
                              _cityController.text = profile.city!;
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
                                    SizedBox(height: 20.0),
                                    Text("Ganti Alamat",style: Theme.of(context).textTheme.bodyLarge),
                                    SizedBox(height: 5.0),
                                    TextField(
                                      controller: _addressController,
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(10.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 20.0),
                                    Text("Ganti Kota",style: Theme.of(context).textTheme.bodyLarge),
                                    SizedBox(height: 5.0),
                                    TextField(
                                      controller: _cityController,
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(10.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }else{
                              return Center(child: Text('Error fetching profile'));
                            }
                          }),
                      if(foodProviderProfileViewModel.isLoading)
                        Container(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (foodProviderProfileViewModel.isLoading)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                )
            ],
          )
        ),
      ),
    );
  }
}
