import 'package:dio/dio.dart';
import '../constants/constants.dart';

class ApiClient {
  final Dio _dio;

  ApiClient({Dio? dio})
    : _dio = dio ?? Dio(BaseOptions(baseUrl: ApiConstants.baseUrl)) {
    // Add logging interceptor for debugging
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          print(
            '[API CLIENT] 📤 ${options.method} Request to: ${options.path}',
          );
          print('[API CLIENT] 🔍 Query Params: ${options.queryParameters}');
          print('[API CLIENT] 📦 Request Data: ${options.data}');
          print('[API CLIENT] 🔑 Headers: ${options.headers}');
          return handler.next(options);
        },
        onResponse: (response, handler) async {
          print(
            '[API CLIENT] ✅ Response from: ${response.requestOptions.path}',
          );
          print('[API CLIENT] 📊 Status Code: ${response.statusCode}');
          return handler.next(response);
        },
        onError: (error, handler) async {
          print('[API CLIENT] ❌ Request error: ${error.message}');
          print('[API CLIENT] 📍 Endpoint: ${error.requestOptions.path}');
          print('[API CLIENT] 📊 Status Code: ${error.response?.statusCode}');
          print('[API CLIENT] 📄 Response: ${error.response?.data}');

          // Log connection type errors
          if (error.type == DioExceptionType.connectionTimeout) {
            print(
              '[API CLIENT] ⏱️ CONNECTION TIMEOUT - Check internet connection or server availability',
            );
          } else if (error.type == DioExceptionType.receiveTimeout) {
            print(
              '[API CLIENT] ⏱️ RECEIVE TIMEOUT - Server is slow to respond',
            );
          } else if (error.type == DioExceptionType.sendTimeout) {
            print('[API CLIENT] ⏱️ SEND TIMEOUT - Upload is taking too long');
          } else if (error.type == DioExceptionType.connectionError) {
            print(
              '[API CLIENT] 🌐 CONNECTION ERROR - No internet or server unreachable',
            );
            print(
              '[API CLIENT] 💡 TIP: Check if you are on mobile data and server IP is accessible',
            );
          }

          return handler.next(error);
        },
      ),
    );

    // Add detailed logging interceptor
    _dio.interceptors.add(
      LogInterceptor(
        responseBody: true,
        requestBody: true,
        requestHeader: true,
        responseHeader: false,
        logPrint: (obj) => print('[DIO] $obj'),
      ),
    );
  }

  Future<Response> post(String path, {dynamic data}) async {
    print('[API CLIENT] 📤 POST Request to: $path');
    return await _dio.post(path, data: data);
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    print('[API CLIENT] 📤 GET Request to: $path');
    print('[API CLIENT] 🔍 Query Params: $queryParameters');
    return await _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    print('[API CLIENT] 📤 PUT Request to: $path');
    print('[API CLIENT] 🔍 Query Params: $queryParameters');
    return await _dio.put(path, data: data, queryParameters: queryParameters);
  }

  void setToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
    print('[API CLIENT] ✅ Token set in default headers');
  }

  void clearToken() {
    _dio.options.headers.remove('Authorization');
    print('[API CLIENT] 🗑️ Token cleared from headers');
  }
}
