class UserData {
  final String id;
  final String? uuid;
  final String? name;
  final String? email;
  final String? phone;
  final String? role;
  final String? status;
  final String? profilePicture;
  final String? code;
  final String? isVerified;
  final String? fcmToken;
  final bool? isOnline;
  final DateTime? lastSeen;

  UserData({
    required this.id,
    this.uuid,
    this.name,
    this.email,
    this.phone,
    this.role,
    this.status,
    this.profilePicture,
    this.code,
    this.isVerified,
    this.fcmToken,
    this.isOnline,
    this.lastSeen,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] ?? "0",
      uuid: json['uuid'] ?? "",
      name: json['name'] ?? "",
      email: json['email'] ?? "",
      phone: json['phone'] ?? "",
      role: json['role'] ?? "",
      status: (json['status'] ?? 0).toString(),
      profilePicture:
          json['profile_picture'] ??
          "https://my-car.backteam.site/dashboard/images/user/user.png",
      code: (json['code'] ?? 0).toString(),
      isVerified: (json['is_verified'] ?? 0).toString(),
      fcmToken: json['fcm_token'],
      isOnline: json['is_online'] ?? false,
      lastSeen: json['last_seen'] != null
          ? (json['last_seen'] is DateTime
                ? json['last_seen']
                : (json['last_seen'] as dynamic).toDate())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "uuid": uuid,
      "name": name,
      "email": email,
      "phone": phone,
      "role": role,
      "status": status,
      "profile_picture": profilePicture,
      "code": code,
      "is_verified": isVerified,
      "fcm_token": fcmToken,
      "is_online": isOnline ?? false,
      "last_seen": lastSeen,
    };
  }
}
