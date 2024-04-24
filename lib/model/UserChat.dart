class UserChat {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final String type;
  final String transactionId;

  const UserChat({
    required this.name,
    this.photoUrl,
    required this.uid,
    required this.email,
    required this.type,
    required this.transactionId,
  });
}