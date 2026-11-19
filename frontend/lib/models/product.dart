/// Modèle Produit, aligné sur les colonnes retournées par
/// GET /api/products et /api/products/:id (routes/products.js) :
/// { id, name, description, price, quantity }
class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final int quantity;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0,
      quantity: int.tryParse(json['quantity'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'price': price,
        'quantity': quantity,
      };

  bool get inStock => quantity > 0;

  Product copyWith({
    int? id,
    String? name,
    String? description,
    double? price,
    int? quantity,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
    );
  }
}
