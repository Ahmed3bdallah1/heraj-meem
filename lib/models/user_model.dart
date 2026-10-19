class UserAuthResponseModel {
  String? token;
  String? message;
  bool needsRoleSelection;
  UserModel? user;

  UserAuthResponseModel(
      {required this.token, required this.user, this.message,this.needsRoleSelection = false});
}

class PreAuthResponseModel {
  final String message;
  final PreAuthUser? data;

  PreAuthResponseModel({
    required this.message,
    this.data,
  });

  factory PreAuthResponseModel.fromJson(Map<String, dynamic> json) {
    return PreAuthResponseModel(
      message: json['message'] ?? '',
      data: json['data'] != null ? PreAuthUser.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "message": message,
      "data": data?.toJson(),
    };
  }
}

class PreLoginResponseModel {
  final bool success;
  final String message;
  final PreLoginData? data;

  PreLoginResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory PreLoginResponseModel.fromJson(Map<String, dynamic> json) {
    return PreLoginResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? PreLoginData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "success": success,
      "message": message,
      "data": data?.toJson(),
    };
  }
}

class PreLoginData {
  final String phone;
  final String countryCode;
  final bool isNewUser;
  final int? expiresInMinutes;
  final String? devCode;

  PreLoginData({
    required this.phone,
    required this.countryCode,
    required this.isNewUser,
    this.expiresInMinutes,
    this.devCode,
  });

  factory PreLoginData.fromJson(Map<String, dynamic> json) {
    return PreLoginData(
      phone: json['phone'] ?? '',
      countryCode: json['countryCode'] ?? '',
      isNewUser: json['isNewUser'] ?? false,
      expiresInMinutes: json['expiresInMinutes'] is int
          ? json['expiresInMinutes'] as int
          : int.tryParse('${json['expiresInMinutes']}'),
      devCode: json['devCode']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "phone": phone,
      "countryCode": countryCode,
      "isNewUser": isNewUser,
    };
  }
}

class PreAuthUser {
  final int id;
  final String name;
  final String email;
  final String phone;
  final bool isVerified;
  final int? verificationCode;
  final String? verificationCodeExpire;
  final String role;
  final String? image;
  final String createdAt;
  final String updatedAt;
  final String? imageUrl;

  PreAuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.isVerified,
    this.verificationCode,
    this.verificationCodeExpire,
    required this.role,
    this.image,
    required this.createdAt,
    required this.updatedAt,
    this.imageUrl,
  });

  factory PreAuthUser.fromJson(Map<String, dynamic> json) {
    return PreAuthUser(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      isVerified: json['is_verified'] ?? false,
      verificationCode: json['verification_code'],
      verificationCodeExpire: json['verification_code_expire'],
      role: json['role'] ?? 'user',
      image: json['image'] ?? "",
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      imageUrl: json['image_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "email": email,
      "phone": phone,
      "is_verified": isVerified,
      "verification_code": verificationCode,
      "verification_code_expire": verificationCodeExpire,
      "role": role,
      "image": image,
      "created_at": createdAt,
      "updated_at": updatedAt,
      "image_url": imageUrl,
    };
  }
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? countryCode;
  final String? image;
  final bool isVerified;
  final String role;
  final bool? isProfileComplete;
  final bool? hasPassword;
  final bool? isRoleSelected;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.countryCode,
    this.image,
    required this.isVerified,
    this.isProfileComplete,
    this.hasPassword,
    this.isRoleSelected = true,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    String userId = '';
    final idValue = json['id'] ?? json['_id'];
    if (idValue != null) {
      userId = idValue.toString();
    }
    final profile = json['profile'] is Map
        ? Map<String, dynamic>.from(json['profile'] as Map)
        : null;
    final imageValue = profile?['avatarUrl'] ??
        json['image'] ??
        json['avatar'] ??
        json['avatarUrl'] ??
        json['image_url'] ??
        '';
    var role = (json['role'] ?? json['userType'] ?? 'customer').toString();
    if (role == 'BUYER') role = 'customer';
    if (role == 'SELLER' || role == 'VENDOR') role = 'vendor';

    return UserModel(
      id: userId,
      name: profile?['displayName'] ?? json['displayName'] ?? json['name'] ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString(),
      countryCode: json['countryCode'] ?? json['country_code'],
      image: imageValue?.toString() ?? '',
      role: role,
      hasPassword: json['hasPassword'] ?? false,
      isRoleSelected: json['isRoleSelected'] ?? true,
      isVerified: json['status'] == 'ACTIVE' ||
          json['isVerified'] == true ||
          json['is_verified'] == true,
      isProfileComplete: json['isProfileComplete'] ?? json['is_profile_complete'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'countryCode': countryCode,
      'image': image,
      'is_verified': isVerified,
      'isProfileComplete': isProfileComplete,
      'hasPassword': hasPassword,
      'isRoleSelected': isRoleSelected,
      'role': role,
    };
  }
}
