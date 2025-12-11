import 'package:dio/dio.dart';
import '../../features/auth/data/datasources/auth_local_data_source.dart';

class AuthInterceptor extends Interceptor {
  final AuthLocalDataSource authLocalDataSource;

  AuthInterceptor({required this.authLocalDataSource});

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    print('');
    print('[AUTH INTERCEPTOR] 🔐 Processing request to: ${options.path}');

    final token = await authLocalDataSource.getAccessToken();

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
      print('[AUTH INTERCEPTOR] ✅ Token added to request');
      print(
        '[AUTH INTERCEPTOR] 🎫 Token preview: ${token.substring(0, 20)}...',
      );
    } else {
      print('[AUTH INTERCEPTOR] ⚠️ No token found in storage!');
    }

    print('[AUTH INTERCEPTOR] 📋 Final headers: ${options.headers}');
    print('');

    handler.next(options);
  }
}
