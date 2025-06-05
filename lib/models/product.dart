class Product {
  final String name;
  final String description;
  final double price;
  final String category; // أضف هذا السطر
  final String imageUrl;
  final int stock;
  final String manufacturer;

  Product({
    required this.name,
    required this.description,
    required this.price,
    required this.category, // أضف هذا السطر
    required this.imageUrl,
    required this.stock,
    required this.manufacturer,
  });
}