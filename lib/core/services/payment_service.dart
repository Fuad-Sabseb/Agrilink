import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../models/payment_model.dart';

class PaymentService {
  Box<PaymentModel>? get _paymentBox =>
      Hive.isBoxOpen('payments') ? Hive.box<PaymentModel>('payments') : null;
  final _uuid = const Uuid();

  Future<PaymentModel> recordPayment({
    required String orderId,
    required double amount,
    required String method,
  }) async {
    final box = _paymentBox ?? await Hive.openBox<PaymentModel>('payments');
    final id = _uuid.v4();
    final payment = PaymentModel(
      id: id,
      orderId: orderId,
      amount: amount,
      method: method,
      status: 'completed',
      paidAt: DateTime.now(),
    );

    await box.put(id, payment);
    return payment;
  }

  List<PaymentModel> getPaymentsForOrder(String orderId) {
    final box = _paymentBox;
    if (box == null) return [];
    return box.values.where((p) => p.orderId == orderId).toList();
  }

  PaymentModel? getPaymentById(String id) {
    return _paymentBox?.get(id);
  }
}
