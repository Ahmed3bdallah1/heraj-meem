import 'package:heraj_meem/config/api_path.dart';

class PublicProfileModel {
  final String id;
  final String displayName;
  final String avatarUrl;
  final String bio;
  final String phone;
  final String cityName;
  final double score;
  final int memberNumber;

  const PublicProfileModel({
    required this.id,
    required this.displayName,
    required this.avatarUrl,
    required this.bio,
    required this.phone,
    required this.cityName,
    required this.score,
    required this.memberNumber,
  });

  factory PublicProfileModel.fromJson(Map<String, dynamic> json) {
    final profile = json['profile'] is Map
        ? Map<String, dynamic>.from(json['profile'] as Map)
        : <String, dynamic>{};
    final city = profile['city'] is Map
        ? Map<String, dynamic>.from(profile['city'] as Map)
        : json['city'] is Map
            ? Map<String, dynamic>.from(json['city'] as Map)
            : null;
    final trust = json['trustScore'] is Map
        ? Map<String, dynamic>.from(json['trustScore'] as Map)
        : null;
    final rawAvatar = profile['avatarUrl']?.toString() ??
        profile['avatar']?.toString() ??
        '';
    final score = trust?['score'];
    final member = json['memberNumber'];
    return PublicProfileModel(
      id: json['id']?.toString() ?? '',
      displayName: profile['displayName']?.toString() ??
          json['displayName']?.toString() ??
          json['name']?.toString() ??
          '',
      avatarUrl: _mediaUrl(rawAvatar),
      bio: profile['bio']?.toString() ?? json['bio']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      cityName: city?['nameAr']?.toString() ??
          city?['nameEn']?.toString() ??
          json['location']?.toString() ??
          '',
      score: score is num
          ? score.toDouble()
          : double.tryParse(score?.toString() ?? '') ?? 0,
      memberNumber: member is int
          ? member
          : int.tryParse(member?.toString() ?? '') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'phone': phone,
      'cityName': cityName,
      'score': score,
      'memberNumber': memberNumber,
    };
  }

  static String _mediaUrl(String raw) {
    if (raw.isEmpty) return '';
    if (raw.startsWith('http')) return raw;
    return '${ApiPath.serverUrl}${raw.startsWith('/') ? raw : '/$raw'}';
  }
}
