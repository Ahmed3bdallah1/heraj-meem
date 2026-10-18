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
    return ParticipantEntity(
      id: json['_id']?.toString() ?? '',
      userId: UserInfoEntity.fromJson(json['userId'] ?? {}),
      role: json['role']?.toString() ?? '',
    );
  }
}
