
import 'package:flutter/material.dart';
import 'package:greenneeds/model/FirebaseAuthProvider.dart';
import 'package:greenneeds/model/Profile.dart';
import 'package:provider/provider.dart';

import 'food_provider_profile_view_model.dart';

class FoodProviderProfilePopUpWindow extends StatelessWidget {
  const FoodProviderProfilePopUpWindow({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<FirebaseAuthProvider>(context);
    final foodProviderProfileViewModel = Provider.of<FoodProviderProfileViewModel>(context);


    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            FutureBuilder(
                future: foodProviderProfileViewModel.fetchProfile(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasData) {
                    FoodProviderProfile? profile = snapshot.data;
                    return Row(
                      children: [
                        Expanded(
                          flex:1,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: CircleAvatar(
                              radius:60,
                              backgroundImage: profile?.photoUrl != null
                                  ? NetworkImage(profile!.photoUrl!)
                                  : AssetImage('images/placeholder_profile.jpg') as ImageProvider<Object>?,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  '${profile!.name}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis
                              ),
                              const SizedBox(height: 5.0),
                              Text('${profile.email}',  overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 5.0),
                              Text('${profile.phoneNumber}',overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 5.0),
                              Text('alamat:',overflow: TextOverflow.ellipsis),
                              Text('${profile.address}',overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 5.0),
                              Row(
                                children: [
                                  Text('Status:'),
                                  SizedBox(width: 5), // Add some spacing between the text and icon
                                  if (profile.status == 'unverified')
                                    const Row(
                                      children: [
                                        Text('unverified'), // Display text for unverified status
                                        Icon(Icons.info,color: Colors.red,), // Display warning icon for unverified status
                                      ],
                                    )
                                  else if (profile.status == 'denied')
                                    const Row(
                                      children: [
                                        Text('denied'), // Display text for unverified status
                                        Icon(Icons.warning,color: Colors.red,), // Display warning icon for unverified status
                                      ],
                                    )
                                  else
                                    const Row(
                                      children: [
                                        Text('verified'), // Display text for unverified status
                                        Icon(Icons.verified,color: Colors.green), // Display warning icon for unverified status
                                      ],
                                    )
                                ],
                              ),
                              const SizedBox(height: 10.0),
                            ],
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Center(child: Text('Error ambil profil'));
                  }
                }),
            Divider(),
            Align(
                alignment: Alignment.centerLeft,
                child: Text("Pengaturan",
                    style: Theme.of(context).textTheme.titleMedium)),
            const SizedBox(
              height: 10.0,
            ),
            ListTile(
              leading: Icon(Icons.edit),
              title: Text("Edit Profile"),
              onTap: () async {
                Navigator.pushNamed(context, "/provider/edit/profile");
              },
            ),
            const SizedBox(
              height: 10.0,
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text("logout"),
              onTap: () async {
                await authProvider.logout();
                Navigator.of(context)
                    .pushNamedAndRemoveUntil("/introduction", (route) => false);
                Navigator.pushReplacementNamed(context, "/introduction");
              },
            )
          ],
        ),
      ),
    );
  }
}