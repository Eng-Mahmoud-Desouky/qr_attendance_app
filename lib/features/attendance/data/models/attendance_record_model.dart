import '../../domain/entities/attendance_record.dart';

class AttendanceRecordModel extends AttendanceRecord {
  const AttendanceRecordModel({
    required super.lectureId,
    required super.lectureTitle,
    required super.date,
    required super.status,
  });

  factory AttendanceRecordModel.fromJson(Map<String, dynamic> json) {
    return AttendanceRecordModel(
      lectureId: json['lectureId'] ?? '',
      lectureTitle: 'Lecture', // API does not provide title
      date: DateTime.tryParse(json['checkInTime'] ?? '') ?? DateTime.now(),
      status: (json['present'] == true) ? 'Present' : 'Absent',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lectureId': lectureId,
      'lectureTitle': lectureTitle,
      'checkInTime': date.toIso8601String(),
      'present': status == 'Present',
    };
  }
}
