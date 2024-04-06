import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void showCustomSnackBar(BuildContext context, String message, {Duration duration = const Duration(seconds: 1), required Color color}) {
  final snackBar = SnackBar(
    content: Text(message),
    duration: duration,
    backgroundColor: color,
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

String formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}

String formatDateWithMonth(DateTime dateTime) {
  List<String> indonesianMonthNames = [
    '',
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember'
  ];

  // Format the date
  String formattedDate = '${dateTime.day} ${indonesianMonthNames[dateTime.month]} ${dateTime.year}';

  return formattedDate;
}

String formatCurrency(int price) {
  String formattedPrice = price.toString();
  final RegExp regExp = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  formattedPrice = formattedPrice.replaceAllMapped(regExp, (Match match) => '${match[1]},');
  return 'Rp $formattedPrice';
}


Future<File?> getImageFromDevice(BuildContext context) async {
  final picker = ImagePicker();
  try {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      return File(pickedFile.path);
    } else {
      return null;
    }
  } catch (e) {
    log('Error picking image: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error picking image: $e'),
        duration: Duration(seconds: 3),
      ),
    );
    return null;
  }
}

Future<String?> uploadProfileImage(File imageFile) async {
  try {
    FirebaseStorage storage = FirebaseStorage.instance;
    final FirebaseAuth _auth = FirebaseAuth.instance;
    String url = "";
    final metadata = SettableMetadata(contentType: "image/jpeg");
    Reference ref = storage.ref().child("images/profile/${_auth.currentUser?.uid}.jpg");
    final uploadTask = ref.putFile(imageFile, metadata);

    await uploadTask.whenComplete(() async {
      url = await ref.getDownloadURL();
    });

    return url;
  } catch (e) {
    log('Error uploading profile image: $e');
    return null;
  }
}

Future<String?> uploadMenuImage(File imageFile,String uid) async {
  try {
    FirebaseStorage storage = FirebaseStorage.instance;
    final FirebaseAuth _auth = FirebaseAuth.instance;
    String url = "";
    final metadata = SettableMetadata(contentType: "image/jpeg");
    Reference ref = storage.ref().child("images/menu/${_auth.currentUser?.uid}/${uid}.jpg");
    final uploadTask = ref.putFile(imageFile, metadata);

    await uploadTask.whenComplete(() async {
      url = await ref.getDownloadURL();
    });

    return url;
  } catch (e) {
    log('Error uploading profile image: $e');
    return null;
  }
}