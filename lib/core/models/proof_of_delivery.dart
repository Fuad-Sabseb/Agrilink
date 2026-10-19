/// Proof of Delivery Model
/// Contains photo and signature evidence of completed delivery
class ProofOfDelivery {
  final String id;
  final String jobId;
  final String photoUrl;
  final String signatureUrl;
  final String recipientName;
  final DateTime capturedAt;
  final String? notes;
  final double? latitude;
  final double? longitude;

  ProofOfDelivery({
    required this.id,
    required this.jobId,
    required this.photoUrl,
    required this.signatureUrl,
    required this.recipientName,
    required this.capturedAt,
    this.notes,
    this.latitude,
    this.longitude,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jobId': jobId,
      'photoUrl': photoUrl,
      'signatureUrl': signatureUrl,
      'recipientName': recipientName,
      'capturedAt': capturedAt.toIso8601String(),
      'notes': notes,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  /// Create from JSON
  factory ProofOfDelivery.fromJson(Map<String, dynamic> json) {
    return ProofOfDelivery(
      id: json['id'] as String,
      jobId: json['jobId'] as String,
      photoUrl: json['photoUrl'] as String,
      signatureUrl: json['signatureUrl'] as String,
      recipientName: json['recipientName'] as String,
      capturedAt: DateTime.parse(json['capturedAt'] as String),
      notes: json['notes'] as String?,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
    );
  }

  /// Check if proof has location data
  bool get hasLocation => latitude != null && longitude != null;
}

/// Signature Data for local storage before upload
class SignatureData {
  final List<int> imageBytes;
  final DateTime capturedAt;
  final bool isEmpty;

  SignatureData({
    required this.imageBytes,
    required this.capturedAt,
    this.isEmpty = false,
  });

  /// Get size in KB
  double get sizeInKB => imageBytes.length / 1024;

  /// Check if signature is valid (not empty and reasonable size)
  bool get isValid => !isEmpty && imageBytes.isNotEmpty && sizeInKB > 1;
}

/// Contact Information for job
class JobContactInfo {
  final String farmerName;
  final String farmerPhone;
  final String? buyerName;
  final String? buyerPhone;
  final String pickupContactName;
  final String pickupContactPhone;
  final String deliveryContactName;
  final String deliveryContactPhone;

  JobContactInfo({
    required this.farmerName,
    required this.farmerPhone,
    this.buyerName,
    this.buyerPhone,
    required this.pickupContactName,
    required this.pickupContactPhone,
    required this.deliveryContactName,
    required this.deliveryContactPhone,
  });

  factory JobContactInfo.fromJson(Map<String, dynamic> json) {
    return JobContactInfo(
      farmerName: json['farmerName'] as String,
      farmerPhone: json['farmerPhone'] as String,
      buyerName: json['buyerName'] as String?,
      buyerPhone: json['buyerPhone'] as String?,
      pickupContactName: json['pickupContactName'] as String,
      pickupContactPhone: json['pickupContactPhone'] as String,
      deliveryContactName: json['deliveryContactName'] as String,
      deliveryContactPhone: json['deliveryContactPhone'] as String,
    );
  }
}
