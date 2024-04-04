
class InventoryItem {
  final String uid;
  final String name;
  final String category;
  final int quantity;
  final DateTime purchaseDate;
  final DateTime expirationDate;

  InventoryItem({
    required this.uid,
    required this.name,
    required this.category,
    required this.quantity,
    required this.purchaseDate,
    required this.expirationDate,
  });
}