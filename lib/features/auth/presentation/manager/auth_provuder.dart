import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:heraj_meem/core/service/location_service/location_provider.dart';
import 'package:heraj_meem/features/auth/presentation/view/widgets/location_request_bottom_sheet.dart';
import 'package:heraj_meem/models/user_model.dart';
// import 'package:flutter_firebase_chat/flutter_firebase_chat.dart';
import '../../../../../core/service/auth_service.dart';
import '../../../../../core/service/local_data_manager.dart';
import '../../../../../core/service/fcm_token_service.dart';
import '../../../../../main.dart';
import '../../../verify/domain/repositories/verification_repo.dart';
import '../../../verify/presentation/pages/verify_view.dart';
import '../../../root/view/root_view.dart';
import '../../domain/use_cases/login_user_use_case.dart';
import '../../domain/use_cases/register_user_use_case.dart';
import '../../domain/use_cases/select_role_use_case.dart';
import '../view/widgets/role_selection_bottom_sheet.dart';
import '../../../onboarding/view/get_started_screen.dart';

final authNotifierProvider =
    StateNotifierProvider.autoDispose<AuthNotifier, bool>((ref) {
  return AuthNotifier(ref);
});

final isLoadingProvider = StateProvider.autoDispose<bool>((ref) => false);

class AuthNotifier extends StateNotifier<bool> {
  AuthNotifier(this.ref) : super(false);
  Ref ref;

  Future login(Map<String, dynamic> data) async {
    state = true;
    try {
      final res = await getIt<LoginUserUseCase>().call(data);
      res.fold((l) {
        throw l;
      }, (r) {
        handleUser(r, null, data);
      });
    } finally {
      state = false;
    }
  }

  Future register(Map<String, dynamic> data) async {
    state = true;
    try {
      final res = await getIt<RegisterUserUseCase>().call(data);
      res.fold((l) {
        throw l;
      }, (r) {
        handleUser(r, null, data, checkIsVerified: false);
      });
    } finally {
      state = false;
    }
  }

  Future vendorRegister(Map<String, dynamic> data) async {
    state = true;
    try {
      final res = await getIt<VendorRegisterUserUseCase>().call(data);
      res.fold((l) {
        throw l;
      }, (r) {
        handleVendorUser(r, data);
      });
    } finally {
      state = false;
    }
  }

  Future<PreLoginResponseModel?> preLogin(Map<String, dynamic> data) async {
    state = true;
    try {
      final res = await getIt<PreLoginUserUseCase>().call(data);
      return res.fold((l) {
        throw l;
      }, (r) {
        return r;
      });
    } finally {
      state = false;
    }
  }

  Future socialLogin(String data) async {
    state = true;
    try {
      final res = await getIt<SocialLoginUserUseCase>().call(data);
      await res.fold((l) {
        throw l;
      }, (r) async {
        // Check if role selection is needed
        if (r.needsRoleSelection) {
          // Check if user has already selected role from get started screen
          final hasPreSelectedRole = dataManager.hasVendorFlowPreference();
          String? selectedRole;

          if (hasPreSelectedRole) {
            // Use the pre-selected role from get started screen
            final isVendor = dataManager.getVendorFlow();
            selectedRole = isVendor ? 'vendor' : 'customer';
          } else {
            // Show bottom sheet to select role
            selectedRole = await showRoleSelectionBottomSheet();
          }

          if (selectedRole != null) {
            // Call select-role API
            final selectRoleRes =
                await getIt<SelectRoleUseCase>().call(selectedRole);
            await selectRoleRes.fold((l) {
              throw l;
            }, (roleResponse) async {
              // Update user with the role response
              // The token should already be set from the initial social login
              // Now we need to update the user with the new role
              final updatedUser = UserAuthResponseModel(
                token: r.token,
                user: roleResponse.user,
                message: roleResponse.message,
                needsRoleSelection: false,
              );

              // Set vendor flow based on selected role
              if (selectedRole == 'vendor') {
                await dataManager.setVendorFlow(true);
              } else {
                await dataManager.setVendorFlow(false);
              }

              // Handle the user normally
              await handleUser(updatedUser, null, {}, checkIsVerified: true);
            });
          } else {
            // User cancelled role selection
            state = false;
            return;
          }
        } else {
          // No role selection needed, proceed normally
          await handleUser(r, null, {}, checkIsVerified: true);
        }
      });
    } finally {
      state = false;
    }
  }

