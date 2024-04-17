import 'package:flutter/material.dart';
import 'package:greenneeds/model/FirebaseAuthProvider.dart';
import 'package:greenneeds/model/Profile.dart';
import 'package:greenneeds/ui/consumer/balance/add_balance_view_model.dart';
import 'package:greenneeds/ui/consumer/food_delivery/address/address_view_model.dart';
import 'package:provider/provider.dart';

import '../../utils.dart';
import '../food_delivery/cart/cart_view_model.dart';
import 'consumer_profile_view_model.dart';

class ConsumerProfilePopUpWindow extends StatefulWidget {
  const ConsumerProfilePopUpWindow({super.key});

  @override
  State<ConsumerProfilePopUpWindow> createState() => _ConsumerProfilePopUpWindowState();
}

class _ConsumerProfilePopUpWindowState extends State<ConsumerProfilePopUpWindow> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<FirebaseAuthProvider>(context);
    final consumerProfileViewModel = Provider.of<ConsumerProfileViewModel>(context);
    final addressViewModel = Provider.of<AddressViewModel>(context);
    final cartViewModel = Provider.of<CartViewModel>(context);
    final balanceViewModel = Provider.of<AddBalanceViewModel>(context);


    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            FutureBuilder(
                future: consumerProfileViewModel.fetchProfile(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasData) {
                    ConsumerProfile? profile = snapshot.data;
                    return Row(
                      children: [
                        Expanded(
                          flex:1,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: CircleAvatar(
                              radius:30,
                              backgroundImage: profile?.photoUrl != null
                                  ? NetworkImage(profile!.photoUrl!)
                                  : const AssetImage('images/placeholder_profile.jpg') as ImageProvider<Object>?,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  profile!.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis
                              ),
                              const SizedBox(height: 5.0),
                              Text(profile.email,  overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 5.0),
                              Text(profile.phoneNumber,overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 10.0),
                            ],
                          ),
                        ),
                      ],
                    );
                  } else {
                    return const Center(child: Text('Error fetching profile'));
                  }
                }),
            const Divider(),
            Align(
                alignment: Alignment.centerLeft,
                child: Text("Pengaturan",
                    style: Theme.of(context).textTheme.titleMedium)),
            const SizedBox(
              height: 10.0,
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text("Edit Profile"),
              onTap: () async {
                Navigator.pushNamed(context, "/consumer/edit/profile");
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_money),
              title: FutureBuilder<int>(
                future: balanceViewModel.getBalance(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                  } else if (snapshot.hasData && snapshot.data != null) {
                    int balance = snapshot.data as int;
                    return Text("Saldo:  " + formatCurrency(balance));
                  } else {
                    return Text("saldo:  Loading...");
                  }
                },
              ),
              onTap: () async {
                Navigator.pushNamed(context, "/consumer/balance");
              },
            ),
            const SizedBox(
              height: 10.0,
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () async {
                consumerProfileViewModel.clearData();
                addressViewModel.clearData();
                await authProvider.logout();
                cartViewModel.clearAll();
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