/// Request model for updating user profile
class ProfileUpdateRequest {
  final String? fullName;
  final String? location;
  final String? woreda;
  final String? cooperativeName;

  ProfileUpdateRequest({
    this.fullName,
    this.location,
    this.woreda,
    this.cooperativeName,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (fullName != null) map['fullName'] = fullName;
    if (location != null) map['location'] = location;
    if (woreda != null) map['woreda'] = woreda;
    if (cooperativeName != null) map['cooperativeName'] = cooperativeName;
    return map;
  }

  bool get isEmpty => toJson().isEmpty;
  bool get isNotEmpty => !isEmpty;
}
