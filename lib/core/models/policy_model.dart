class PolicyModel {
  final String content;
  final String version;
  final DateTime lastUpdated;
  final PolicyType type;

  const PolicyModel({
    required this.content,
    required this.version,
    required this.lastUpdated,
    required this.type,
  });

  factory PolicyModel.fromJson(Map<String, dynamic> json) {
    return PolicyModel(
      content: json['content'] as String,
      version: json['version'] as String,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      type: PolicyType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => PolicyType.privacy,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'version': version,
      'lastUpdated': lastUpdated.toIso8601String(),
      'type': type.toString().split('.').last,
    };
  }

  PolicyModel copyWith({
    String? content,
    String? version,
    DateTime? lastUpdated,
    PolicyType? type,
  }) {
    return PolicyModel(
      content: content ?? this.content,
      version: version ?? this.version,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      type: type ?? this.type,
    );
  }
}

enum PolicyType {
  privacy,
  terms,
}

class PolicyAcceptance {
  final String userId;
  final PolicyType policyType;
  final String version;
  final DateTime acceptedAt;

  const PolicyAcceptance({
    required this.userId,
    required this.policyType,
    required this.version,
    required this.acceptedAt,
  });

  factory PolicyAcceptance.fromJson(Map<String, dynamic> json) {
    return PolicyAcceptance(
      userId: json['userId'] as String,
      policyType: PolicyType.values.firstWhere(
        (e) => e.toString().split('.').last == json['policyType'],
      ),
      version: json['version'] as String,
      acceptedAt: DateTime.parse(json['acceptedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'policyType': policyType.toString().split('.').last,
      'version': version,
      'acceptedAt': acceptedAt.toIso8601String(),
    };
  }
}