  Future<void> handleUser(UserAuthResponseModel? user,
      PreAuthResponseModel? preAuth, Map<String, dynamic> data,
      {bool checkIsVerified = false}) async {
    state = true;
    try {
      if (preAuth != null) {
        return Get.offAll(() => VerifyView(
                repo: getIt<VerificationRepo>(
              param1: data["email"],
            )));
      }
      if (user != null) {
        final locationDetails = await showLocationRequestBottomSheet();
        if (user.token != null && user.user != null) {
          await dataManager.setUser(user.user!);
          await dataManager.setToken(user.token!);

          // try {
          //   final uploader = FirestoreDataUploader();
          //   final userData = {
          //     "_id": user.user!.id,
          //     "id": user.user!.id,
          //     "phone": user.user?.phone ?? "",
          //     "countryCode": user.user?.countryCode ?? "",
          //     "role": user.user?.role ?? "",
          //     "name": user.user?.name ?? "",
          //     "email": user.user?.email ?? "",
          //     "avatar": user.user?.image ?? "",
          //     "isVerified": user.user?.isVerified ?? false,
          //     "isProfileComplete": user.user?.isProfileComplete ?? false,
          //   };
          //   await uploader.initUserDataIfNotExists(
          //     userData: userData,
          //     createChatRoom: true,
          //     createSampleMessages: true,
          //   );
          // } catch (e) {
          //   print("Error uploading user to Firestore: $e");
          // }
        }
        ref.read(userProvider.notifier).state = user.user;
        if (locationDetails != null) {
          Future.microtask(() {
            ref.invalidate(fetchLocationDetailsProvider);
          });
        }

        try {
          await getIt<FCMTokenService>().registerFCMToken();
        } catch (e) {
          print('Error registering FCM token: $e');
        }

        return Get.offAll(() => const RootView());
      }
    } finally {
      state = false;
    }
  }

  Future<void> handleVendorUser(
      UserAuthResponseModel user, Map<String, dynamic> data) async {
    state = true;
    try {
      final locationDetails = await showLocationRequestBottomSheet();
      if (user.token != null && user.user != null) {
        await dataManager.setUser(user.user!);
        await dataManager.setToken(user.token!);

        // Set vendor flow to true
        await dataManager.setVendorFlow(true);

        // try {
        //   final uploader = FirestoreDataUploader();
        //   final userData = {
        //     "_id": user.user!.id,
        //     "id": user.user!.id,
        //     "phone": user.user?.phone ?? "",
        //     "countryCode": user.user?.countryCode ?? "",
        //     "role": user.user?.role ?? "",
        //     "name": user.user?.name ?? "",
        //     "email": user.user?.email ?? "",
        //     "avatar": user.user?.image ?? "",
        //     "isVerified": user.user?.isVerified ?? false,
        //     "isProfileComplete": user.user?.isProfileComplete ?? false,
        //   };
        //   await uploader.initUserDataIfNotExists(
        //     userData: userData,
        //     createChatRoom: true,
        //     createSampleMessages: true,
        //   );
        // } catch (e) {
        //   print("Error uploading user to Firestore: $e");
        // }
      }
      ref.read(userProvider.notifier).state = user.user;
      if (locationDetails != null) {
        Future.microtask(() {
          ref.invalidate(fetchLocationDetailsProvider);
        });
      }

      try {
        await getIt<FCMTokenService>().registerFCMToken();
      } catch (e) {
        print('Error registering FCM token: $e');
      }

      return Get.offAll(() => const RootView());
    } finally {
      state = false;
    }
  }
}

final fingerprintControllerProvider = StateProvider.autoDispose<bool>((ref) {
  return dataManager.getFingerprintEnabled();
});
