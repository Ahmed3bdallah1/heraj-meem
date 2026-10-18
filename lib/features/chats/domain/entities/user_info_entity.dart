class UserProfile {
  final String? email;
  final String? name;
  final String? avatar;

  UserProfile({
    this.email,
    this.name,
    this.avatar,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      email: json['email']?.toString(),
      name: json['name']?.toString(),
      avatar: json['avatar']?.toString(),
    );
  }
}

class VendorInfo {
  final String? storeName;
  final String? logo;

  VendorInfo({
    this.storeName,
    this.logo,
  });

  factory VendorInfo.fromJson(Map<String, dynamic> json) {
    return VendorInfo(
      storeName: json['storeName']?.toString(),
      logo: json['logo']?.toString(),
    );
  }
}

class UserInfoEntity {
  final String id;
  final String? phone;
  final String? role;
  final UserProfile? profile;
  final VendorInfo? vendorInfo;

  UserInfoEntity({
    required this.id,
    this.phone,
    this.role,
    this.profile,
    this.vendorInfo,
  });

  factory UserInfoEntity.fromJson(Map<String, dynamic> json) {
    return UserInfoEntity(
      id: json['_id']?.toString() ?? '',
      phone: json['phone']?.toString(),
      role: json['role']?.toString(),
      profile: json['profile'] != null
          ? UserProfile.fromJson(json['profile'] as Map<String, dynamic>)
          : null,
      vendorInfo: json['vendorInfo'] != null
          ? VendorInfo.fromJson(json['vendorInfo'] as Map<String, dynamic>)
          : null,
    );
  }

  String get displayName {
    if (profile?.name != null && profile!.name!.isNotEmpty) {
      return profile!.name!;
    }
    if (vendorInfo?.storeName != null && vendorInfo!.storeName!.isNotEmpty) {
      return vendorInfo!.storeName!;
    }
    return phone ?? 'Unknown User';
  }

  String get displayImage {
    if (profile?.avatar != null && profile!.avatar!.isNotEmpty) {
      return profile!.avatar!;
    }
    if (vendorInfo?.logo != null && vendorInfo!.logo!.isNotEmpty) {
      return vendorInfo!.logo!;
    }
    return '';
  }
}


