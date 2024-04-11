
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

class Product {
  final MenuItem menuItem;
  int quantity;

  Product({
    required this.menuItem,
    this.quantity = 0,
  });
}

class Paket{
  final List<Product> products;
  final String uid;
  final String name;
  final int price;
  int quantity;

  Paket({
    required this.uid,
    required this.products,
    required this.name,
    required this.price,
    this.quantity = 0,
  });
}