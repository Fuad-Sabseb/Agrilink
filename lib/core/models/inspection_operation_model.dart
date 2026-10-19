import 'package:hive/hive.dart';

part 'inspection_operation_model.g.dart';

/// Inspection Operation Model
/// Represents an offline operation to be synced when online
/// Requirements: 13.1-13.11, 14.8-14.10
@HiveType(typeId: 31)
class InspectionOperation {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final InspectionOperationType type;

  @HiveField(2)
  final Map<String, dynamic> data;

  @HiveField(3)
  final DateTime timestamp;

  @HiveField(4)
  final int retryCount;

  InspectionOperation({
    required this.id,
    required this.type,
    required this.data,
    required this.timestamp,
    this.retryCount = 0,
  });

  /// Create a copy with updated fields
  InspectionOperation copyWith({
    int? retryCount,
  }) {
    return InspectionOperation(
      id: id,
      type: type,
      data: data,
      timestamp: timestamp,
      retryCount: retryCount ?? this.retryCount,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'retryCount': retryCount,
    };
  }

  /// Create from JSON
  factory InspectionOperation.fromJson(Map<String, dynamic> json) {
    return InspectionOperation(
      id: json['id'] as String,
      type: InspectionOperationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => InspectionOperationType.createInspection,
      ),
      data: Map<String, dynamic>.from(json['data'] as Map),
      timestamp: DateTime.parse(json['timestamp'] as String),
      retryCount: json['retryCount'] as int? ?? 0,
    );
  }
}

/// Inspection Operation Type Enum
@HiveType(typeId: 32)
enum InspectionOperationType {
  @HiveField(0)
  createInspection,
  @HiveField(1)
  checkIn,
  @HiveField(2)
  addFinding,
  @HiveField(3)
  updateFinding,
  @HiveField(4)
  deleteFinding,
  @HiveField(5)
  uploadPhoto,
  @HiveField(6)
  completeInspection,
}
