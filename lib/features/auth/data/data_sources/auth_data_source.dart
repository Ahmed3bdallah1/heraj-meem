import '../../../../../config/api_path.dart';
import '../../../../../core/service/webservice/dio_helper.dart';
import '../../../../../models/user_model.dart';
import '../../../../core/service/local_data_manager.dart';

String authPhone(Map<String, dynamic> data) {
  final raw = (data['phone'] ?? '').toString().trim();
  if (raw.startsWith('+')) return raw;
  var country =
      (data['countryCode'] ?? data['country_code'] ?? '+966').toString();
  if (!country.startsWith('+')) country = '+$country';
  var local = raw;
  if (local.startsWith('0')) local = local.substring(1);
  return '$country$local';
}

abstract class AuthDataSource {
  Future<UserAuthResponseModel> login(Map<String, dynamic> data);

  Future<UserAuthResponseModel> socialLogin(String idToken);

  Future<UserAuthResponseModel> register(Map<String, dynamic> data);

  Future<UserAuthResponseModel> vendorRegister(Map<String, dynamic> data);

  Future<UserAuthResponseModel> selectRole(String role);

  Future<UserModel> getMyProfile();

  Future<bool> logOut();

  Future<bool> deleteAccount();

  Future<PreLoginResponseModel> preLogin(Map<String, dynamic> data);
}

class AuthDataSourceImpl extends AuthDataSource {
  final ApiService apiService;

  AuthDataSourceImpl(this.apiService);

  @override
  Future<UserAuthResponseModel> login(Map<String, dynamic> data) async {
    final displayName = data['displayName']?.toString();
    final res = await apiService.post(
      url: ApiPath.verifyOTP,
      requestBody: {
        'phone': authPhone(data),
        'code': data['code'] ?? data['otp'],
        if (displayName != null && displayName.isNotEmpty)
          'displayName': displayName,
      },
      returnDataOnly: false,
    );
    return _saveSession(res);
  }

  @override
  Future<UserAuthResponseModel> socialLogin(String idsToken) async {
    final res = await apiService.post(
      url: ApiPath.googleLogin,
      requestBody: {"idToken": idsToken},
      returnDataOnly: false,
    );

    final responseData = res["data"] as Map<String, dynamic>?;

    final tokens = responseData?["tokens"] as Map<String, dynamic>?;
    if (tokens == null) {
      throw Exception("Invalid response: missing tokens field");
    }

    final accessToken = tokens["accessToken"] as String?;
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception("Invalid response: missing or empty accessToken");
    }

    final refreshToken = tokens["refreshToken"] as String?;

