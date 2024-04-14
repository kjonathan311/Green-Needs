
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:greenneeds/model/Address.dart';
import 'package:greenneeds/ui/utils.dart';

class AddressViewModel extends ChangeNotifier{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int _selectedIndex = -1;
  int get selectedIndex => _selectedIndex;

  Address? _selectedAddress;
  Address? get selectedAddress => _selectedAddress;

  List<Address> _addresses = [];
  List<Address> get addresses => _addresses;


  Stream<List<Address>> addressItems() async* {
    User? user = _auth.currentUser;
    if (user != null && user.email != null) {
      CollectionReference inventoryCollectionRef =
      _firestore.collection('consumers').doc(user.uid).collection('addresses');
      await for (QuerySnapshot snapshot in inventoryCollectionRef.snapshots()) {
        _addresses.clear();
        for (QueryDocumentSnapshot doc in snapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          Address item = Address(
              uid: doc.id,
              address: data['address'],
              longitude: data['longitude'],
              latitude: data['latitude'],
              postalcode: data['postalcode'],
              city: data['city'],
          );
          _addresses.add(item);
        }

        yield _addresses;
      }
    } else {
      yield [];
    }
  }

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void selectAddress(BuildContext context){
    if (_selectedIndex != -1 && _selectedIndex < _addresses.length) {
      _selectedAddress = _addresses[_selectedIndex];
    } else {
      showCustomSnackBar(context, "pilih alamat diatas.", color: Colors.red);
    }
    notifyListeners();
    print(_selectedAddress!.address.toString());
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }


  Future<void> addAddress(BuildContext context,String address,String city)async{
    User? user = _auth.currentUser;
    _isLoading = true;
    notifyListeners();
    if (user != null && user.email != null) {

      if (address.isEmpty || city.isEmpty) {
        showCustomSnackBar(context, "Semua field perlu diisi.", color: Colors.red);

        _isLoading = false;
        notifyListeners();
        return;
      }

      DocumentReference documentRef = _firestore.collection('consumers').doc(
          user.uid);

      try{
        city = city.toLowerCase();
        city = city.substring(0, 1).toUpperCase() + city.substring(1);

        List<Location> checklocal = await locationFromAddress('$city');

        List<Location> checkLoc = await locationFromAddress('$address');

        List<Location> locations = await locationFromAddress('$address, $city');
        double lat = locations[0].latitude;
        double lng = locations[0].longitude;

        List<Placemark> placemarks = await placemarkFromCoordinates(lat,lng);
        String? postalcode= placemarks[0].postalCode;

        Map<String, dynamic> addressData = {
          'address': address,
          'latitude': lat,
          'longitude': lng,
          if(postalcode!=null) 'postalcode':postalcode,
          'city': city,
        };
        await documentRef.collection('addresses').add(addressData);
      }catch(e){
        _isLoading = false;
        notifyListeners();
      }

      Navigator.of(context).pop();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteAddress(BuildContext context,String uid)async {
    User? user = _auth.currentUser;
    _isLoading = true;
    notifyListeners();
    if (user != null && user.email != null) {
      await _firestore.collection('consumers').doc(user.uid).collection('addresses').doc(uid).delete();
    }
    _isLoading = false;
    notifyListeners();
  }
  void clearData(){
    _selectedAddress=null;
    notifyListeners();
  }


}