import '../../domain/entities/participant_entity.dart';
import 'user_info_model.dart';

class ParticipantModel extends ParticipantEntity {
  ParticipantModel({
    required super.id,
    required super.userId,
    required super.role,
  });

  factory ParticipantModel.fromJson(Map<String, dynamic> json) {
    return ParticipantModel(
      id: json['_id']?.toString() ?? '',
      userId: UserInfoModel.fromJson(
          json['userId'] as Map<String, dynamic>? ?? {}),
      role: json['role']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': (userId as UserInfoModel).toJson(),
      'role': role,
    };
  }
}

