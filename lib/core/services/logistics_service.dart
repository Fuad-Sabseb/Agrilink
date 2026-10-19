import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../models/logistics_model.dart';

class LogisticsService {
  Box<LogisticsModel>? get _logisticsBox =>
      Hive.isBoxOpen('logistics') ? Hive.box<LogisticsModel>('logistics') : null;
  final _uuid = const Uuid();

  Future<LogisticsModel> createLogisticsEntry({
    required String orderId,
    required String transporterId,
    required String notes,
  }) async {
    final box = _logisticsBox ?? await Hive.openBox<LogisticsModel>('logistics');
    final id = _uuid.v4();
    final logistics = LogisticsModel(
      id: id,
      orderId: orderId,
      transporterId: transporterId,
      status: 'awaiting',
      notes: notes,
    );

    await box.put(id, logistics);
    return logistics;
  }

  List<LogisticsModel> getDeliveriesForTransporter(String transporterId) {
    final box = _logisticsBox;
    if (box == null) return [];
    return box.values.where((l) => l.transporterId == transporterId).toList();
  }

  LogisticsModel? getLogisticsByOrderId(String orderId) {
    final box = _logisticsBox;
    if (box == null) return null;
    try {
      return box.values.firstWhere((l) => l.orderId == orderId);
    } catch (e) {
      return null;
    }
  }

  List<LogisticsModel> getDeliveriesForOrder(String orderId) {
    final box = _logisticsBox;
    if (box == null) return [];
    return box.values.where((l) => l.orderId == orderId).toList();
  }

  LogisticsModel? getLogisticsById(String id) {
    return _logisticsBox?.get(id);
  }

  Future<void> updateLogisticsStatus(String id, String status) async {
    final box = _logisticsBox ?? await Hive.openBox<LogisticsModel>('logistics');
    final logistics = getLogisticsById(id);
    if (logistics != null) {
      final updated = LogisticsModel(
        id: logistics.id,
        orderId: logistics.orderId,
        transporterId: logistics.transporterId,
        pickupTime: status == 'in_transit' ? DateTime.now() : logistics.pickupTime,
        deliveryTime: status == 'delivered' ? DateTime.now() : logistics.deliveryTime,
        status: status,
        notes: logistics.notes,
      );
      await box.put(id, updated);
    }
  }
}
