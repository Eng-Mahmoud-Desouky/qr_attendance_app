import '../../../../core/network/api_client.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/services/device_info_service.dart';
import '../models/attendance_record_model.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

abstract class AttendanceRemoteDataSource {
  Future<void> markAttendance(
    String lectureId,
    String studentId,
    String qrCode,
    DateTime timestamp,
  );

  Future<bool> developMarkPresence(
    String lectureId,
    String studentId,
    String qrCodeId,
  );

  Future<List<AttendanceRecordModel>> getHistory(
    String studentId,
    int limit,
    int offset,
  );
}

class AttendanceRemoteDataSourceImpl implements AttendanceRemoteDataSource {
  final ApiClient client;
  final DeviceInfoService deviceInfoService;

  AttendanceRemoteDataSourceImpl({
    required this.client,
    required this.deviceInfoService,
  });

  @override
  Future<void> markAttendance(
    String lectureId,
    String studentId,
    String qrCode,
    DateTime timestamp,
  ) async {
    try {
      // Parse the QR code JSON
      Map<String, dynamic> qrData = {};
      try {
        qrData = jsonDecode(qrCode);
        print('[ATTENDANCE] Successfully parsed QR code JSON: $qrData');
      } catch (e) {
        print('[ATTENDANCE] Failed to parse QR as JSON: $e');
        throw ServerException('Invalid QR code format');
      }

      // Extract required fields from QR code
      final String? qrCodeId = qrData['qrCodeId'];
      final String? uuidTokenHash = qrData['uuidTokenHash'];

      if (qrCodeId == null || qrCodeId.isEmpty) {
        throw ServerException('Missing qrCodeId in QR code');
      }
      if (uuidTokenHash == null || uuidTokenHash.isEmpty) {
        throw ServerException('Missing uuidTokenHash in QR code');
      }

      // Get device information
      final ipAddress = await deviceInfoService.getIpAddress();
      final deviceId = await deviceInfoService.getDeviceId();

      print('');
      print('═══════════════════════════════════════════════════');
      print('📤 [ATTENDANCE API] Preparing Mark Attendance Request');
      print('═══════════════════════════════════════════════════');
      print('🎯 Basic Information:');
      print('   ├─ Endpoint: ${ApiConstants.markAttendanceEndpoint}');
      print('   ├─ Method: PUT');
      print('   └─ Student ID: $studentId');
      print('───────────────────────────────────────────────────');
      print('📱 Device Information:');
      print('   ├─ IP Address: $ipAddress');
      print('   └─ Device ID: $deviceId');
      print('───────────────────────────────────────────────────');
      print('🎫 QR Code Data:');
      print('   ├─ QR Code ID: $qrCodeId');
      print('   ├─ Token Hash: $uuidTokenHash');
      print('   └─ Lecture ID: $lectureId');
      print('═══════════════════════════════════════════════════');

      // Prepare request body according to API specification
      final requestData = {
        "requestAttendance": {
          "ipAddress": ipAddress,
          "deviceId": deviceId,
          "lectureId": lectureId,
          "qrCodeId": qrCodeId,
          "studentAcademicMemberId": studentId,
        },
        "requestQrGenerator": {
          "qrCodeId": qrCodeId,
          "uuidTokenHash": uuidTokenHash,
        },
      };

      print('📦 Complete Request Body:');
      print(const JsonEncoder.withIndent('  ').convert(requestData));
      print('═══════════════════════════════════════════════════');
      print('🚀 Sending request...');
      print('');

      // Make API request with query parameters
      await client.put(
        ApiConstants.markAttendanceEndpoint,
        queryParameters: {'studentId': studentId, 'lectureId': lectureId},
        data: requestData,
      );

      print('');
      print('═══════════════════════════════════════════════════');
      print('✅ [ATTENDANCE API] Success! Attendance Marked');
      print('═══════════════════════════════════════════════════');
      print('');
    } on DioException catch (e) {
      print('[ATTENDANCE] ✗ DioException occurred:');
      print('[ATTENDANCE]   Status code: ${e.response?.statusCode}');
      print('[ATTENDANCE]   Response data: ${e.response?.data}');
      print('[ATTENDANCE]   Error message: ${e.message}');

      // Handle specific error codes
      if (e.response?.statusCode == 400) {
        throw ServerException('Invalid QR code or expired');
      } else if (e.response?.statusCode == 401) {
        throw ServerException('Authentication failed. Please login again.');
      } else if (e.response?.statusCode == 409) {
        throw ServerException('Attendance already marked for this lecture');
      } else if (e.response?.statusCode == 404) {
        throw ServerException('QR code or lecture not found');
      }

      throw ServerException(
        e.response?.data['message'] ?? e.message ?? 'Unknown error',
      );
    } on ServerException {
      rethrow;
    } catch (e) {
      print('[ATTENDANCE] ✗ Unexpected error: $e');
      throw ServerException('Failed to mark attendance: $e');
    }
  }