    await dataManager.setToken(accessToken);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await dataManager.setRefreshToken(refreshToken);
    }

    final userData = responseData?["user"] as Map<String, dynamic>?;
    if (userData == null) {
      throw Exception("Invalid response: missing user field");
    }

    final userId = userData["id"] ?? userData["_id"];
    String userIdString = '';
    if (userId is int) {
      userIdString = userId.toString();
    } else if (userId is String) {
      userIdString = userId;
    } else {
      throw Exception("Invalid response: user ID is missing or invalid");
    }

    await dataManager.setId(userIdString);
    final user = UserModel.fromJson(userData);

    return UserAuthResponseModel(
        message: res["message"] as String? ?? "Logged in successfully",
        token: accessToken,
        needsRoleSelection: res["needsRoleSelection"] as bool? ?? false,
        user: user);
  }

  @override
  Future<PreLoginResponseModel> preLogin(Map<String, dynamic> data) async {
    final res = await apiService.post(
      url: ApiPath.sendOTP,
      requestBody: {'phone': authPhone(data)},
      returnDataOnly: false,
    );
    return PreLoginResponseModel.fromJson(Map<String, dynamic>.from(res));
  }

  @override
  Future<UserAuthResponseModel> register(Map<String, dynamic> data) {
    return login(data);
  }

  @override
  Future<UserAuthResponseModel> vendorRegister(
      Map<String, dynamic> data) async {
    final res = await apiService.post(
      url: ApiPath.vendorRegister,
      requestBody: data,
      returnDataOnly: false,
    );

    final responseData = res["data"] as Map<String, dynamic>?;
    if (responseData == null) {
      throw Exception("Invalid response: missing data field");
    }

    final tokens = responseData["tokens"] as Map<String, dynamic>?;
    if (tokens == null) {
      throw Exception("Invalid response: missing tokens field");
    }

    final accessToken = tokens["accessToken"] as String?;
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception("Invalid response: missing or empty accessToken");
    }

    final refreshToken = tokens["refreshToken"] as String?;

    await dataManager.setToken(accessToken);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await dataManager.setRefreshToken(refreshToken);
    }

    final userData = responseData["user"] as Map<String, dynamic>?;
    if (userData == null) {
      throw Exception("Invalid response: missing user field");
    }

    final userId = userData["id"] ?? userData["_id"];
    String userIdString = '';
    if (userId is int) {
      userIdString = userId.toString();
    } else if (userId is String) {
      userIdString = userId;
    } else {
      throw Exception("Invalid response: user ID is missing or invalid");
    }

    await dataManager.setId(userIdString);
    final user = UserModel.fromJson(userData);

    return UserAuthResponseModel(
      message: res["message"] as String? ?? "Vendor registered successfully",
      token: accessToken,
      user: user,
    );
  }

  @override
  Future<UserModel> getMyProfile() async {
    final response =
        await apiService.get(url: ApiPath.getUser, returnDataOnly: true);
    return UserModel.fromJson(Map<String, dynamic>.from(response as Map));
  }

  Future<UserAuthResponseModel> _saveSession(Map<String, dynamic> res) async {
    final responseData = res['data'] as Map<String, dynamic>?;
    if (responseData == null) {
      throw Exception('Invalid response: missing data field');
    }

    final accessToken = responseData['accessToken'] as String?;
    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Invalid response: missing or empty accessToken');
    }

    final refreshToken = responseData['refreshToken'] as String?;
    await dataManager.setToken(accessToken);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await dataManager.setRefreshToken(refreshToken);
    }

    UserModel user;
    try {
      user = await getMyProfile();
    } catch (_) {
      final userData = responseData['user'] as Map<String, dynamic>?;
      if (userData == null) {
        throw Exception('Invalid response: missing user field');
      }
      user = UserModel.fromJson(userData);
    }

    await dataManager.setId(user.id);
    return UserAuthResponseModel(
      message: res['message'] as String? ?? 'Logged in successfully',
      token: accessToken,
      user: user,
    );
  }

  @override
  Future<bool> logOut() async {
    await apiService.post(url: ApiPath.logOut);
    return true;
  }

  @override
  Future<bool> deleteAccount() async {
    await apiService.post(url: ApiPath.deleteAccount);
    return true;
  }

  @override
  Future<UserAuthResponseModel> selectRole(String role) async {
    final res = await apiService.post(
      url: ApiPath.selectRole,
      requestBody: {'role': role},
      returnDataOnly: false,
    );

    final responseData = res["data"] as Map<String, dynamic>?;
    if (responseData == null) {
      throw Exception("Invalid response: missing data field");
    }

    final userData = responseData["user"] as Map<String, dynamic>?;
    if (userData == null) {
      throw Exception("Invalid response: missing user field");
    }

    final userId = userData["id"] ?? userData["_id"];
    String userIdString = '';
    if (userId is int) {
      userIdString = userId.toString();
    } else if (userId is String) {
      userIdString = userId;
    } else {
      throw Exception("Invalid response: user ID is missing or invalid");
    }

    await dataManager.setId(userIdString);
    final user = UserModel.fromJson(userData);

    return UserAuthResponseModel(
      message: res["message"] as String? ?? "Role selected successfully",
      token: null,
      user: user,
    );
  }
}
