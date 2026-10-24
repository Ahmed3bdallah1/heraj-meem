import 'package:heraj_meem/core/service/theme_service/theme_service.dart';
import 'package:heraj_meem/features/categories/data/data_source/categories_data_source.dart';
import 'package:heraj_meem/features/favorites/data/data_source/favorites_data_source.dart';
import 'package:heraj_meem/features/favorites/data/repo/favorites_repo_imp.dart';
import 'package:heraj_meem/features/favorites/domain/repo/favorites_repo.dart';
import 'package:heraj_meem/features/favorites/domain/use_case/favorites_use_case.dart';
import 'package:heraj_meem/features/categories/data/repo/categories_repo_imp.dart';
import 'package:heraj_meem/features/categories/domain/repo/categories_repo.dart';
import 'package:heraj_meem/features/home/data/data_source/partners_and_testmonial_data_source.dart';
import 'package:heraj_meem/features/home/data/repostories/partner_repo_imp.dart';
import 'package:heraj_meem/features/home/domain/repositories/partner_repo.dart';
import 'package:heraj_meem/features/home/domain/use_case/fetch_partner_use_case.dart';
import 'package:heraj_meem/features/plans/data/data_source/plans_data_source.dart';
import 'package:heraj_meem/features/plans/data/repo/plans_repo_imp.dart';
import 'package:heraj_meem/features/plans/domain/repo/plans_repo.dart';
import 'package:heraj_meem/features/ads/data/data_source/create_ad_data_source.dart';
import 'package:heraj_meem/features/ads/data/data_source/products_data_source.dart';
import 'package:heraj_meem/features/ads/data/repo/create_ad_repo_imp.dart';
import 'package:heraj_meem/features/ads/domain/repo/create_ad_repo.dart';
import 'package:heraj_meem/features/ads/data/data_source/rate_vendor_data_source.dart';
import 'package:heraj_meem/features/ads/data/repo/rate_vendor_repo_imp.dart';
import 'package:heraj_meem/features/ads/domain/repo/rate_vendor_repo.dart';
import 'package:heraj_meem/features/ads/domain/use_case/rate_vendor_use_case.dart';
import 'package:heraj_meem/features/search/data/data_source/baho_search_data_source.dart';
import 'package:heraj_meem/features/search/data/repo/baho_search_repo_imp.dart';
import 'package:heraj_meem/features/search/domain/repo/baho_search_repo.dart';
import 'package:heraj_meem/features/search/domain/use_case/search_ads_use_case.dart';
import 'package:heraj_meem/features/ads/domain/use_case/create_ad_use_case.dart';
import 'package:heraj_meem/features/ads/data/repo/product_repo_imp.dart';
import 'package:heraj_meem/features/ads/domain/repo/product_repo.dart';
import 'package:heraj_meem/features/settings/data/data_source/policy_data_source.dart';
import 'package:heraj_meem/features/settings/data/repo/policy_repo_imp.dart';
import 'package:heraj_meem/features/settings/domain/repo/policy_repo.dart';
import 'package:heraj_meem/features/settings/domain/use_case/fetch_policy_use_case.dart';
import 'package:heraj_meem/features/settings/data/data_source/settings_data_source.dart';
import 'package:heraj_meem/features/settings/data/repo/settings_repo_imp.dart';
import 'package:heraj_meem/features/settings/domain/repo/settings_repo.dart';
import 'package:heraj_meem/features/settings/domain/use_case/fetch_settings_use_case.dart';
import 'package:local_auth/local_auth.dart';
import 'core/service/location_service/location_service.dart';
import 'core/service/remote_config_service.dart';
import 'core/service/image_picker_cropper.dart';
import 'core/service/local_data_manager.dart';
import 'core/service/localization_service/localization_service.dart';
import 'core/service/webservice/dio_helper.dart';
import 'core/service/fcm_token_service.dart';
import 'features/auth/data/data_sources/auth_data_source.dart';
import 'features/auth/data/repositories/auth_repo_impl.dart';
import 'features/auth/domain/repositories/auth_repo.dart';
import 'features/auth/domain/use_cases/login_user_use_case.dart';
import 'features/auth/domain/use_cases/register_user_use_case.dart';
import 'features/auth/domain/use_cases/select_role_use_case.dart';
import 'features/forget_password/data/data_sources/forget_password_data_source.dart';
import 'features/forget_password/data/repositories/forget_password_repo_impl.dart';
import 'features/forget_password/domain/repositories/forget_password_repo.dart';
import 'features/notifications/data/data_source/notification_data_source.dart';
import 'features/notifications/data/repo/notification_repo_imp.dart';
import 'features/notifications/domain/repos/notification_repo.dart';
import 'features/notifications/domain/use_case/fetch_notifications_use_case.dart';
import 'features/verify/data/data_sources/verification_data_source.dart';
import 'features/verify/data/repositories/forget_verify_repo_impl.dart';
import 'features/verify/data/repositories/verify_repo_impl.dart';
import 'features/verify/domain/repositories/verification_repo.dart';
import 'features/home/data/data_source/ads_data_source.dart';
import 'features/home/data/repostories/ads_repo_imp.dart';
import 'features/home/domain/repositories/ads_repo.dart';
import 'features/home/domain/use_case/fetch_ads_use_case.dart';
import 'features/notifications/domain/use_case/fetch_seen_use_case.dart';
import 'features/notifications/domain/use_case/get_unread_count_use_case.dart';
import 'features/notifications/domain/use_case/mark_all_as_read_use_case.dart';
import 'features/profile/data/data_sources/update_profile_date_source.dart';
import 'features/profile/data/data_sources/upload_file_data_source.dart';
import 'features/profile/data/repositories/update_profile_repo_impl.dart';
import 'features/profile/data/repositories/upload_file_repo_impl.dart';
import 'features/profile/domain/repositories/update_profile_repo.dart';
import 'features/profile/domain/repositories/upload_file_repo.dart';
import 'features/profile/domain/use_cases/update_profile_use_case.dart';
import 'features/profile/domain/use_cases/upload_file_use_case.dart';
import 'features/store/data/data_source/stores_data_source.dart';
import 'features/store/data/repo/stores_repo_imp.dart';
import 'features/store/domain/repo/stores_repo.dart';
import 'features/store/domain/use_case/fetch_stores_use_case.dart';
import 'features/location/data/data_source/location_data_source.dart';
import 'features/location/data/repo/location_repo_imp.dart';
import 'features/location/domain/repo/location_repo.dart';
import 'features/location/domain/use_case/fetch_cities_use_case.dart';
import 'features/location/domain/use_case/fetch_districts_use_case.dart';
import 'features/location/domain/use_case/fetch_neighborhoods_use_case.dart';
import 'features/chats/data/data_source/chats_data_source.dart';
import 'features/chats/data/repo/chats_repo_imp.dart';
import 'features/chats/domain/repo/chats_repo.dart';
import 'features/chats/domain/use_case/get_chats_use_case.dart';
import 'features/chats/domain/use_case/get_chat_messages_use_case.dart';
import 'features/chats/domain/use_case/send_message_use_case.dart';
import 'features/chats/domain/use_case/create_chat_use_case.dart';
import 'main.dart';

