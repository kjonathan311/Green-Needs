

import 'package:flutter/material.dart';

import '../profile/consumer_profile_popupwindow.dart';


class BlockedScreen extends StatelessWidget {
  const BlockedScreen({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              icon: const Icon(Icons.person_2),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return const ConsumerProfilePopUpWindow();
                    });
              },
            ),
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Text(
              "Akun telah diblock. Silakan logout dari aplikasi",
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center, // Align text to the center
            ),
          ),
        ),
      );
}

