import 'package:hive/hive.dart';

part 'route_model.g.dart';

/// Route Model
/// Represents a transport route with cost transparency and checkpoint fee logs
@HiveType(typeId: 9)
class Route {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String origin;

  @HiveField(2)
  final String destination;

  @HiveField(3)
  final double distanceKm;

  @HiveField(4)
  final double baseCostPerKm; // Base transport cost per km

  @HiveField(5)
  final double costPerTonKm; // Additional cost per ton-km

  @HiveField(6)
  final List<Checkpoint> checkpoints;

  @HiveField(7)
  final double estimatedDurationHours;

  @HiveField(8)
  final RouteCondition condition;

  @HiveField(9)
  final DateTime? lastUpdated;

  Route({
    required this.id,
    required this.origin,
    required this.destination,
    required this.distanceKm,
    this.baseCostPerKm = 10.0,
    this.costPerTonKm = 5.0,
    this.checkpoints = const [],
    required this.estimatedDurationHours,
    this.condition = RouteCondition.good,
    this.lastUpdated,
  });

  /// Get route name (Origin-Destination)
  String get routeName => '$origin-$destination';

  /// Get reverse route name
  String get reverseRouteName => '$destination-$origin';

  /// Calculate total checkpoint fees
  double get totalCheckpointFees {
    return checkpoints.fold(0.0, (sum, checkpoint) => sum + checkpoint.fee);
  }

  /// Calculate base transport cost (distance-based, no weight)
  double get baseTransportCost {
    return distanceKm * baseCostPerKm;
  }

  /// Calculate total transport cost for a given weight in tons
  double calculateTotalCost(double weightTons) {
    final baseTransport = baseTransportCost;
    final weightBasedCost = distanceKm * weightTons * costPerTonKm;
    final checkpointTotal = totalCheckpointFees;
    return baseTransport + weightBasedCost + checkpointTotal;
  }

  /// Calculate cost breakdown for transparency
  RouteCostBreakdown calculateCostBreakdown(double weightTons) {
    return RouteCostBreakdown(
      baseTransportCost: baseTransportCost,
      weightBasedCost: distanceKm * weightTons * costPerTonKm,
      checkpointFees: totalCheckpointFees,
      totalCost: calculateTotalCost(weightTons),
      checkpoints: checkpoints,
    );
  }

  /// Get estimated arrival time from departure
  DateTime getEstimatedArrival(DateTime departureTime) {
    return departureTime.add(Duration(
      hours: estimatedDurationHours.floor(),
      minutes: ((estimatedDurationHours % 1) * 60).round(),
    ));
  }

