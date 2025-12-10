import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/attendance_repository.dart';

class MarkAttendanceUseCase implements UseCase<void, MarkAttendanceParams> {
  final AttendanceRepository repository;

  MarkAttendanceUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(MarkAttendanceParams params) async {
    return await repository.markAttendance(
      params.lectureId,
      params.studentId,
      params.qrCode,
      params.timestamp,
    );
  }
}

class MarkAttendanceParams extends Equatable {
  final String lectureId;
  final String studentId;
  final String qrCode;
  final DateTime timestamp;

  const MarkAttendanceParams({
    required this.lectureId,
    required this.studentId,
    required this.qrCode,
    required this.timestamp,
  });

  @override
  List<Object> get props => [lectureId, studentId, qrCode, timestamp];
}
