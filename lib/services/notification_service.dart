import "package:syncio_capstone/networking/dio/dio_client.dart";
import "package:syncio_capstone/networking/dio/api_endpoints.dart";
import 'package:dio/dio.dart';
import "package:syncio_capstone/services/types.dart";

class NotificationService {
  final Dio _dio = DioClient().dio;

  Future<RegisterDeviceResponse> registerDevice(RegisterDevice request) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.registerDevice,
        data: request.toJson(),
      );
      return RegisterDeviceResponse.fromJson(response.data);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<GetNotificationResponse> getNotifications(
      GetNotificationRequest request) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.getNotifications,
        data: request.toJson(),
      );
      return GetNotificationResponse.fromJson(response.data);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<MarkAsReadNotificationResponse> markAsRead(
      MarkAsReadNotificationRequest request) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.markAsRead,
        data: request.toJson(),
      );
      return MarkAsReadNotificationResponse.fromJson(response.data);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<CountUnreadNotiResponse> countUnread(
      CountUnreadNotiRequest request) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.countUnread,
        data: request.toJson(),
      );
      return CountUnreadNotiResponse.fromJson(response.data);
    } catch (e) {
      throw Exception(e);
    }
  }
}