  /// Create a copy with updated fields
  Route copyWith({
    String? origin,
    String? destination,
    double? distanceKm,
    double? baseCostPerKm,
    double? costPerTonKm,
    List<Checkpoint>? checkpoints,
    double? estimatedDurationHours,
    RouteCondition? condition,
    DateTime? lastUpdated,
  }) {
    return Route(
      id: id,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      distanceKm: distanceKm ?? this.distanceKm,
      baseCostPerKm: baseCostPerKm ?? this.baseCostPerKm,
      costPerTonKm: costPerTonKm ?? this.costPerTonKm,
      checkpoints: checkpoints ?? this.checkpoints,
      estimatedDurationHours:
          estimatedDurationHours ?? this.estimatedDurationHours,
      condition: condition ?? this.condition,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'origin': origin,
      'destination': destination,
      'distanceKm': distanceKm,
      'baseCostPerKm': baseCostPerKm,
      'costPerTonKm': costPerTonKm,
      'checkpoints': checkpoints.map((c) => c.toJson()).toList(),
      'estimatedDurationHours': estimatedDurationHours,
      'condition': condition.name,
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  /// Create from JSON
  factory Route.fromJson(Map<String, dynamic> json) {
    return Route(
      id: json['id'] as String,
      origin: json['origin'] as String,
      destination: json['destination'] as String,
      distanceKm: (json['distanceKm'] as num).toDouble(),
      baseCostPerKm: (json['baseCostPerKm'] as num?)?.toDouble() ?? 10.0,
      costPerTonKm: (json['costPerTonKm'] as num?)?.toDouble() ?? 5.0,
      checkpoints: (json['checkpoints'] as List<dynamic>?)
              ?.map((c) => Checkpoint.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
      estimatedDurationHours:
          (json['estimatedDurationHours'] as num).toDouble(),
      condition: RouteCondition.values.firstWhere(
        (e) => e.name == json['condition'],
        orElse: () => RouteCondition.good,
      ),
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : null,
    );
  }
}

/// Checkpoint Model
/// Represents a checkpoint/toll point with fee transparency
@HiveType(typeId: 16)
class Checkpoint {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final double distanceFromOriginKm;

  @HiveField(2)
  final double fee; // Fee in ETB

  @HiveField(3)
  final CheckpointType type;

  @HiveField(4)
  final String? description;

  Checkpoint({
    required this.name,
    required this.distanceFromOriginKm,
    required this.fee,
    this.type = CheckpointType.inspection,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'distanceFromOriginKm': distanceFromOriginKm,
      'fee': fee,
      'type': type.name,
      'description': description,
    };
  }

  factory Checkpoint.fromJson(Map<String, dynamic> json) {
    return Checkpoint(
      name: json['name'] as String,
      distanceFromOriginKm: (json['distanceFromOriginKm'] as num).toDouble(),
      fee: (json['fee'] as num).toDouble(),
      type: CheckpointType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => CheckpointType.inspection,
      ),
      description: json['description'] as String?,
    );
  }
}

/// Route Cost Breakdown - For transparency display
class RouteCostBreakdown {
  final double baseTransportCost;
  final double weightBasedCost;
  final double checkpointFees;
  final double totalCost;
  final List<Checkpoint> checkpoints;

  RouteCostBreakdown({
    required this.baseTransportCost,
    required this.weightBasedCost,
    required this.checkpointFees,
    required this.totalCost,
    required this.checkpoints,
  });

  /// Get cost breakdown items for display
  List<CostLineItem> get lineItems {
    return [
      CostLineItem(
        label: 'Base Transport',
        amount: baseTransportCost,
        icon: '🚚',
      ),
      CostLineItem(
        label: 'Weight-Based Cost',
        amount: weightBasedCost,
        icon: '⚖️',
      ),
      ...checkpoints.map((checkpoint) => CostLineItem(
            label: checkpoint.name,
            amount: checkpoint.fee,
            icon: '🛂',
            isCheckpoint: true,
          )),
    ];
  }
}

/// Cost Line Item - For breakdown display
class CostLineItem {
  final String label;
  final double amount;
  final String icon;
  final bool isCheckpoint;

  CostLineItem({
    required this.label,
    required this.amount,
    required this.icon,
    this.isCheckpoint = false,
  });
}

/// Route Condition Enum
@HiveType(typeId: 17)
enum RouteCondition {
  @HiveField(0)
  excellent, // Paved, well-maintained

  @HiveField(1)
  good, // Mostly paved, minor issues

  @HiveField(2)
  fair, // Mix of paved/unpaved

  @HiveField(3)
  poor, // Mostly unpaved, difficult

  @HiveField(4)
  seasonal, // Depends on weather
}

/// Checkpoint Type Enum
@HiveType(typeId: 18)
enum CheckpointType {
  @HiveField(0)
  inspection, // Agricultural inspection

  @HiveField(1)
  toll, // Road toll

  @HiveField(2)
  weighbridge, // Weight check station

  @HiveField(3)
  police, // Police checkpoint
}

/// Extension for route condition display
extension RouteConditionExtension on RouteCondition {
  String get displayName {
    switch (this) {
      case RouteCondition.excellent:
        return 'Excellent';
      case RouteCondition.good:
        return 'Good';
      case RouteCondition.fair:
        return 'Fair';
      case RouteCondition.poor:
        return 'Poor';
      case RouteCondition.seasonal:
        return 'Seasonal';
    }
  }

  String get color {
    switch (this) {
      case RouteCondition.excellent:
        return '#28A745';
      case RouteCondition.good:
        return '#5CB85C';
      case RouteCondition.fair:
        return '#FFC107';
      case RouteCondition.poor:
        return '#FF5722';
      case RouteCondition.seasonal:
        return '#17A2B8';
    }
  }

  String get icon {
    switch (this) {
      case RouteCondition.excellent:
        return '✅';
      case RouteCondition.good:
        return '👍';
      case RouteCondition.fair:
        return '⚠️';
      case RouteCondition.poor:
        return '❌';
      case RouteCondition.seasonal:
        return '🌦️';
    }
  }
}

/// Extension for checkpoint type display
extension CheckpointTypeExtension on CheckpointType {
  String get displayName {
    switch (this) {
      case CheckpointType.inspection:
        return 'Inspection';
      case CheckpointType.toll:
        return 'Toll';
      case CheckpointType.weighbridge:
        return 'Weighbridge';
      case CheckpointType.police:
        return 'Police';
    }
  }

  String get icon {
    switch (this) {
      case CheckpointType.inspection:
        return '🔍';
      case CheckpointType.toll:
        return '💰';
      case CheckpointType.weighbridge:
        return '⚖️';
      case CheckpointType.police:
        return '👮';
    }
  }
}
