/// Modèle Commande, aligné sur routes/order.js :
/// GET/POST /api/orders renvoie { id, total_price, status, order_date, items: [...] }
class OrderItem {
  final int productId;
  final String name;
  final int quantity;
  final double unitPrice;

  OrderItem({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.unitPrice,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['product_id'] as int,
      name: json['name'] as String? ?? '',
      quantity: int.tryParse(json['quantity'].toString()) ?? 0,
      unitPrice: double.tryParse(json['unit_price'].toString()) ?? 0,
    );
  }
}

class Order {
  final int id;
  final double totalPrice;
  final String status;
  final DateTime orderDate;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.totalPrice,
    required this.status,
    required this.orderDate,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as int,
      totalPrice: double.tryParse(json['total_price'].toString()) ?? 0,
      status: json['status'] as String? ?? '',
      orderDate: DateTime.tryParse(json['order_date'].toString()) ?? DateTime.now(),
      items: (json['items'] as List? ?? [])
          .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
