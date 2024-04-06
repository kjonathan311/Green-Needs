
class MenuItem {
  final String uid;
  final String name;
  final String category;
  final String description;
  final int startPrice;
  final int discountedPrice;
  final String? photoUrl;

  MenuItem({
    required this.uid,
    required this.name,
    required this.category,
    required this.description,
    required this.startPrice,
    required this.discountedPrice,
    this.photoUrl,
  });
}
