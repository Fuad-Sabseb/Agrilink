/// LocationCoordinate Model
/// Represents a GPS coordinate with validation for Ethiopia bounds

/// Exception thrown when location coordinates are invalid
class InvalidLocationException implements Exception {
  final String message;

  InvalidLocationException(this.message);

  @override
  String toString() => 'InvalidLocationException: $message';
}

/// Location coordinate with validation
/// Validates that coordinates fall within Ethiopia's geographic bounds
/// (3°N to 15°N latitude, 33°E to 48°E longitude)
class LocationCoordinate {
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  LocationCoordinate({
    required this.latitude,
    required this.longitude,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now() {
    // Reject null island coordinates (0.0, 0.0)
    if (latitude == 0.0 && longitude == 0.0) {
      throw InvalidLocationException(
        'Invalid coordinates (0.0, 0.0) - null island',
      );
    }

    // Validate Ethiopia bounds (3°N to 15°N, 33°E to 48°E)
    if (latitude < 3.0 || latitude > 15.0) {
      throw InvalidLocationException(
        'Latitude $latitude is outside Ethiopia bounds (3°N to 15°N)',
      );
    }

    if (longitude < 33.0 || longitude > 48.0) {
      throw InvalidLocationException(
        'Longitude $longitude is outside Ethiopia bounds (33°E to 48°E)',
      );
    }
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Create from JSON
  factory LocationCoordinate.fromJson(Map<String, dynamic> json) {
    return LocationCoordinate(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }

  /// Create a copy with updated fields
  LocationCoordinate copyWith({
    double? latitude,
    double? longitude,
    DateTime? timestamp,
  }) {
    return LocationCoordinate(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() {
    return 'LocationCoordinate(lat: ${latitude.toStringAsFixed(6)}, '
        'lng: ${longitude.toStringAsFixed(6)}, '
        'timestamp: ${timestamp.toIso8601String()})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LocationCoordinate &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return latitude.hashCode ^ longitude.hashCode ^ timestamp.hashCode;
  }
}
