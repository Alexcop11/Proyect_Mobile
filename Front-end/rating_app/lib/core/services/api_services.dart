import 'package:dio/dio.dart';
import '../utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiServices {
  late Dio _dio;
  String? _token;
  String? _role;
  String? _email;

  ApiServices() {
    _configDio();
  }

  void _configDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: Api_Constants.url,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_token != null) {
            options.headers['Authorization'] = 'Bearer $_token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            print("Token expirado");
            cleanToken();
          }
          return handler.next(error);
        },
      ),
    );
  }

  void setRole(String role) {
    _role = role;
  }

  void cleanRole() {
    _role = null;
  }

  void setToken(String token) {
    _token = token;
  }

  void cleanToken() {
    _token = null;
  }

  Future<Response> request({
    required String method,
    required String endpoint,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.request(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: Options(method: method),
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException error) {
    if (error.response != null) {
      final responseData = error.response!.data;
      if (responseData is Map && responseData.containsKey('message')) {
        return Exception(responseData['message']);
      }
      return Exception('Error del servidor: ${error.response!.statusCode}');
    } else {
      return Exception('Error de conexión: ${error.message}');
    }
  }

  void setEmail(String email) {
    _email = email;
  }

  void cleanEmail() {
    _email = null;
  }
}
