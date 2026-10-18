import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heraj/features/settings/data/models/settings_model.dart';
import 'package:heraj/features/settings/domain/use_case/fetch_settings_use_case.dart';
import '../../../../main.dart';

final fetchSettingsProvider = FutureProvider.autoDispose<SettingsModel>((ref) async {
  final res = await getIt<FetchSettingsUseCase>().call();
  return res.fold((l) => throw l, (r) => r);
});