import '../../core/config/supabase_config.dart';
import '../models/app_user.dart';
import '../models/cart_item.dart';
import '../models/event_details.dart';
import '../models/order.dart';

class OrderRepository {
  /// Groups cart items by shop (each product belongs to exactly one shop)
  /// and creates one order per shop, since this is a multi-tenant catalog.
  Future<List<BulkOrder>> submitOrder({
    required List<CartItem> items,
    required EventDetails eventDetails,
    required Profile profile,
  }) async {
    final userId = supabase.auth.currentUser!.id;
    final byShop = <String, List<CartItem>>{};
    for (final item in items) {
      byShop.putIfAbsent(item.product.shopId, () => []).add(item);
    }

    final createdOrders = <BulkOrder>[];

    for (final entry in byShop.entries) {
      final shopId = entry.key;
      final shopItems = entry.value;
      final total = shopItems.fold<double>(0, (sum, i) => sum + i.subtotal);
      final orderNumber = 'ORD-${DateTime.now().millisecondsSinceEpoch}';

      final orderRow = await supabase
          .from('orders')
          .insert({
            'shop_id': shopId,
            'user_id': userId,
            'customer_name': profile.fullName,
            'customer_phone': profile.phone,
            'customer_email': profile.email,
            'occasion': eventDetails.occasion,
            'event_date': eventDetails.eventDate?.toIso8601String(),
            'expected_guests': eventDetails.expectedGuests,
            'delivery_address': eventDetails.deliveryAddress,
            'preferred_delivery_time': eventDetails.preferredDeliveryTime,
            'budget': eventDetails.budget ?? 0,
            'additional_notes': eventDetails.additionalNotes,
            'order_number': orderNumber,
            'status': 'pending',
            'total_amount': total,
          })
          .select()
          .single();

      final orderId = orderRow['id'] as String;

      await supabase.from('order_items').insert(shopItems
          .map((i) => {
                'order_id': orderId,
                'product_id': i.product.id,
                'product_name': i.product.name,
                'quantity': i.quantity,
                'unit': i.product.unit,
                'price_per_unit': i.product.price,
                'total_price': i.subtotal,
                'packaging': i.packaging ?? '',
                'notes': i.notes ?? '',
              })
          .toList());

      await _upsertCustomerRecord(shopId, profile, total);

      createdOrders.add(BulkOrder.fromMap({...orderRow, 'order_items': []}));
    }

    return createdOrders;
  }

  Future<void> _upsertCustomerRecord(
      String shopId, Profile profile, double orderTotal) async {
    try {
      final existing = await supabase
          .from('customers')
          .select('id, total_orders, total_spent')
          .eq('shop_id', shopId)
          .eq('email', profile.email)
          .maybeSingle();

      if (existing == null) {
        await supabase.from('customers').insert({
          'shop_id': shopId,
          'name': profile.fullName,
          'email': profile.email,
          'phone': profile.phone,
          'total_orders': 1,
          'total_spent': orderTotal,
        });
      } else {
        await supabase.from('customers').update({
          'total_orders': ((existing['total_orders'] as num?) ?? 0) + 1,
          'total_spent': ((existing['total_spent'] as num?) ?? 0) + orderTotal,
        }).eq('id', existing['id']);
      }
    } catch (_) {
      // Non-critical CRM sync — never block order submission on this.
    }
  }

  Future<List<BulkOrder>> fetchMyOrders() async {
    final userId = supabase.auth.currentUser!.id;
    final data = await supabase
        .from('orders')
        .select('*, order_items(*)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return (data as List)
        .map((e) => BulkOrder.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<BulkOrder?> fetchOrderById(String id) async {
    final data = await supabase
        .from('orders')
        .select('*, order_items(*)')
        .eq('id', id)
        .maybeSingle();
    if (data == null) return null;
    return BulkOrder.fromMap(Map<String, dynamic>.from(data));
  }

  Future<Quotation?> fetchQuotationForOrder(String orderId) async {
    final data = await supabase
        .from('quotations')
        .select()
        .eq('order_id', orderId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();
    if (data == null) return null;
    return Quotation.fromMap(Map<String, dynamic>.from(data));
  }

  Future<void> updateQuotationStatus(String quotationId, String status) async {
    await supabase.from('quotations').update({'status': status}).eq('id', quotationId);
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await supabase.from('orders').update({'status': status}).eq('id', orderId);
  }

  /// Flags the quotation as needing revision. This is the ONLY way a shop
  /// can send a second quotation for the same order — the admin panel's
  /// "Build Quotation" is gated on this status so an order never ends up
  /// with more than one active quotation without the customer asking for it.
  Future<void> requestQuotationModification(String quotationId, String note) async {
    final data = await supabase
        .from('quotations')
        .select('notes')
        .eq('id', quotationId)
        .single();
    final existingNotes = (data['notes'] as String?) ?? '';
    final updated = existingNotes.isEmpty
        ? 'Customer requested change: $note'
        : '$existingNotes\nCustomer requested change: $note';
    await supabase
        .from('quotations')
        .update({'notes': updated, 'status': 'changes_requested'}).eq('id', quotationId);
  }
}
