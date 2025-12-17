import 'package:qr_attendance_app/core/services/url_config_service.dart';
import 'package:qr_attendance_app/injection_container.dart';

class ApiConstants {
  // Dynamic baseUrl getter that retrieves from UrlConfigService
  static String get baseUrl {
    try {
      final urlService = sl<UrlConfigService>();
      return urlService.getBaseUrl();
    } catch (e) {
      // Fallback to default if service not initialized
      return 'http://192.168.1.238:8083';
    }
  }

  static const String loginEndpoint = '/api/v1/auth/login';
  static const String markAttendanceEndpoint =
      '/api/v1/attendance/mark-present';
  static const String developMarkAttendanceEndpoint =
      '/api/v1/attendance/develop-mark-present';
  static const String historyEndpoint =
      '/api/v1/attendance/find-student-history';
  static const String profileEndpoint = '/api/v1/member/me';
}
