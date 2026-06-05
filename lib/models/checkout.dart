class CheckoutItem {
  final String id;
  final String name;
  final int quantity;
  final double price;
  final String store_id;
  final String store_name;

  CheckoutItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price,
    required this.store_id,
    required this.store_name,
  });

  factory CheckoutItem.fromJson(Map<String, dynamic> json) {
    return CheckoutItem(
      id: json['id'],
      name: json['name'],
      quantity: json['quantity'],
      price: double.parse(json['price'].toString()),
      store_id: json['store_id'],
      store_name: json['store_name'],
    );
  }
}

class CheckoutSummaryResponse {
  final double subtotal;
  final double service_fee;
  final double delivery_fee;
  final double total;
  final List<CheckoutItem> items;

  CheckoutSummaryResponse({
    required this.subtotal,
    required this.service_fee,
    required this.delivery_fee,
    required this.total,
    required this.items,
  });

  factory CheckoutSummaryResponse.fromJson(Map<String, dynamic> json) {
    return CheckoutSummaryResponse(
      subtotal: (json['subtotal'] as num).toDouble(),
      service_fee: (json['service_fee'] as num).toDouble(),
      delivery_fee: (json['delivery_fee'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      items: (json['items'] as List)
          .map((item) => CheckoutItem.fromJson(item))
          .toList(),
    );
  }
}

class CheckoutResponse {
  final String payment_link;
  final String? order_id;

  CheckoutResponse({required this.payment_link, this.order_id});

  factory CheckoutResponse.fromJson(Map<String, dynamic> json) {
    return CheckoutResponse(
      payment_link: json['payment_link'],
      order_id: json['order_id'],
    );
  }
}