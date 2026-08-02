import 'package:flutter/material.dart';
import '../data/models/app_user.dart';
import '../data/models/cart_item.dart';
import '../data/models/event_details.dart';
import '../data/models/order.dart';
import '../data/repositories/order_repository.dart';

class OrderProvider extends ChangeNotifier {
  final OrderRepository _repo = OrderRepository();

  bool loading = false;
  String? error;
  List<BulkOrder> orders = [];

  Future<void> loadMyOrders() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      orders = await _repo.fetchMyOrders();
    } catch (e) {
      error = 'Could not load your orders. Pull down to retry.';
    }
    loading = false;
    notifyListeners();
  }

  Future<List<BulkOrder>> submitOrder({
    required List<CartItem> items,
    required EventDetails eventDetails,
    required Profile profile,
  }) async {
    final created = await _repo.submitOrder(
      items: items,
      eventDetails: eventDetails,
      profile: profile,
    );
    await loadMyOrders();
    return created;
  }

  Future<BulkOrder?> fetchOrderById(String id) => _repo.fetchOrderById(id);

  Future<Quotation?> fetchQuotation(String orderId) =>
      _repo.fetchQuotationForOrder(orderId);

  Future<void> acceptQuotation(Quotation quotation, String orderId) async {
    await _repo.updateQuotationStatus(quotation.id, 'accepted');
    await _repo.updateOrderStatus(orderId, 'accepted');
    await loadMyOrders();
  }

  Future<void> rejectQuotation(Quotation quotation, String orderId) async {
    await _repo.updateQuotationStatus(quotation.id, 'rejected');
    await _repo.updateOrderStatus(orderId, 'cancelled');
    await loadMyOrders();
  }

  Future<void> requestModification(String quotationId, String note) async {
    await _repo.requestQuotationModification(quotationId, note);
  }

  BulkOrder? byId(String id) {
    try {
      return orders.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }
}
