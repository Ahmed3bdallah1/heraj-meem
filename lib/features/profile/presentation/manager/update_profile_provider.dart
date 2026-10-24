import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../core/service/auth_service.dart';
import '../../../../../../core/service/local_data_manager.dart';
import '../../../../../../main.dart';
import '../../../../../models/user_model.dart';
import '../../../auth/domain/repositories/auth_repo.dart';

final refreshProfileProvider =
    FutureProvider.autoDispose<UserModel>((ref) async {
  ref.listenSelf((previous, next) {
    if (next.value is UserModel) {
      final merged =
          (next.value as UserModel).withSavedPlaceFrom(dataManager.getUser());
      dataManager.setUser(merged);
      ref.read(userProvider.notifier).state = merged;
    }
  });
  final res = await getIt<AuthRepo>().getMyProfile();
  return res.fold((l) => throw l, (r) => r);
});
