class Product {
  String name; 
  double price;
  String description;
  String category;
  String? imagePath;

  Product({
    required this.name,
    required this.price,
    required this.description,
    required this.category,
    this.imagePath,
  });
}