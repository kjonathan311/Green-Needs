

abstract class Profile {
  String get uid;
  String get name;
  String get email;
  String get phoneNumber;
}

class ConsumerProfile extends Profile {
  final String _uid;
  final String _name;
  final String _email;
  final String _phoneNumber;
  final String? _photoUrl;

  ConsumerProfile({
    required String uid,
    required String name,
    required String email,
    required String phoneNumber,
    String? photoUrl,
  })   : _uid = uid,
        _name = name,
        _email = email,
        _phoneNumber = phoneNumber,
        _photoUrl = photoUrl;

  @override
  String get name => _name;

  @override
  String get email => _email;

  @override
  String get phoneNumber => _phoneNumber;

  String? get photoUrl => _photoUrl;

  @override
  String get uid => _uid;
}

class FoodProviderProfile extends Profile {
  final String _uid;
  final String _name;
  final String _email;
  final String _phoneNumber;
  final String _address;
  final String _city;
  final String _status;
  final String? _photoUrl;

  FoodProviderProfile({
    required String uid,
    required String name,
    required String email,
    required String phoneNumber,
    required String address,
    required String city,
    required String status,
    String? photoUrl,
  })   :_uid=uid,
        _name = name,
        _email = email,
        _phoneNumber = phoneNumber,
        _address= address,
        _city= city,
        _status= status,
        _photoUrl = photoUrl;

  @override
  String get name => _name;

  @override
  String get email => _email;

  @override
  String get phoneNumber => _phoneNumber;

  String? get photoUrl => _photoUrl;
  String? get address => _address;
  String? get city => _city;
  String? get status => _status;

  @override
  String get uid => _uid;
}