import "package:syncio_capstone/networking/dio/dio_client.dart";
import "package:syncio_capstone/networking/dio/api_endpoints.dart";
import 'package:dio/dio.dart';
import "package:syncio_capstone/services/types.dart";

class ModerationService {
  final Dio _dio = DioClient().dio;

  Future<ReportResponse> reportPost(ReportPost request) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.reportPost,
        data: request.toJson(),
      );
      return ReportResponse.fromJson(response.data);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<ReportResponse> reportAccount(ReportAccount request) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.reportAccount,
        data: request.toJson(),
      );
      return ReportResponse.fromJson(response.data);
    } catch (e) {
      throw Exception(e);
    }
  }
}
