import "package:dio/dio.dart";
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncio_capstone/networking/networking_config.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  late final Dio dio;

  factory DioClient() {
    return _instance;
  }

  DioClient._internal() {
    BaseOptions options = BaseOptions(
        baseUrl: 'http://${NetworkingConfig.baseUrl}:${NetworkingConfig.port}',
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 60),
        headers: {
          'Content-Type': 'application/json',
        });

    dio = Dio(options);

    dio.interceptors
        .add(InterceptorsWrapper(onRequest: (options, handler) async {
      String? accessToken = await _getAccessToken();
      if (accessToken != null) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }
      return handler.next(options);
    }));
  }
}

Future<String?> _getAccessToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('access_token');
}
