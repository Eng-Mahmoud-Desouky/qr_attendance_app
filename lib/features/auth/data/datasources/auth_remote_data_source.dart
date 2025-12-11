import '../../../../core/network/api_client.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/login_response_model.dart';
import 'package:dio/dio.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponseModel> login(String username, String password);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient client;

  AuthRemoteDataSourceImpl({required this.client});

  @override
  Future<LoginResponseModel> login(String username, String password) async {
    try {
      print('');
      print('═══════════════════════════════════════════════════');
      print('🔐 [AUTH API] Login Request');
      print('═══════════════════════════════════════════════════');
      print('👤 Username: $username');
      print('═══════════════════════════════════════════════════');

      final response = await client.post(
        ApiConstants.loginEndpoint,
        data: {'username': username, 'password': password},
      );

      print('');
      print('═══════════════════════════════════════════════════');
      print('✅ [AUTH API] Login Response Received');
      print('═══════════════════════════════════════════════════');
      print('📦 Raw Response Data:');
      print(response.data);
      print('───────────────────────────────────────────────────');
      print('🔍 Response Data Type: ${response.data.runtimeType}');
      print('═══════════════════════════════════════════════════');
      print('');

      final loginResponse = LoginResponseModel.fromJson(response.data);

      print('');
      print('═══════════════════════════════════════════════════');
      print('📋 [AUTH API] Parsed Login Response');
      print('═══════════════════════════════════════════════════');
      print(
        '🎫 Access Token: ${loginResponse.accessToken.substring(0, 20)}...',
      );
      print('👤 Student ID: ${loginResponse.student.id}');
      print('👤 Student Name: ${loginResponse.student.name}');
      print('👤 Student Email: ${loginResponse.student.email}');
      print('═══════════════════════════════════════════════════');
      print('');

      return loginResponse;
    } on DioException catch (e) {
      print('');
      print('❌ [AUTH API] Login Failed');
      print('   ├─ Status Code: ${e.response?.statusCode}');
      print('   ├─ Response: ${e.response?.data}');
      print('   └─ Error: ${e.message}');
      print('');

      throw ServerException(
        e.response?.data['message'] ?? e.message ?? 'Unknown error',
      );
    } catch (e) {
      print('');
      print('❌ [AUTH API] Unexpected Error: $e');
      print('');

      throw ServerException('Login failed: $e');
    }
  }
}
