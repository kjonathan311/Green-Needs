

abstract class Profile {
  String get uid;
  String get name;
  String get email;
  String get phoneNumber;
}

class ConsumerProfile extends Profile {
  final String uid;
  final String name;
  final String email;
  final String phoneNumber;
  final String? photoUrl;

  ConsumerProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.photoUrl,
  });
}

class FoodProviderProfile extends Profile {
  final String uid;
  final String name;
  final String email;
  final String phoneNumber;
  final String address;
  final String city;
  final String? status;
  final String? postalcode;
  final double? rating;
  final String? photoUrl;
  final double? longitude;
  final double? latitude;

  FoodProviderProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.city,
    this.status,
    this.rating,
    this.postalcode,
    this.photoUrl,
    this.longitude,
    this.latitude
  });
}