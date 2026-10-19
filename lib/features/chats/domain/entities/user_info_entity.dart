import '../../../../config/api_path.dart';

String chatMediaUrl(String? path) {
  if (path == null || path.isEmpty) return '';
  if (path.startsWith('http')) return path;
  final normalized = path.startsWith('/') ? path : '/$path';
  return '${ApiPath.serverUrl}$normalized';
}

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
    final avatar = json['avatar'] ?? json['imageUrl'] ?? json['photo'];
    return UserProfile(
      email: json['email']?.toString(),
      name: json['displayName']?.toString() ?? json['name']?.toString(),
      avatar: avatar == null ? null : chatMediaUrl(avatar.toString()),
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

  factory UserInfoEntity.fromJson(dynamic raw) {
    if (raw is String) return UserInfoEntity(id: raw);
    if (raw is! Map) return UserInfoEntity(id: '');
    final json = Map<String, dynamic>.from(raw);
    final profileRaw = json['profile'];
    UserProfile? profile = profileRaw is Map
        ? UserProfile.fromJson(Map<String, dynamic>.from(profileRaw))
        : null;
    final displayName = json['displayName']?.toString();
    if ((profile == null || (profile.name ?? '').isEmpty) &&
        displayName != null &&
        displayName.isNotEmpty) {
      profile = UserProfile(
        email: profile?.email,
        name: displayName,
        avatar: profile?.avatar,
      );
    }
    final vendorRaw = json['vendorInfo'];
    return UserInfoEntity(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      phone: json['phone']?.toString(),
      role: json['role']?.toString(),
      profile: profile,
      vendorInfo: vendorRaw is Map
          ? VendorInfo.fromJson(Map<String, dynamic>.from(vendorRaw))
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


