import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/supabase_config.dart';

class PaymentOrderResult {
  final bool sessionRequired;
  final String? razorpayKeyId;
  final String? razorpayOrderId;
  final String? customerEmail;
  final String? customerPhone;
  final double amount;

  const PaymentOrderResult({
    required this.sessionRequired,
    this.razorpayKeyId,
    this.razorpayOrderId,
    this.customerEmail,
    this.customerPhone,
    required this.amount,
  });

  factory PaymentOrderResult.fromMap(Map<String, dynamic> map) {
    return PaymentOrderResult(
      sessionRequired: map['sessionRequired'] as bool? ?? false,
      razorpayKeyId: map['razorpayKeyId'] as String?,
      razorpayOrderId: map['razorpayOrderId'] as String?,
      customerEmail: map['customerEmail'] as String?,
      customerPhone: map['customerPhone'] as String?,
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
    );
  }
}

class PaymentSummary {
  final double grandTotal;
  final double advanceAmount;
  final double totalPaid;
  final double remainingAmount;
  final bool advanceSettled;
  final bool fullySettled;

  const PaymentSummary({
    required this.grandTotal,
    required this.advanceAmount,
    required this.totalPaid,
    required this.remainingAmount,
    required this.advanceSettled,
    required this.fullySettled,
  });

  factory PaymentSummary.fromMap(Map<String, dynamic> map) {
    return PaymentSummary(
      grandTotal: (map['grand_total'] as num?)?.toDouble() ?? 0,
      advanceAmount: (map['advance_amount'] as num?)?.toDouble() ?? 0,
      totalPaid: (map['total_paid'] as num?)?.toDouble() ?? 0,
      remainingAmount: (map['remaining_amount'] as num?)?.toDouble() ?? 0,
      advanceSettled: map['advance_settled'] as bool? ?? false,
      fullySettled: map['fully_settled'] as bool? ?? false,
    );
  }
}

/// Stage of the two payment checkpoints — right after quotation
/// acceptance ('advance') and right before delivery completes ('final').
/// Both use the same Edge Functions, just with a different amount and a
/// different order-status gate, resolved entirely server-side.
enum PaymentStage { advance, final_ }

extension PaymentStageX on PaymentStage {
  String get value => this == PaymentStage.advance ? 'advance' : 'final';
}

class PaymentRepository {
  Future<PaymentOrderResult> createPaymentOrder(String orderId, PaymentStage stage) async {
    try {
      final res = await supabase.functions.invoke(
        'create-payment-order',
        body: {'order_id': orderId, 'stage': stage.value},
      );
      return PaymentOrderResult.fromMap(Map<String, dynamic>.from(res.data as Map));
    } on FunctionException catch (e) {
      throw Exception(_messageFrom(e));
    }
  }

  Future<void> selectPaymentMethod(String orderId, PaymentStage stage, String method) async {
    try {
      await supabase.functions.invoke(
        'select-payment-method',
        body: {'order_id': orderId, 'stage': stage.value, 'method': method},
      );
    } on FunctionException catch (e) {
      throw Exception(_messageFrom(e));
    }
  }

  Future<PaymentSummary?> fetchPaymentSummary(String orderId) async {
    final data = await supabase
        .from('order_payment_summary')
        .select()
        .eq('order_id', orderId)
        .maybeSingle();
    if (data == null) return null;
    return PaymentSummary.fromMap(Map<String, dynamic>.from(data));
  }

  Future<String?> _latestPaymentStatus(String orderId, PaymentStage stage) async {
    final data = await supabase
        .from('payments')
        .select('status')
        .eq('order_id', orderId)
        .eq('purpose', stage.value)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();
    return data?['status'] as String?;
  }

  /// Polls the latest payment attempt for [orderId]/[stage] until it
  /// resolves to paid/failed/cancelled, or [timeout] elapses (returns
  /// 'timeout' in that case) — the webhook is the actual source of truth,
  /// this just waits for it to catch up after the gateway UI closes.
  Future<String> pollUntilResolved(
    String orderId,
    PaymentStage stage, {
    Duration timeout = const Duration(seconds: 45),
    Duration interval = const Duration(seconds: 2),
  }) async {
    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      final status = await _latestPaymentStatus(orderId, stage);
      if (status == 'paid' || status == 'failed' || status == 'cancelled') {
        return status!;
      }
      await Future.delayed(interval);
    }
    return 'timeout';
  }

  String _messageFrom(FunctionException e) {
    final details = e.details;
    if (details is Map && details['error'] is String) return details['error'] as String;
    return 'Something went wrong. Please try again.';
  }
}
