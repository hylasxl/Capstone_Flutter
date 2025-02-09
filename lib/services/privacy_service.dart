import "package:syncio_capstone/networking/dio/dio_client.dart";
import "package:syncio_capstone/networking/dio/api_endpoints.dart";
import 'package:dio/dio.dart';
import "package:syncio_capstone/services/types.dart";

class PrivacyService {
  final Dio _dio = DioClient().dio;

  Future<SetPrivacyResponse> setPrivacy(SetPrivacyRequest request) async {
    try {
      final response = await _dio.put(
        ApiEndpoints.setPrivacy,
        data: request.toJson(),
      );
      return SetPrivacyResponse.fromJson(response.data);
    } catch (e) {
      throw Exception(e);
    }
  }
}
