import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';


class MediaService {
  static Future<Uint8List?> pickImage() async {
    try {
      final imagePicker = ImagePicker();
      final file = await imagePicker.pickImage(
          source: ImageSource.gallery);
      if (file != null) {
        return await file.readAsBytes();
      }
    } on PlatformException catch (e) {
      debugPrint('Failed to pick image: $e');
    }
    return null;
  }
}
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

Color statusColor(String status){
  Color textColor = Colors.black; // Default color
  if (status == "sedang diproses") {
    textColor = Colors.orange;
  } else if (status == "telah dikonfirmasi") {
    textColor = Colors.blue;
  }else if(status=="sedang dikirim"){
    textColor = Colors.blue;
  }else if(status=="order selesai"){
    textColor = Colors.green;
  }else if(status=="sedang dikirim"){
    textColor = Colors.teal;
  }else if(status=="order bisa diambil"){
    textColor = Colors.teal;
  }else if(status=="order dibatalkan"){
    textColor = Colors.red;
  }
  return textColor;
}
Color statusWithdrawColor(String status){
  Color textColor = Colors.black; // Default color
  if (status == "PENDING") {
    textColor = Colors.orange;
  } else if (status == "CLAIMED") {
    textColor = Colors.blue;
  }else if(status=="COMPLETED"){
    textColor = Colors.green;
  }else if(status=="EXPIRED"){
    textColor = Colors.red;
  }
  return textColor;
}

String formatDateWithMonthAndTime(DateTime dateTime) {
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

  // Format the time
  String formattedTime = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

  // Combine date and time
  formattedDate += ' $formattedTime';

  return formattedDate;
}

String formatCurrency(int price) {
  String formattedPrice = price.toString();
  final RegExp regExp = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  formattedPrice = formattedPrice.replaceAllMapped(regExp, (Match match) => '${match[1]},');
  return 'Rp $formattedPrice';
}

String formatCurrencyWithDouble(double price) {
  String formattedPrice = price.round().toString();
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