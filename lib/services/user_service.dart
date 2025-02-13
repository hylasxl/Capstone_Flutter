import "package:syncio_capstone/networking/dio/dio_client.dart";
import "package:syncio_capstone/networking/dio/api_endpoints.dart";
import 'package:dio/dio.dart';
import "package:syncio_capstone/services/types.dart";

class UserService {
  final Dio _dio = DioClient().dio;

  Future<CheckDuplicateResponse> checkDuplicateCredentials(
      CheckDuplicateRequest request) async {
    try {
      final response = await _dio.post(ApiEndpoints.checkDuplicateCredentials,
          data: request.toJson());
      return CheckDuplicateResponse.fromJson(response.data);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response =
          await _dio.post(ApiEndpoints.login, data: request.toJson());
      return LoginResponse.fromJson(response.data);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<SignUpResponse> register(SignUpRequest request) async {
    try {
      final response =
          await _dio.post(ApiEndpoints.register, data: request.toJson());
      return SignUpResponse.fromJson(response.data);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<GetAccountInfoResponse> getAccountInfo(
      GetAccountInfoRequest request) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.getAccountInfo,
        data: request.toJson(),
      );
      return GetAccountInfoResponse.fromJson(response.data);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<GetProfileInfoResponse> getProfileInfo(
      GetProfileInfoRequest request) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.getProfileInfo,
        data: request.toJson(),
      );
      return GetProfileInfoResponse.fromJson(response.data);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<ChangeAvatarResponse> changeAvatar(ChangeAvatarRequest request) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.changeAvatar,
        data: request.toJson(),
      );
      return ChangeAvatarResponse.fromJson(response.data);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<ChangeAccountInfoResponse> changeUserInfo(
      ChangeAccountInfoRequest request) async {
    try {
      final response = await _dio.patch(
        ApiEndpoints.changeUserInfo,
        data: request.toJson(),
      );
      return ChangeAccountInfoResponse.fromJson(response.data);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<LoginResponse> loginWithGoogle(LoginWithGoogleRequest request) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.loginWithGoogle,
        data: request.toJson(),
      );
      return LoginResponse.fromJson(response.data);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<VerifyUsernameAndEmailResponse> verifyEmailAndUsername(
      VerifyUsernameAndEmailRequest request) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.verifyEmailAndUsername,
        data: request.toJson(),
      );
      return VerifyUsernameAndEmailResponse.fromJson(response.data);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<ChangePasswordResponse> changePassword(
      ChangePasswordRequest request) async {
    try {
      final response = await _dio.patch(
        ApiEndpoints.changePassword,
        data: request.toJson(),
      );
      return ChangePasswordResponse.fromJson(response.data);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<SearchAccountResponse> searchAccount(
      SearchAccountRequest request) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.searchAccount,
        data: request.toJson(),
      );
      return SearchAccountResponse.fromJson(response.data);
    } catch (e) {
      throw Exception(e);
    }
  }
}
