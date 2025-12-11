import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

abstract class AuthLocalDataSource {
  Future<void> saveTokens(String accessToken, String? refreshToken);
  Future<String?> getAccessToken();
  Future<void> clearTokens();

  // New methods for student data
  Future<void> saveStudentData(Map<String, dynamic> studentData);
  Future<Map<String, dynamic>?> getStudentData();
  Future<void> clearStudentData();
  Future<void> clearAll();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage storage;

  AuthLocalDataSourceImpl({required this.storage});

  static const _accessTokenKey = 'ACCESS_TOKEN';
  static const _refreshTokenKey = 'REFRESH_TOKEN';
  static const _studentDataKey = 'STUDENT_DATA';

  @override
  Future<void> saveTokens(String accessToken, String? refreshToken) async {
    await storage.write(key: _accessTokenKey, value: accessToken);
    if (refreshToken != null) {
      await storage.write(key: _refreshTokenKey, value: refreshToken);
    }
  }

  @override
  Future<String?> getAccessToken() async {
    return await storage.read(key: _accessTokenKey);
  }

  @override
  Future<void> clearTokens() async {
    await storage.delete(key: _accessTokenKey);
    await storage.delete(key: _refreshTokenKey);
  }

  @override
  Future<void> saveStudentData(Map<String, dynamic> studentData) async {
    final jsonString = jsonEncode(studentData);
    await storage.write(key: _studentDataKey, value: jsonString);
  }

  @override
  Future<Map<String, dynamic>?> getStudentData() async {
    final jsonString = await storage.read(key: _studentDataKey);
    if (jsonString == null) return null;
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      print('[AUTH LOCAL] Error decoding student data: $e');
      return null;
    }
  }

  @override
  Future<void> clearStudentData() async {
    await storage.delete(key: _studentDataKey);
  }

  @override
  Future<void> clearAll() async {
    await clearTokens();
    await clearStudentData();
  }
}
