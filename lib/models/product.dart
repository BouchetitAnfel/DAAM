class Product {
  final int? id;
  final String name;
  final String description;
  final double price;
  final int quantity;

  const Product({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
  });

  // MySQL DECIMAL comes back as a string ("250.00") -> parse safely
  factory Product.fromJson(Map<String, dynamic> j) => Product(
        id: int.parse(j['id'].toString()),
        name: (j['name'] ?? '').toString(),
        description: (j['description'] ?? '').toString(),
        price: double.parse(j['price'].toString()),
        quantity: int.parse(j['quantity'].toString()),
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'price': price,
        'quantity': quantity,
      };
}
