import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/attendance_record.dart';

abstract class AttendanceRepository {
  Future<Either<Failure, void>> markAttendance(
    String lectureId,
    String studentId,
    String qrCode,
    DateTime timestamp,
  );

  Future<Either<Failure, bool>> developMarkPresence(
    String lectureId,
    String studentId,
    String qrCodeId,
  );

  Future<Either<Failure, List<AttendanceRecord>>> getAttendanceHistory(
    String studentId,
    int limit,
    int offset,
  );
}
