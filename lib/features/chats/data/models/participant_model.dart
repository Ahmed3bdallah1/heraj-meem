import '../../domain/entities/participant_entity.dart';
import 'user_info_model.dart';

class ParticipantModel extends ParticipantEntity {
  ParticipantModel({
    required super.id,
    required super.userId,
    required super.role,
  });

  factory ParticipantModel.fromJson(Map<String, dynamic> json) {
    final parsed = ParticipantEntity.fromJson(json);
    return ParticipantModel(
      id: parsed.id,
      userId: parsed.userId == null
          ? UserInfoModel(id: '')
          : UserInfoModel.fromJson({
              'id': parsed.userId!.id,
              'phone': parsed.userId!.phone,
              'role': parsed.userId!.role,
              if (parsed.userId!.profile != null)
                'profile': {
                  'name': parsed.userId!.profile!.name,
                  'email': parsed.userId!.profile!.email,
                  'avatar': parsed.userId!.profile!.avatar,
                },
            }),
      role: parsed.role,
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

