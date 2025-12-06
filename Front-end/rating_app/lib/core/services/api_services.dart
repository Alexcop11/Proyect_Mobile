import 'package:dio/dio.dart';
import '../utils/constants.dart';

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
        // ✅ Aumentar timeouts
        connectTimeout: const Duration(seconds: 30), // Era 10, ahora 30
        receiveTimeout: const Duration(seconds: 30), // Era 10, ahora 30
        sendTimeout: const Duration(seconds: 30), // Nuevo
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
          // Log de la petición
          print('📤 ${options.method} ${options.path}');
          if (_token != null) {
            print('🔑 Token: ${_token!.substring(0, 20)}...');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Log de respuesta exitosa
          print('✅ ${response.statusCode} ${response.requestOptions.path}');
          return handler.next(response);
        },
        onError: (error, handler) {
          // Log de error
          print('❌ Error: ${error.type}');
          print('❌ Message: ${error.message}');

          if (error.response?.statusCode == 401) {
            print("🔒 Token expirado o inválido");
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
    print('🔑 Token configurado en ApiServices');
  }

  void cleanToken() {
    _token = null;
    print('🗑️ Token eliminado de ApiServices');
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
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return Exception(
          'Timeout de conexión. Verifica tu conexión a internet.',
        );

      case DioExceptionType.sendTimeout:
        return Exception('Timeout al enviar datos. El servidor no responde.');

      case DioExceptionType.receiveTimeout:
        return Exception(
          'Timeout al recibir datos. El servidor tardó demasiado.',
        );

      case DioExceptionType.badResponse:
        final responseData = error.response!.data;
        if (responseData is Map && responseData.containsKey('message')) {
          return Exception(responseData['message']);
        }
        if (responseData is Map && responseData.containsKey('text')) {
          return Exception(responseData['text']);
        }
        return Exception('Error del servidor: ${error.response!.statusCode}');

      case DioExceptionType.cancel:
        return Exception('Petición cancelada');

      case DioExceptionType.connectionError:
        return Exception(
          'Error de conexión. Verifica que el servidor esté corriendo.',
        );

      default:
        return Exception('Error de red: ${error.message}');
    }
  }

 

  void setEmail(String email) {
    _email = email;
  }

  void cleanEmail() {
    _email = null;
  }
}
