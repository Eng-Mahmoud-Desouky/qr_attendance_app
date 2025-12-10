import '../../../../core/network/api_client.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/attendance_record_model.dart';
import 'package:dio/dio.dart';

abstract class AttendanceRemoteDataSource {
  Future<void> markAttendance(
    String lectureId,
    String studentId,
    String qrCode,
    DateTime timestamp,
  );
  Future<List<AttendanceRecordModel>> getHistory(
    String studentId,
    int limit,
    int offset,
  );
}

class AttendanceRemoteDataSourceImpl implements AttendanceRemoteDataSource {
  final ApiClient client;

  AttendanceRemoteDataSourceImpl({required this.client});

  @override
  Future<void> markAttendance(
    String lectureId,
    String studentId,
    String qrCode,
    DateTime timestamp,
  ) async {
    try {
      // Assuming qrCode string contains necessary data or we map straightforwardly
      // In a real app, we might parse the QR payload.
      // For now, mapping 'qrCode' to token hash and using lectureId as passed.
      // We also need qrCodeId. We'll assume the passed 'qrCode' might be the ID or hash.
      // Let's assume for this "Mini" implementaiton that qrCode argument IS the qrCodeId.

      await client.put(
        ApiConstants.markAttendanceEndpoint,
        data: {
          "requestAttendance": {
            "deviceId": "device-id-placeholder", // TODO: Get real device ID
            "ipAddress": "127.0.0.1", // TODO: Get real IP
            "lectureId": lectureId,
            "qrCodeId": qrCode, // Using scanned code as ID
            "studentAcademicMemberId": studentId,
          },
          "requestQrGenerator": {
            "qrCodeId": qrCode,
            "uuidTokenHash":
                "hash_placeholder", // TODO: Extract from QR payload
          },
        },
      );
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? e.message ?? 'Unknown error',
      );
    }
  }

  @override
  Future<List<AttendanceRecordModel>> getHistory(
    String studentId,
    int limit,
    int offset,
  ) async {
    try {
      final response = await client.get(
        ApiConstants.historyEndpoint,
        queryParameters: {
          'studentId': studentId,
          'limit': limit,
          // 'offset': offset, // Offset not in new API params explicitly shown in my summary, but limit is.
        },
      );
      // New API returns a List directly
      final List records = response.data;
      return records.map((e) => AttendanceRecordModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? e.message ?? 'Unknown error',
      );
    }
  }
}
