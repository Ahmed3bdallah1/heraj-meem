import 'user_info_entity.dart';

class ParticipantEntity {
  final String id;
  final UserInfoEntity? userId;
  final String role;

  ParticipantEntity({
    required this.id,
    required this.userId,
    required this.role,
  });

  factory ParticipantEntity.fromJson(Map<String, dynamic> json) {
    final rawUser = json['user'] ?? json['userId'] ?? json['participant'];
    final bool isUser =
        json['profile'] != null || json['phone'] != null || json['displayName'] != null;
    final user = rawUser ?? (isUser ? json : null);
    return ParticipantEntity(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      userId: user == null ? null : UserInfoEntity.fromJson(user),
      role: json['role']?.toString() ?? '',
    );
  }
}
