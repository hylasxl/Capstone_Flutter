import "package:syncio_capstone/networking/dio/dio_client.dart";
import "package:syncio_capstone/networking/dio/api_endpoints.dart";
import 'package:dio/dio.dart';
import "package:syncio_capstone/services/types.dart";

class OtpService {
  final Dio _dio = DioClient().dio;

  Future<SendOTPForgetPasswordMessageResponse> sendOTPForgetPassword(
      SendOTPForgetPasswordMessageRequest request) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.sendOTPForgetPassword,
        data: request.toJson(),
      );
      return SendOTPForgetPasswordMessageResponse.fromJson(response.data);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<CheckValidOTPResponse> checkValidOTP(
      CheckValidOTPRequest request) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.checkValidOTP,
        data: request.toJson(),
      );
      return CheckValidOTPResponse.fromJson(response.data);
    } catch (e) {
      throw Exception(e);
    }
  }
}
