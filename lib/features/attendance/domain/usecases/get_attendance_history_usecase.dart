import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/attendance_record.dart';
import '../repositories/attendance_repository.dart';

class GetAttendanceHistoryUseCase
    implements UseCase<List<AttendanceRecord>, GetHistoryParams> {
  final AttendanceRepository repository;

  GetAttendanceHistoryUseCase(this.repository);

  @override
  Future<Either<Failure, List<AttendanceRecord>>> call(
      GetHistoryParams params) async {
    return await repository.getAttendanceHistory(
        params.studentId, params.limit, params.offset);
  }
}

class GetHistoryParams extends Equatable {
  final String studentId;
  final int limit;
  final int offset;

  const GetHistoryParams(this.studentId, {this.limit = 50, this.offset = 0});

  @override
  List<Object> get props => [studentId, limit, offset];
}
