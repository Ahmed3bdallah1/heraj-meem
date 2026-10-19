import '../../domain/entities/user_info_entity.dart';

class UserProfileModel extends UserProfile {
  UserProfileModel({
    super.email,
    super.name,
    super.avatar,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return UserProfileModel();
    final parsed = UserProfile.fromJson(json);
    return UserProfileModel(
      email: parsed.email,
      name: parsed.name,
      avatar: parsed.avatar,
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

  factory UserInfoModel.fromJson(dynamic raw) {
    final parsed = UserInfoEntity.fromJson(raw);
    return UserInfoModel(
      id: parsed.id,
      phone: parsed.phone,
      role: parsed.role,
      profile: parsed.profile == null
          ? null
          : UserProfileModel(
              email: parsed.profile!.email,
              name: parsed.profile!.name,
              avatar: parsed.profile!.avatar,
            ),
      vendorInfo: parsed.vendorInfo == null
          ? null
          : VendorInfoModel(
              storeName: parsed.vendorInfo!.storeName,
              logo: parsed.vendorInfo!.logo,
            ),
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

