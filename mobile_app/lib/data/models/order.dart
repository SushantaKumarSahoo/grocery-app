enum OrderStatus {
  pending,
  quotationSent,
  accepted,
  preparing,
  ready,
  delivered,
  cancelled,
}

extension OrderStatusX on OrderStatus {
  String get value {
    switch (this) {
      case OrderStatus.pending:
        return 'pending';
      case OrderStatus.quotationSent:
        return 'quotation_sent';
      case OrderStatus.accepted:
        return 'accepted';
      case OrderStatus.preparing:
        return 'preparing';
      case OrderStatus.ready:
        return 'ready';
      case OrderStatus.delivered:
        return 'delivered';
      case OrderStatus.cancelled:
        return 'cancelled';
    }
  }

  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending Review';
      case OrderStatus.quotationSent:
        return 'Quotation Sent';
      case OrderStatus.accepted:
        return 'Accepted';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.ready:
        return 'Ready';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  static OrderStatus fromValue(String? value) {
    return OrderStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () => OrderStatus.pending,
    );
  }
}

class OrderLineItem {
  final String id;
  final String? productId;
  final String productName;
  final double quantity;
  final String unit;
  final double pricePerUnit;
  final String packaging;
  final String notes;

  const OrderLineItem({
    required this.id,
    this.productId,
    required this.productName,
    required this.quantity,
    required this.unit,
    required this.pricePerUnit,
    this.packaging = '',
    this.notes = '',
  });

  double get total => quantity * pricePerUnit;

  factory OrderLineItem.fromMap(Map<String, dynamic> map) {
    return OrderLineItem(
      id: map['id'] as String? ?? '',
      productId: map['product_id'] as String?,
      productName: map['product_name'] as String? ?? '',
      quantity: (map['quantity'] as num?)?.toDouble() ?? 0,
      unit: map['unit'] as String? ?? 'KG',
      pricePerUnit: (map['price_per_unit'] as num?)?.toDouble() ?? 0,
      packaging: map['packaging'] as String? ?? '',
      notes: map['notes'] as String? ?? '',
    );
  }
}

class QuotationLine {
  final String productName;
  final double quantity;
  final String unit;
  final double pricePerUnit;

  const QuotationLine({
    required this.productName,
    required this.quantity,
    required this.unit,
    required this.pricePerUnit,
  });

  double get total => quantity * pricePerUnit;

  factory QuotationLine.fromMap(Map<String, dynamic> map) {
    return QuotationLine(
      productName: map['product_name'] as String? ?? '',
      quantity: (map['quantity'] as num?)?.toDouble() ?? 0,
      unit: map['unit'] as String? ?? 'KG',
      pricePerUnit: (map['price_per_unit'] as num?)?.toDouble() ?? 0,
    );
  }
}

class Quotation {
  final String id;
  final String orderId;
  final List<QuotationLine> lines;
  final double subtotal;
  final double transportCharge;
  final double gstPercent;
  final double gstAmount;
  final double discountAmount;
  final double grandTotal;
  final double advanceAmount;
  final String notes;
  final String status;

  const Quotation({
    required this.id,
    required this.orderId,
    required this.lines,
    required this.subtotal,
    required this.transportCharge,
    required this.gstPercent,
    required this.gstAmount,
    required this.discountAmount,
    required this.grandTotal,
    this.advanceAmount = 0,
    required this.notes,
    required this.status,
  });

  factory Quotation.fromMap(Map<String, dynamic> map) {
    final rawItems = (map['items'] as List?) ?? [];
    return Quotation(
      id: map['id'] as String,
      orderId: map['order_id'] as String? ?? '',
      lines: rawItems
          .map((e) => QuotationLine.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0,
      transportCharge: (map['transport_charge'] as num?)?.toDouble() ?? 0,
      gstPercent: (map['gst_percent'] as num?)?.toDouble() ?? 0,
      gstAmount: (map['gst_amount'] as num?)?.toDouble() ?? 0,
      discountAmount: (map['discount_amount'] as num?)?.toDouble() ?? 0,
      grandTotal: (map['grand_total'] as num?)?.toDouble() ?? 0,
      advanceAmount: (map['advance_amount'] as num?)?.toDouble() ?? 0,
      notes: map['notes'] as String? ?? '',
      status: map['status'] as String? ?? 'draft',
    );
  }
}

class BulkOrder {
  final String id;
  final String shopId;
  final String orderNumber;
  final DateTime createdAt;
  final String occasion;
  final DateTime? eventDate;
  final int expectedGuests;
  final String deliveryAddress;
  final String preferredDeliveryTime;
  final double budget;
  final String additionalNotes;
  final OrderStatus status;
  final double totalAmount;
  final List<OrderLineItem> items;
  final String? paymentMethod;
  final String paymentStatus;
  final double advanceAmount;

  const BulkOrder({
    required this.id,
    required this.shopId,
    required this.orderNumber,
    required this.createdAt,
    required this.occasion,
    this.eventDate,
    required this.expectedGuests,
    required this.deliveryAddress,
    required this.preferredDeliveryTime,
    required this.budget,
    required this.additionalNotes,
    required this.status,
    required this.totalAmount,
    required this.items,
    this.paymentMethod,
    this.paymentStatus = 'not_required',
    this.advanceAmount = 0,
  });

  factory BulkOrder.fromMap(Map<String, dynamic> map) {
    final rawItems = (map['order_items'] as List?) ?? [];
    return BulkOrder(
      id: map['id'] as String,
      shopId: map['shop_id'] as String? ?? '',
      orderNumber: map['order_number'] as String? ?? '',
      createdAt: DateTime.parse(map['created_at'] as String),
      occasion: map['occasion'] as String? ?? '',
      eventDate: map['event_date'] != null
          ? DateTime.tryParse(map['event_date'] as String)
          : null,
      expectedGuests: (map['expected_guests'] as num?)?.toInt() ?? 0,
      deliveryAddress: map['delivery_address'] as String? ?? '',
      preferredDeliveryTime: map['preferred_delivery_time'] as String? ?? '',
      budget: (map['budget'] as num?)?.toDouble() ?? 0,
      additionalNotes: map['additional_notes'] as String? ?? '',
      status: OrderStatusX.fromValue(map['status'] as String?),
      totalAmount: (map['total_amount'] as num?)?.toDouble() ?? 0,
      items: rawItems
          .map((e) => OrderLineItem.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      paymentMethod: map['payment_method'] as String?,
      paymentStatus: map['payment_status'] as String? ?? 'not_required',
      advanceAmount: (map['advance_amount'] as num?)?.toDouble() ?? 0,
    );
  }
}
