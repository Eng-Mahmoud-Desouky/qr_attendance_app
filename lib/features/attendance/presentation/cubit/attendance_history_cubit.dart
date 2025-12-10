import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/attendance_record.dart';
import '../../domain/usecases/get_attendance_history_usecase.dart';

abstract class AttendanceHistoryState extends Equatable {
  @override
  List<Object> get props => [];
}

class AttendanceHistoryInitial extends AttendanceHistoryState {}

class AttendanceHistoryLoading extends AttendanceHistoryState {}

class AttendanceHistoryLoaded extends AttendanceHistoryState {
  final List<AttendanceRecord> records;
  AttendanceHistoryLoaded(this.records);
}

class AttendanceHistoryFailure extends AttendanceHistoryState {
  final String message;
  AttendanceHistoryFailure(this.message);
}

class AttendanceHistoryCubit extends Cubit<AttendanceHistoryState> {
  final GetAttendanceHistoryUseCase getHistoryUseCase;

  AttendanceHistoryCubit({required this.getHistoryUseCase})
      : super(AttendanceHistoryInitial());

  Future<void> loadHistory(String studentId,
      {int limit = 50, int offset = 0}) async {
    emit(AttendanceHistoryLoading());
    final result = await getHistoryUseCase(
        GetHistoryParams(studentId, limit: limit, offset: offset));
    result.fold(
      (failure) => emit(AttendanceHistoryFailure(failure.message)),
      (records) => emit(AttendanceHistoryLoaded(records)),
    );
  }
}
