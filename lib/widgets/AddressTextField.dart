
import 'package:flutter/material.dart';

class AddressTextField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {

      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Alamat',style: TextStyle(fontSize: 16.0,color: Colors.grey)),
            Icon(Icons.arrow_forward_ios),
          ],
        ),
      ),
    );
  }
}