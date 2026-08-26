import 'package:flutter/material.dart';
import '../data/repositories/payment_repository.dart';

enum PaymentFlowStatus {
  idle,
  startingOnline,
  awaitingGateway,
  confirming,
  succeeded,
  failed,
  submittingOffline,
  offlineConfirmed,
}

/// Drives one payment checkpoint (advance or final) on the payment screen.
/// A fresh instance is created per screen visit — this isn't app-wide state.
class PaymentProvider extends ChangeNotifier {
  final PaymentRepository _repo = PaymentRepository();

  PaymentFlowStatus status = PaymentFlowStatus.idle;
  PaymentSummary? summary;
  PaymentOrderResult? pendingOrder;
  String? errorMessage;

  Future<void> loadSummary(String orderId) async {
    summary = await _repo.fetchPaymentSummary(orderId);
    notifyListeners();
  }

  /// Kicks off the Razorpay order creation for [orderId]/[stage]. Returns
  /// the result so the screen can decide whether a gateway checkout needs
  /// to open (sessionRequired) or the stage was already fully settled.
  Future<PaymentOrderResult?> startOnlinePayment(String orderId, PaymentStage stage) async {
    status = PaymentFlowStatus.startingOnline;
    errorMessage = null;
    notifyListeners();
    try {
      final result = await _repo.createPaymentOrder(orderId, stage);
      pendingOrder = result;
      status = result.sessionRequired ? PaymentFlowStatus.awaitingGateway : PaymentFlowStatus.succeeded;
      notifyListeners();
      return result;
    } catch (e) {
      status = PaymentFlowStatus.failed;
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  /// Called once the Razorpay SDK reports the checkout UI closed
  /// successfully. The SDK callback alone isn't proof of payment — this
  /// polls until the webhook (the real source of truth) confirms it.
  Future<void> confirmAfterGateway(String orderId, PaymentStage stage) async {
    status = PaymentFlowStatus.confirming;
    notifyListeners();
    final result = await _repo.pollUntilResolved(orderId, stage);
    if (result == 'paid') {
      status = PaymentFlowStatus.succeeded;
    } else if (result == 'failed' || result == 'cancelled') {
      status = PaymentFlowStatus.failed;
      errorMessage = 'The payment did not go through. You can try again.';
    } else {
      // Timed out waiting — not necessarily a failure, the webhook may
      // still land shortly. The order detail screen reflects the true
      // state independently, so this isn't a dead end for the customer.
      status = PaymentFlowStatus.failed;
      errorMessage = "Still confirming your payment — check back in a moment.";
    }
    notifyListeners();
  }

  void gatewayDismissedWithError(String message) {
    status = PaymentFlowStatus.failed;
    errorMessage = message;
    notifyListeners();
  }

  Future<void> chooseOfflineMethod(String orderId, PaymentStage stage, String method) async {
    status = PaymentFlowStatus.submittingOffline;
    errorMessage = null;
    notifyListeners();
    try {
      await _repo.selectPaymentMethod(orderId, stage, method);
      status = PaymentFlowStatus.offlineConfirmed;
    } catch (e) {
      status = PaymentFlowStatus.failed;
      errorMessage = e.toString().replaceFirst('Exception: ', '');
    }
    notifyListeners();
  }

  void reset() {
    status = PaymentFlowStatus.idle;
    errorMessage = null;
    pendingOrder = null;
    notifyListeners();
  }
}
