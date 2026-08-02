import '../../core/config/supabase_config.dart';
import '../models/support.dart';

class SupportRepository {
  Future<List<SupportTicket>> fetchMyTickets() async {
    final userId = supabase.auth.currentUser!.id;
    final data = await supabase
        .from('support_tickets')
        .select()
        .eq('user_id', userId)
        .order('updated_at', ascending: false);
    return (data as List)
        .map((e) => SupportTicket.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<SupportTicket> createTicket({
    required String subject,
    required String firstMessage,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
  }) async {
    final userId = supabase.auth.currentUser!.id;
    final ticketRow = await supabase
        .from('support_tickets')
        .insert({
          'user_id': userId,
          'subject': subject,
          'customer_name': customerName,
          'customer_email': customerEmail,
          'customer_phone': customerPhone,
          'status': 'open',
        })
        .select()
        .single();
    final ticket = SupportTicket.fromMap(ticketRow);
    await sendMessage(
      ticketId: ticket.id,
      message: firstMessage,
      senderType: 'customer',
      senderName: customerName,
    );
    return ticket;
  }

  /// Order-related support goes to the shop that owns the order, not the
  /// platform super admin. Reuses an existing ticket for the order if the
  /// customer already opened one, so repeat taps don't spawn duplicates.
  Future<SupportTicket> findOrCreateOrderTicket({
    required String orderId,
    required String shopId,
    required String orderNumber,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
  }) async {
    final userId = supabase.auth.currentUser!.id;
    final existing = await supabase
        .from('support_tickets')
        .select()
        .eq('order_id', orderId)
        .eq('user_id', userId)
        .maybeSingle();
    if (existing != null) return SupportTicket.fromMap(existing);

    final ticketRow = await supabase
        .from('support_tickets')
        .insert({
          'user_id': userId,
          'shop_id': shopId,
          'order_id': orderId,
          'subject': 'Order $orderNumber',
          'customer_name': customerName,
          'customer_email': customerEmail,
          'customer_phone': customerPhone,
          'status': 'open',
        })
        .select()
        .single();
    return SupportTicket.fromMap(ticketRow);
  }

  Future<void> sendMessage({
    required String ticketId,
    required String message,
    required String senderType,
    required String senderName,
  }) async {
    await supabase.from('support_messages').insert({
      'ticket_id': ticketId,
      'message': message,
      'sender_type': senderType,
      'sender_name': senderName,
    });
  }

  Future<List<SupportMessage>> fetchMessages(String ticketId) async {
    final data = await supabase
        .from('support_messages')
        .select()
        .eq('ticket_id', ticketId)
        .order('created_at');
    return (data as List)
        .map((e) => SupportMessage.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// Live-updating stream of a ticket's messages, oldest first.
  Stream<List<SupportMessage>> watchMessages(String ticketId) {
    return supabase
        .from('support_messages')
        .stream(primaryKey: ['id'])
        .eq('ticket_id', ticketId)
        .order('created_at')
        .map((rows) => rows.map((e) => SupportMessage.fromMap(e)).toList());
  }
}
