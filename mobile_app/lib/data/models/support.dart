enum TicketStatus { open, inProgress, resolved, closed }

extension TicketStatusX on TicketStatus {
  String get value {
    switch (this) {
      case TicketStatus.open:
        return 'open';
      case TicketStatus.inProgress:
        return 'in_progress';
      case TicketStatus.resolved:
        return 'resolved';
      case TicketStatus.closed:
        return 'closed';
    }
  }

  String get label {
    switch (this) {
      case TicketStatus.open:
        return 'Open';
      case TicketStatus.inProgress:
        return 'In Progress';
      case TicketStatus.resolved:
        return 'Resolved';
      case TicketStatus.closed:
        return 'Closed';
    }
  }

  static TicketStatus fromValue(String? value) {
    return TicketStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () => TicketStatus.open,
    );
  }
}

class SupportTicket {
  final String id;
  final String userId;
  final String? shopId;
  final String? orderId;
  final String subject;
  final TicketStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SupportTicket({
    required this.id,
    required this.userId,
    this.shopId,
    this.orderId,
    required this.subject,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Order-related tickets go to the shop's admin; general tickets
  /// (shopId null) go to the platform super admin.
  bool get isShopScoped => shopId != null;

  factory SupportTicket.fromMap(Map<String, dynamic> map) {
    return SupportTicket(
      id: map['id'] as String,
      userId: map['user_id'] as String? ?? '',
      shopId: map['shop_id'] as String?,
      orderId: map['order_id'] as String?,
      subject: map['subject'] as String? ?? 'General Support',
      status: TicketStatusX.fromValue(map['status'] as String?),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String? ?? map['created_at'] as String),
    );
  }
}

class SupportMessage {
  final String id;
  final String ticketId;
  final String senderType; // 'customer' | 'super_admin' | 'shop_admin'
  final String senderName;
  final String message;
  final DateTime createdAt;

  const SupportMessage({
    required this.id,
    required this.ticketId,
    required this.senderType,
    required this.senderName,
    required this.message,
    required this.createdAt,
  });

  bool get isFromCustomer => senderType == 'customer';

  factory SupportMessage.fromMap(Map<String, dynamic> map) {
    return SupportMessage(
      id: map['id'] as String,
      ticketId: map['ticket_id'] as String? ?? '',
      senderType: map['sender_type'] as String? ?? 'customer',
      senderName: map['sender_name'] as String? ?? '',
      message: map['message'] as String? ?? '',
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
