
class MenuItem {
  final String uid;
  final String name;
  final String category;
  final String? description;
  final int startPrice;
  final int discountedPrice;
  final String? photoUrl;

  MenuItem({
    required this.uid,
    required this.name,
    required this.category,
    this.description,
    required this.startPrice,
    required this.discountedPrice,
    this.photoUrl,
  });
}

class Product {
  final String uid;
  final MenuItem menuItem;
  int quantity;
  bool status;

  Product({
    required this.uid,
    required this.menuItem,
    this.quantity = 0,
    this.status=true,
  });
}

class Paket{
  final List<Product> products;
  final String uid;
  final String name;
  final int startPrice;
  final int discountedPrice;
  bool status;
  int quantity;

  Paket({
    required this.uid,
    required this.products,
    required this.name,
    required this.startPrice,
    required this.discountedPrice,
    this.quantity = 0,
    this.status=true,
  });
}