Future setupLocator() async {
  //DATABASE
  getIt.registerSingleton<LocalDataManager>(
      await GetStorageManagerImpl().init());

  //NETWORK
  getIt.registerSingleton<ApiService>(ApiService());
  //FCM TOKEN SERVICE
  getIt.registerLazySingleton<FCMTokenService>(
      () => FCMTokenService(getIt<ApiService>()));
  //LOCALIZATION
  getIt.registerSingleton<LocaleService>(
      LocaleService(getIt<LocalDataManager>()));
  //THEME
  getIt
      .registerSingleton<ThemeService>(ThemeService(getIt<LocalDataManager>()));
  //IMAGE PICKER
  getIt.registerLazySingleton<ImagePickerService>(
      () => ImagePickerServiceImpl());

  getIt.registerLazySingleton<LocalAuthentication>(() => LocalAuthentication());
  getIt.registerLazySingleton<RemoteConfigService>(() => RemoteConfigService());
  getIt.registerLazySingleton<LocationService>(() => LocationService());

  /// notifications entity
  getIt.registerLazySingleton<NotificationDataSource>(
      () => NotificationDataSourceImp(apiService: getIt<ApiService>()));
  getIt.registerLazySingleton<NotificationRepo>(() => NotificationRepoImp(
      notificationDataSource: getIt<NotificationDataSource>()));
  getIt.registerLazySingleton<FetchNotificationUseCase>(() =>
      FetchNotificationUseCase(notificationRepo: getIt<NotificationRepo>()));
  getIt.registerLazySingleton<SeenNotificationUseCase>(() =>
      SeenNotificationUseCase(notificationRepo: getIt<NotificationRepo>()));
  getIt.registerLazySingleton<GetUnreadCountUseCase>(
      () => GetUnreadCountUseCase(notificationRepo: getIt<NotificationRepo>()));
  getIt.registerLazySingleton<MarkAllAsReadUseCase>(
      () => MarkAllAsReadUseCase(notificationRepo: getIt<NotificationRepo>()));

  /// Settings entity
  getIt.registerLazySingleton<PrivacyPolicyDataSource>(
      () => PrivacyPolicyDataSourceImpl(apiService: getIt<ApiService>()));
  getIt.registerLazySingleton<PrivacyPolicyRepo>(() => PrivacyPolicyRepoImp(
      privacyPolicyDataSource: getIt<PrivacyPolicyDataSource>()));
  getIt.registerLazySingleton<FetchPolicyUseCase>(
      () => FetchPolicyUseCase(policyRepo: getIt<PrivacyPolicyRepo>()));
  getIt.registerLazySingleton<FetchWhoAreWeUseCase>(
      () => FetchWhoAreWeUseCase(policyRepo: getIt<PrivacyPolicyRepo>()));
  getIt.registerLazySingleton<SettingsDataSource>(
      () => SettingsDataSourceImpl(apiService: getIt<ApiService>()));
  getIt.registerLazySingleton<SettingsRepo>(
      () => SettingsRepoImpl(dataSource: getIt<SettingsDataSource>()));
  getIt.registerLazySingleton<FetchSettingsUseCase>(
      () => FetchSettingsUseCase(policyRepo: getIt<SettingsRepo>()));

  /// Categories entity
  getIt.registerLazySingleton<CategoriesDataSource>(
      () => CategoriesDataSourceImpl(getIt<ApiService>()));
  getIt.registerLazySingleton<CategoriesRepo>(
      () => CategoriesRepoImpl(getIt<CategoriesDataSource>()));

  /// Products entity
  getIt.registerLazySingleton<ProductsDataSource>(
      () => ProductsDataSourceImpl(apiService: getIt<ApiService>()));
  getIt.registerLazySingleton<ProductRepo>(
      () => ProductRepoImp(productsDataSource: getIt<ProductsDataSource>()));
  getIt.registerLazySingleton<CreateAdDataSource>(
      () => CreateAdDataSourceImpl(apiClient: getIt<ApiService>()));
  getIt.registerLazySingleton<CreateAdRepo>(
      () => CreateAdRepoImp(dataSource: getIt<CreateAdDataSource>()));
  getIt.registerLazySingleton<UploadAdMediaUseCase>(
      () => UploadAdMediaUseCase(getIt<CreateAdRepo>()));
  getIt.registerLazySingleton<CreateAdUseCase>(
      () => CreateAdUseCase(getIt<CreateAdRepo>()));
  getIt.registerLazySingleton<PublishAdUseCase>(
      () => PublishAdUseCase(getIt<CreateAdRepo>()));
  getIt.registerLazySingleton<UpdateAdUseCase>(
      () => UpdateAdUseCase(getIt<CreateAdRepo>()));
  getIt.registerLazySingleton<PromoteAdMediaUseCase>(
      () => PromoteAdMediaUseCase(getIt<CreateAdRepo>()));
  getIt.registerLazySingleton<DeleteAdMediaUseCase>(
      () => DeleteAdMediaUseCase(getIt<CreateAdRepo>()));
  getIt.registerLazySingleton<RateVendorDataSource>(
      () => RateVendorDataSourceImpl(apiClient: getIt<ApiService>()));
  getIt.registerLazySingleton<RateVendorRepo>(
      () => RateVendorRepoImp(dataSource: getIt<RateVendorDataSource>()));
  getIt.registerLazySingleton<RateVendorUseCase>(
      () => RateVendorUseCase(getIt<RateVendorRepo>()));
  getIt.registerLazySingleton<BahoSearchDataSource>(
      () => BahoSearchDataSourceImpl(api: getIt<ApiService>()));
  getIt.registerLazySingleton<BahoSearchRepo>(
      () => BahoSearchRepoImp(dataSource: getIt<BahoSearchDataSource>()));
  getIt.registerLazySingleton<SearchAdsUseCase>(
      () => SearchAdsUseCase(getIt<BahoSearchRepo>()));

  /// ads entity
  getIt.registerLazySingleton<AdsDataSource>(
      () => AdsDataSourceImp(apiService: getIt<ApiService>()));
  getIt.registerLazySingleton<AdsRepo>(
      () => AdsRepoImp(adsDataSource: getIt<AdsDataSource>()));
  getIt.registerLazySingleton<FetchAdsUseCase>(
      () => FetchAdsUseCase(adsRepo: getIt<AdsRepo>()));

  /// plans entity
  getIt.registerLazySingleton<PlansDataSource>(
      () => PlansDataSourceImp(apiService: getIt<ApiService>()));
  getIt.registerLazySingleton<PlansRepo>(
      () => PlansRepoImp(dataSource: getIt<PlansDataSource>()));

  /// partners and testimonials entity
  getIt.registerLazySingleton<PartnersAndTestimonialDataSource>(() =>
      PartnersAndTestimonialDataSourceImp(apiService: getIt<ApiService>()));
  getIt.registerLazySingleton<PartnerRepo>(() => PartnerRepoImp(
      partnerDataSource: getIt<PartnersAndTestimonialDataSource>()));
  getIt.registerLazySingleton<FetchPartnersUseCase>(
      () => FetchPartnersUseCase(partnerRepo: getIt<PartnerRepo>()));
  getIt.registerLazySingleton<FetchTestimonialsUseCase>(
      () => FetchTestimonialsUseCase(partnerRepo: getIt<PartnerRepo>()));

  /// Favorites entity
  getIt.registerLazySingleton<FavoritesDataSource>(
      () => FavoritesDataSourceImpl(apiClient: getIt<ApiService>()));
  getIt.registerLazySingleton<FavoritesRepo>(() =>
      FavoritesRepoImp(favoritesDataSource: getIt<FavoritesDataSource>()));
  getIt.registerLazySingleton<FetchFavoritesUseCase>(
      () => FetchFavoritesUseCase(getIt<FavoritesRepo>()));
  getIt.registerLazySingleton<AddOrDeleteFavoritesUseCase>(
      () => AddOrDeleteFavoritesUseCase(getIt<FavoritesRepo>()));
  getIt.registerLazySingleton<RemoveFavoriteUseCase>(
      () => RemoveFavoriteUseCase(getIt<FavoritesRepo>()));

  /// Verification
  getIt.registerLazySingleton<VerificationDataSource>(
      () => VerifiyDataSourceImpl(getIt<ApiService>()));

  getIt.registerFactoryParam<VerificationRepo, String, String?>(
      (param1, param2) => VerifyRepoImpl(
            dataSource: getIt<VerificationDataSource>(),
            sendTo: param1,
          ));

  /// auth
  getIt.registerLazySingleton<AuthDataSource>(
      () => AuthDataSourceImpl(getIt<ApiService>()));
  getIt.registerLazySingleton<AuthRepo>(
      () => AuthRepoImpl(getIt<AuthDataSource>()));
  getIt.registerLazySingleton<LoginUserUseCase>(
      () => LoginUserUseCase(getIt<AuthRepo>()));
  getIt.registerLazySingleton<RegisterUserUseCase>(
      () => RegisterUserUseCase(getIt<AuthRepo>()));
  getIt.registerLazySingleton<VendorRegisterUserUseCase>(
      () => VendorRegisterUserUseCase(getIt<AuthRepo>()));
  getIt.registerLazySingleton<SelectRoleUseCase>(
      () => SelectRoleUseCase(getIt<AuthRepo>()));
  getIt.registerLazySingleton<PreLoginUserUseCase>(
      () => PreLoginUserUseCase(getIt<AuthRepo>()));
  getIt.registerLazySingleton<SocialLoginUserUseCase>(
      () => SocialLoginUserUseCase(getIt<AuthRepo>()));
  getIt.registerLazySingleton<LogOutUserUseCase>(
      () => LogOutUserUseCase(getIt<AuthRepo>()));
  getIt.registerLazySingleton<DeleteAccountUseCase>(
      () => DeleteAccountUseCase(getIt<AuthRepo>()));

  /// upload
  getIt.registerLazySingleton<UploadFileDataSource>(
      () => UploadFileDataSourceImpl(getIt<ApiService>())); // upload
  getIt.registerLazySingleton<UploadFileRepo>(
      () => UploadFileRepoImpl(getIt<UploadFileDataSource>()));
  getIt.registerLazySingleton<UploadFileUseCase>(
      () => UploadFileUseCase(getIt<UploadFileRepo>()));

  /// update_profile
  getIt.registerLazySingleton<UpdateProfileDataSource>(
      () => UpdateProfileDataSourceImpl(getIt<ApiService>()));
  getIt.registerLazySingleton<UpdateProfileRepo>(
      () => UpdateProfileRepoImpl(getIt<UpdateProfileDataSource>()));
  getIt.registerLazySingleton<UpdateProfileUseCase>(
      () => UpdateProfileUseCase(getIt<UpdateProfileRepo>()));

  getIt.registerLazySingleton<VerificationDataSource>(
      instanceName: "checkphone",
      () => CheckPhoneDataSourceImpl(getIt<ApiService>()));

  getIt.registerLazySingleton<ForgetDataSource>(
      () => ForgetDataSourceImpl(getIt<ApiService>()));

  getIt.registerFactoryParam<VerificationRepo, String, Map<String, dynamic>>(
      instanceName: "checkphone",
      (param1, param2) => CheckPhoneRepo(
            data: param2,
            dataSource: getIt<VerificationDataSource>(
              instanceName: "checkphone",
            ),
            sendTo: param1,
          ));

  getIt.registerFactoryParam<ForgetPasswordRepo, String, String?>(
      (param1, param2) => ForgetPasswordRepoImpl(
            dataSource: getIt<ForgetDataSource>(),
            code: param1,
            sendTo: param2!,
          ));

  /// Stores entity
  getIt.registerLazySingleton<StoresDataSource>(
      () => StoresDataSourceImpl(apiService: getIt<ApiService>()));
  getIt.registerLazySingleton<StoresRepo>(
      () => StoresRepoImp(storesDataSource: getIt<StoresDataSource>()));
  getIt.registerLazySingleton<FetchStoresUseCase>(
      () => FetchStoresUseCase(getIt<StoresRepo>()));
  getIt.registerLazySingleton<FetchStoreDetailsUseCase>(
      () => FetchStoreDetailsUseCase(getIt<StoresRepo>()));
  getIt.registerLazySingleton<FetchStorePageUseCase>(
      () => FetchStorePageUseCase(getIt<StoresRepo>()));

  /// Location entity
  getIt.registerLazySingleton<LocationDataSource>(
      () => LocationDataSourceImpl(apiService: getIt<ApiService>()));
  getIt.registerLazySingleton<LocationRepo>(
      () => LocationRepoImp(locationDataSource: getIt<LocationDataSource>()));
  getIt.registerLazySingleton<FetchCitiesUseCase>(
      () => FetchCitiesUseCase(getIt<LocationRepo>()));
  getIt.registerLazySingleton<FetchDistrictsUseCase>(
      () => FetchDistrictsUseCase(getIt<LocationRepo>()));
  getIt.registerLazySingleton<FetchNeighborhoodsUseCase>(
      () => FetchNeighborhoodsUseCase(getIt<LocationRepo>()));

  /// Chats entity
  getIt.registerLazySingleton<ChatsDataSource>(
      () => ChatsDataSourceImpl(apiService: getIt<ApiService>()));
  getIt.registerLazySingleton<ChatsRepo>(
      () => ChatsRepoImp(dataSource: getIt<ChatsDataSource>()));
  getIt.registerLazySingleton<GetChatsUseCase>(
      () => GetChatsUseCase(getIt<ChatsRepo>()));
  getIt.registerLazySingleton<GetChatMessagesUseCase>(
      () => GetChatMessagesUseCase(getIt<ChatsRepo>()));
  getIt.registerLazySingleton<SendMessageUseCase>(
      () => SendMessageUseCase(getIt<ChatsRepo>()));
  getIt.registerLazySingleton<CreateChatUseCase>(
      () => CreateChatUseCase(getIt<ChatsRepo>()));
}
