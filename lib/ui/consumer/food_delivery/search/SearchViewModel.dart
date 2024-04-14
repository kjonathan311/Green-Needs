import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:greenneeds/model/SearchFoodProvider.dart';

import '../../../../model/Address.dart';
import '../../../../model/Category.dart';

class SearchViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Address? _selectedAddress;
  Address? get selectedAddress => _selectedAddress;

  set selectedAddress(Address? value) {
    _selectedAddress = value;
    notifyListeners();
  }

  Stream<List<SearchFoodProvider>> get searchItemsStream {
    return _searchController.stream;
  }
  Stream<List<SearchFoodProvider>> get allItemsStream {
    return _displayAllController.stream;
  }

  final _searchController = StreamController<List<SearchFoodProvider>>.broadcast();
  final _displayAllController = StreamController<List<SearchFoodProvider>>.broadcast();

  void searchItems(String query) async {
    final user = _auth.currentUser;
    if (user != null &&
        user.email != null &&
        _selectedAddress != null &&
        query.isNotEmpty) {
      final userLatitude = _selectedAddress!.latitude;
      final userLongitude = _selectedAddress!.longitude;

      final querySnapshot = await _firestore.collection('providers').get();
      List<SearchFoodProvider> results = [];

      for (final providerDoc in querySnapshot.docs) {
        final providerId = providerDoc.id;
        final providerData = providerDoc.data() as Map<String, dynamic>;
        final providerName = providerData['name']?.toLowerCase(); // Add null check here
        final providerPhotoUrl = providerData['photoUrl'];
        final providerRating = providerData['rating'];
        final providerLocation = GeoPoint(providerData['latitude'], providerData['longitude']);
        final providerCity = providerData['city']?.toLowerCase();
        if (providerData['status'] == "verified" && providerCity == _selectedAddress?.city?.toLowerCase()) {
          final productsSnapshot =
          await providerDoc.reference.collection('products').get();

          if (productsSnapshot.docs.isNotEmpty) {
            for (final productDoc in productsSnapshot.docs) {
              final productData = productDoc.data() as Map<String, dynamic>;
              final productCategory = productData['type'];
              final productName = productData['name']?.toLowerCase();

              if (productData.containsKey('type')) {
                if (productCategory == 'ala carte') {
                  final productCategory = productData['category']?.toLowerCase();
                  if (productName != null && productCategory != null && (productName.contains(query.toLowerCase())
                      || productCategory.contains(query.toLowerCase()) || providerName.contains(query.toLowerCase()))) {

                    final distance = await _calculateDistance(
                        userLatitude,
                        userLongitude,
                        providerLocation.latitude,
                        providerLocation.longitude);

                    results.add(SearchFoodProvider(
                      uid: providerId,
                      title: providerData['name'],
                      distance: distance,
                      rating: providerRating,
                      photoUrl: providerPhotoUrl,
                    ));

                    break;
                  }
                } else if (productCategory == 'paket') {
                  final itemsSnapshot =
                  await productDoc.reference.collection('Items').get();
                  for (final itemDoc in itemsSnapshot.docs) {
                    final itemData = itemDoc.data() as Map<String, dynamic>;
                    final itemName = itemData['name']?.toLowerCase();
                    final itemCategory = itemData['category']?.toLowerCase();
                    if (itemName != null && itemCategory != null && (itemName.contains(query.toLowerCase()) ||
                        itemCategory.contains(query.toLowerCase()) || providerName.contains(query.toLowerCase()))) {
                      final distance = await _calculateDistance(
                          userLatitude,
                          userLongitude,
                          providerLocation.latitude,
                          providerLocation.longitude);

                      results.add(SearchFoodProvider(
                        uid: providerId,
                        title: providerData['name'],
                        distance: distance,
                        rating: providerRating,
                        photoUrl: providerPhotoUrl,
                      ));

                      break;
                    }
                  }
                }
              }
            }
          } else {
            if (providerName != null && providerName.contains(query.toLowerCase())) {
              final distance = await _calculateDistance(
                  userLatitude,
                  userLongitude,
                  providerLocation.latitude,
                  providerLocation.longitude);

              results.add(SearchFoodProvider(
                uid: providerId,
                title: providerData['name'],
                distance: distance,
                rating: providerRating,
                photoUrl: providerPhotoUrl,
              ));
            }
          }
        }
      }

      results.sort((a, b) => a.distance.compareTo(b.distance));
      _searchController.add(results);
    } else {
      _searchController.add([]);
    }
  }


  void searchItemsWithCategory(String query) async {
    final user = _auth.currentUser;
    if (user != null &&
        user.email != null &&
        _selectedAddress != null &&
        query.isNotEmpty) {
      final userLatitude = _selectedAddress!.latitude;
      final userLongitude = _selectedAddress!.longitude;

      final querySnapshot = await _firestore.collection('providers').get();
      List<SearchFoodProvider> results = [];

      for (final providerDoc in querySnapshot.docs) {
        final providerId = providerDoc.id;
        final providerData = providerDoc.data() as Map<String, dynamic>;
        final providerPhotoUrl = providerData['photoUrl'];
        final providerRating = providerData['rating'];
        final providerLocation = GeoPoint(providerData['latitude'], providerData['longitude']);
        final providerCity = providerData['city']?.toLowerCase();
        if (providerData['status'] == "verified" && providerCity == _selectedAddress?.city?.toLowerCase()) {
          final productsSnapshot =
          await providerDoc.reference.collection('products').get();

          bool storeHasCategory = false;

          if (productsSnapshot.docs.isNotEmpty) {
            for (final productDoc in productsSnapshot.docs) {
              final productData = productDoc.data() as Map<String, dynamic>;
              final productCategory = productData['type'];
              if (productData.containsKey('type')) {
                if (productCategory == 'ala carte') {
                  final productCategory =
                  productData['category']?.toLowerCase();
                  if (productCategory != null && productCategory.contains(query.toLowerCase())) {
                    storeHasCategory = true;
                    break;
                  }
                } else if (productCategory == 'paket') {
                  final itemsSnapshot =
                  await productDoc.reference.collection('items').get();
                  for (final itemDoc in itemsSnapshot.docs) {
                    final itemData = itemDoc.data() as Map<String, dynamic>;
                    final itemCategory = itemData['category']?.toLowerCase();
                    if (itemCategory != null && itemCategory.contains(query.toLowerCase())) {
                      storeHasCategory = true;
                      break;
                    }
                  }
                }
              }
            }
          }

          if (storeHasCategory) {
            final distance = await _calculateDistance(
                userLatitude,
                userLongitude,
                providerLocation.latitude,
                providerLocation.longitude);

            results.add(SearchFoodProvider(
              uid: providerId,
              title: providerData['name'],
              distance: distance,
              rating: providerRating,
              photoUrl: providerPhotoUrl,
            ));
          }
        }
      }

      results.sort((a, b) => a.distance.compareTo(b.distance));
      _displayAllController.add(results);
    } else {
      _displayAllController.add([]);
    }
  }


  void allItems() async{
    final user = _auth.currentUser;
    if (user != null &&
        user.email != null &&
        _selectedAddress != null) {

      final querySnapshot = await _firestore.collection('providers').get();
      List<SearchFoodProvider> results = [];

      final userLatitude = _selectedAddress!.latitude;
      final userLongitude = _selectedAddress!.longitude;

      for (final providerDoc in querySnapshot.docs) {
        final providerId = providerDoc.id;
        final providerData = providerDoc.data() as Map<String, dynamic>;
        final providerPhotoUrl = providerData['photoUrl'];
        final providerRating = providerData['rating'];
        final providerLocation = GeoPoint(providerData['latitude'], providerData['longitude']);
        if (providerData['status']=="verified") {
          final distance = await _calculateDistance(
              userLatitude,
              userLongitude,
              providerLocation.latitude,
              providerLocation.longitude);

          results.add(SearchFoodProvider(
            uid: providerId,
            title: providerData['name'],
            distance: distance,
            rating: providerRating,
            photoUrl: providerPhotoUrl,
          ));
        }
      }

      results.sort((a, b) => a.title[0].toLowerCase().compareTo(b.title[0].toLowerCase()));
      _displayAllController.add(results);
    } else {
      _displayAllController.add([]);
    }
  }




  Future<double> _calculateDistance(double userLatitude, double userLongitude, double providerLatitude, double providerLongitude) async {
    final distanceInMeters = await Geolocator.distanceBetween(userLatitude, userLongitude, providerLatitude, providerLongitude);
    final distanceInKilometers = double.parse((distanceInMeters / 1000).toStringAsFixed(2));
    return distanceInKilometers;
  }

  Future<List<CategoryItem>?> categoryItems() async {
    User? user = _auth.currentUser;
    if (user != null && user.email != null) {
      final querySnapshot = await _firestore
          .collection('settings_food_waste_categories');
      await for (QuerySnapshot snapshot in querySnapshot.snapshots()) {
        List<CategoryItem> items = [];
        for (QueryDocumentSnapshot doc in snapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          CategoryItem item = CategoryItem(
              uid: doc.id,
              name: data['name'],
              photoUrl: data['photoUrl']
          );
          items.add(item);
        }
        return items;
      }
      return [];
    } else {
      return [];
    }
  }

  void dispose() {
    _searchController.close();
  }
}
