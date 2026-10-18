import '../../domain/entities/user_info_entity.dart';

class UserProfileModel extends UserProfile {
  UserProfileModel({
    super.email,
    super.name,
    super.avatar,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return UserProfileModel();
    return UserProfileModel(
      email: json['email']?.toString(),
      name: json['name']?.toString(),
      avatar: json['avatar']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (email != null) 'email': email,
      if (name != null) 'name': name,
      if (avatar != null) 'avatar': avatar,
    };
  }
}

class VendorInfoModel extends VendorInfo {
  VendorInfoModel({
    super.storeName,
    super.logo,
  });

  factory VendorInfoModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return VendorInfoModel();
    return VendorInfoModel(
      storeName: json['storeName']?.toString(),
      logo: json['logo']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (storeName != null) 'storeName': storeName,
      if (logo != null) 'logo': logo,
    };
  }
}

class UserInfoModel extends UserInfoEntity {
  UserInfoModel({
    required super.id,
    super.phone,
    super.role,
    super.profile,
    super.vendorInfo,
  });

  factory UserInfoModel.fromJson(Map<String, dynamic> json) {
    return UserInfoModel(
      id: json['_id']?.toString() ?? '',
      phone: json['phone']?.toString(),
      role: json['role']?.toString(),
      profile: json['profile'] != null
          ? UserProfileModel.fromJson(json['profile'] as Map<String, dynamic>)
          : null,
      vendorInfo: json['vendorInfo'] != null
          ? VendorInfoModel.fromJson(json['vendorInfo'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      if (phone != null) 'phone': phone,
      if (role != null) 'role': role,
      if (profile != null) 'profile': (profile as UserProfileModel).toJson(),
      if (vendorInfo != null)
        'vendorInfo': (vendorInfo as VendorInfoModel).toJson(),
    };
  }
}

