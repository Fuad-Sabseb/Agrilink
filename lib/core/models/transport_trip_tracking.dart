import 'package:hive/hive.dart';
import 'location_coordinate.dart';

part 'transport_trip_tracking.g.dart';

@HiveType(typeId: 14)
class TransportTripTracking extends HiveObject {
  @HiveField(0)
  final String tripId;

  @HiveField(1)
  final String transporterId;

  @HiveField(2)
  final double startLatitude;

  @HiveField(3)
  final double startLongitude;

  @HiveField(4)
  final double destinationLatitude;

  @HiveField(5)
  final double destinationLongitude;

  @HiveField(6)
  final DateTime startTime;

  @HiveField(7)
  final List<String> locationHistoryIds;

  @HiveField(8)
  final int statusIndex;

  @HiveField(9)
  final int trackingIntervalSeconds;

  TransportTripTracking({
    required this.tripId,
    required this.transporterId,
    required this.startLatitude,
    required this.startLongitude,
    required this.destinationLatitude,
    required this.destinationLongitude,
    required this.startTime,
    this.locationHistoryIds = const [],
    TripStatus status = TripStatus.active,
    this.trackingIntervalSeconds = 30,
  }) : statusIndex = status.index;

  LocationCoordinate get startLocation => LocationCoordinate(
        latitude: startLatitude,
        longitude: startLongitude,
        timestamp: startTime,
      );

  LocationCoordinate get destinationLocation => LocationCoordinate(
        latitude: destinationLatitude,
        longitude: destinationLongitude,
      );

  TripStatus get status => TripStatus.values[statusIndex];

  Map<String, dynamic> toJson() => {
        'trip_id': tripId,
        'transporter_id': transporterId,
        'start_latitude': startLatitude,
        'start_longitude': startLongitude,
        'destination_latitude': destinationLatitude,
        'destination_longitude': destinationLongitude,
        'start_time': startTime.toIso8601String(),
        'location_history_ids': locationHistoryIds,
        'status': status.name,
        'tracking_interval_seconds': trackingIntervalSeconds,
      };

  factory TransportTripTracking.fromJson(Map<String, dynamic> json) {
    return TransportTripTracking(
      tripId: json['trip_id'] as String,
      transporterId: json['transporter_id'] as String,
      startLatitude: (json['start_latitude'] as num).toDouble(),
      startLongitude: (json['start_longitude'] as num).toDouble(),
      destinationLatitude: (json['destination_latitude'] as num).toDouble(),
      destinationLongitude: (json['destination_longitude'] as num).toDouble(),
      startTime: DateTime.parse(json['start_time'] as String),
      locationHistoryIds: (json['location_history_ids'] as List?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      status: TripStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TripStatus.active,
      ),
      trackingIntervalSeconds:
          json['tracking_interval_seconds'] as int? ?? 30,
    );
  }
}

@HiveType(typeId: 18)
enum TripStatus {
  @HiveField(0)
  active,
  @HiveField(1)
  completed,
  @HiveField(2)
  cancelled,
}
