import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../main.dart';
import '../../../../core/service/auth_service.dart';
import '../../../../core/service/local_data_manager.dart';
import '../../../../core/service/remote_config_service.dart';

enum SplashNavigate {
  home,
  getStarted,
  boarding,
  login,
  forceUpdate,
}

/// When true, splash should show optional-update dialog before navigating.
final showOptionalUpdateDialogProvider =
    StateProvider.autoDispose<bool>((ref) => false);

final splashNavigateProvider = Provider.autoDispose<SplashNavigate>((ref) {
  SplashNavigate splashNavigate = SplashNavigate.home;
  if (dataManager.getToken() != null) {
    splashNavigate = SplashNavigate.home;
  } else if (dataManager.isFirstTime) {
    // splashNavigate = SplashNavigate.boarding;
    splashNavigate = SplashNavigate.boarding;
  } else {
    splashNavigate = SplashNavigate.login;
  }
  return splashNavigate;
});

// final newUpdateProvider = FutureProvider.autoDispose<bool>((ref) async {
//   final shorebirdCodePush = ShorebirdCodePush();
//   final isUpdateAvailable =
//       await shorebirdCodePush.isNewPatchAvailableForDownload();
//   if (isUpdateAvailable) {
//     ref.read(isUpdateAvailableProvider.notifier).state = true;
//     await shorebirdCodePush.downloadUpdateIfAvailable();
//   }
//   return isUpdateAvailable;
// });

final isUpdateAvailableProvider = StateProvider.autoDispose<bool>((ref) {
  return false;
});

final splashProvider = FutureProvider.autoDispose<SplashNavigate>((ref) async {
  // 1) Remote Config version check
  try {
    final remoteConfig = getIt<RemoteConfigService>();
    await remoteConfig.fetchAndActivate();
    final versionResult = await remoteConfig.checkVersion();
    switch (versionResult) {
      case VersionCheckResult.forceUpdate:
        return SplashNavigate.forceUpdate;
      case VersionCheckResult.optionalUpdate:
        ref.read(showOptionalUpdateDialogProvider.notifier).state = true;
        break;
      case VersionCheckResult.upToDate:
        break;
    }
  } catch (_) {
    // On error (e.g. no network), continue without blocking
  }

  // 2) Existing splash flow
  final hasUser = await ref.read(fetchUserProvider.future);
  if (!hasUser) await Future.delayed(const Duration(seconds: 2));
  final res = ref.read(splashNavigateProvider);
  if (res == SplashNavigate.home) {
    if (dataManager.getFingerprintEnabled() == true) {
      return SplashNavigate.login;
    } else {
      return SplashNavigate.home;
    }
  } else {
    return res;
  }
});

final hasInternetProvider2 = StateProvider<bool>((ref) => true);

final isInternetOk = Provider<bool>((ref) {
  final connector1 = ref.watch(hasInternetProvider);
  final connector2 = ref.watch(hasInternetProvider2);
  if (connector1.isLoading) {
    return true;
  } else if (connector1.hasValue) {
    if (connector1.value!) {
      return connector2;
    } else {
      return false;
    }
  } else {
    return connector2;
  }
});
final connectivity = Connectivity();

final hasInternetProvider = StreamProvider<bool>((ref) async* {
  ref.listenSelf((previous, next) {
    if (previous?.value == false && next.value == true) {
      ref.invalidate(hasInternetProvider2);
    }
  });
  final connectivityResult = await connectivity.checkConnectivity();
  yield connectivityResult.isOnline;
  yield* connectivity.onConnectivityChanged.map((event) {
    return event.isOnline;
  });
});

extension on List<ConnectivityResult> {
  bool get isOffline {
    return contains(ConnectivityResult.none);
  }

  bool get isOnline {
    return !isOffline;
  }
}
