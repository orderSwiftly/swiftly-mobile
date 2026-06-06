// models/checkout.dart

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
  final String tx_reference; // Changed: added tx_reference, removed order_id
  final String?
  order_id; // Keep for backward compatibility, but will likely be removed

  CheckoutResponse({
    required this.payment_link,
    required this.tx_reference,
    this.order_id,
  });

  factory CheckoutResponse.fromJson(Map<String, dynamic> json) {
    return CheckoutResponse(
      payment_link: json['payment_link'],
      tx_reference: json['tx_reference'],
      order_id: json['order_id'], // May be null or removed in future
    );
  }
}

// New model for payment verification response
class PaymentVerificationResponse {
  final String status; // Can be: PENDING, PAID, FAILED, ABANDONED

  PaymentVerificationResponse({required this.status});

  factory PaymentVerificationResponse.fromJson(Map<String, dynamic> json) {
    return PaymentVerificationResponse(status: json['status']);
  }

  bool get isPaid => status == 'PAID';
  bool get isPending => status == 'PENDING';
  bool get isFailed => status == 'FAILED';
  bool get isAbandoned => status == 'ABANDONED';
}
