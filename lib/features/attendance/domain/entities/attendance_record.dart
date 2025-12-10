import 'package:equatable/equatable.dart';

class AttendanceRecord extends Equatable {
  final String lectureId;
  final String lectureTitle;
  final DateTime date;
  final String status;

  const AttendanceRecord({
    required this.lectureId,
    required this.lectureTitle,
    required this.date,
    required this.status,
  });

  @override
  List<Object> get props => [lectureId, lectureTitle, date, status];
}