  @override
  Future<bool> developMarkPresence(
    String lectureId,
    String studentId,
    String qrCodeId,
  ) async {
    try {
      print('');
      print('═══════════════════════════════════════════════════');
      print('📤 [DEVELOP ATTENDANCE] Mark Presence Request');
      print('═══════════════════════════════════════════════════');
      print('🎯 Request Information:');
      print('   ├─ Endpoint: ${ApiConstants.developMarkAttendanceEndpoint}');
      print('   ├─ Method: PUT');
      print('   ├─ Lecture ID: $lectureId');
      print('   ├─ Student ID: $studentId');
      print('   └─ QR Code ID: $qrCodeId');
      print('═══════════════════════════════════════════════════');
      print('🚀 Sending request...');
      print('');

      // Make PUT request with query parameters
      final response = await client.put(
        ApiConstants.developMarkAttendanceEndpoint,
        queryParameters: {
          'lectureId': lectureId,
          'studentId': studentId,
          'qrCodeId': qrCodeId,
        },
      );

      // Extract boolean result from response
      final bool result = response.data as bool;

      print('');
      print('═══════════════════════════════════════════════════');
      if (result) {
        print('✅ [DEVELOP ATTENDANCE] Success! Attendance Marked');
      } else {
        print('❌ [DEVELOP ATTENDANCE] Failed to mark attendance');
      }
      print('   └─ Result: $result');
      print('═══════════════════════════════════════════════════');
      print('');

      return result;
    } on DioException catch (e) {
      print('[DEVELOP ATTENDANCE] ✗ DioException occurred:');
      print('[DEVELOP ATTENDANCE]   Status code: ${e.response?.statusCode}');
      print('[DEVELOP ATTENDANCE]   Response data: ${e.response?.data}');
      print('[DEVELOP ATTENDANCE]   Error message: ${e.message}');

      // Handle specific error codes
      if (e.response?.statusCode == 400) {
        throw ServerException('Invalid QR code or expired');
      } else if (e.response?.statusCode == 401) {
        throw ServerException('Authentication failed. Please login again.');
      } else if (e.response?.statusCode == 409) {
        throw ServerException('Attendance already marked for this lecture');
      } else if (e.response?.statusCode == 404) {
        throw ServerException('QR code or lecture not found');
      }

      throw ServerException(
        e.response?.data['message'] ?? e.message ?? 'Unknown error',
      );
    } on ServerException {
      rethrow;
    } catch (e) {
      print('[DEVELOP ATTENDANCE] ✗ Unexpected error: $e');
      throw ServerException('Failed to mark attendance: $e');
    }
  }

  @override
  Future<List<AttendanceRecordModel>> getHistory(
    String studentId,
    int limit,
    int offset,
  ) async {
    try {
      print('');
      print('═══════════════════════════════════════════════════');
      print('📤 [HISTORY API] Fetching Attendance History');
      print('═══════════════════════════════════════════════════');
      print('🎯 Request Information:');
      print('   ├─ Endpoint: ${ApiConstants.historyEndpoint}');
      print('   ├─ Method: GET');
      print('   ├─ Student ID: $studentId');
      print('   ├─ Limit: $limit');
      print('   └─ Offset: $offset');
      print('═══════════════════════════════════════════════════');

      if (studentId.isEmpty) {
        print('❌ [HISTORY API] Student ID is empty!');
        throw ServerException('Student ID is missing. Please re-login.');
      }

      print('🚀 Sending GET request...');
      print('');

      final response = await client.get(
        ApiConstants.historyEndpoint,
        queryParameters: {'studentId': studentId, 'limit': limit},
      );

      print('');
      print('═══════════════════════════════════════════════════');
      print('✅ [HISTORY API] Response Received');
      print('═══════════════════════════════════════════════════');
      print('📊 Response Data Type: ${response.data.runtimeType}');
      print('📊 Response Data: ${response.data}');
      print('═══════════════════════════════════════════════════');
      print('');

      final List records = response.data;
      final result = records
          .map((e) => AttendanceRecordModel.fromJson(e))
          .toList();

      print('✅ [HISTORY API] Successfully parsed ${result.length} records');
      print('');

      return result;
    } on DioException catch (e) {
      print('');
      print('❌ [HISTORY API] DioException occurred:');
      print('   ├─ Status code: ${e.response?.statusCode}');
      print('   ├─ Response data: ${e.response?.data}');
      print('   └─ Error message: ${e.message}');
      print('');

      throw ServerException(
        e.response?.data['message'] ?? e.message ?? 'Unknown error',
      );
    } catch (e) {
      print('');
      print('❌ [HISTORY API] Unexpected error: $e');
      print('');

      throw ServerException('Failed to fetch history: $e');
    }
  }
}
