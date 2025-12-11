import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/attendance_repository.dart';

class DevelopMarkPresenceUseCase {
  final AttendanceRepository repository;

  DevelopMarkPresenceUseCase(this.repository);

  Future<Either<Failure, bool>> call(
    String lectureId,
    String studentId,
    String qrCodeId,
  ) async {
    return await repository.developMarkPresence(lectureId, studentId, qrCodeId);
  }
}
