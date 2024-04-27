
class Post {
  final String uid;
  final String title;
  final String description;
  final String name;
  final String? photoUrl;
  final bool status;
  final String uidUser;
  final DateTime date;

  Post({
    required this.uid,
    required this.title,
    required this.description,
    required this.name,
    this.photoUrl,
    required this.status,
    required this.uidUser,
    required this.date,
  });
}