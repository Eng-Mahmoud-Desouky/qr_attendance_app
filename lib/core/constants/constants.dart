class ApiConstants {
  static const String baseUrl =
      'https://smart-attendance-system-production-253e.up.railway.app'; // TODO: Replace with actual URL
  static const String loginEndpoint = '/api/v1/auth/login';
  static const String markAttendanceEndpoint =
      '/api/v1/attendance/mark-present';
  static const String historyEndpoint =
      '/api/v1/attendance/find-student-history';
  static const String profileEndpoint = '/api/v1/member/me';
}
