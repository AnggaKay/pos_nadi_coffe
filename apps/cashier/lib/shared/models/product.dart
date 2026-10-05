class Product {
  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.icon,
    this.isAvailable = true,
  });

  final String id;
  final String name;
  final String category;
  final int price;
  final String icon;
  final bool isAvailable;
}
