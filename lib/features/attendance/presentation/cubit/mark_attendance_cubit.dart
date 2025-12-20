import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/usecases/mark_attendance_usecase.dart';

abstract class MarkAttendanceState extends Equatable {
  @override
  List<Object> get props => [];
}

class MarkAttendanceInitial extends MarkAttendanceState {}

class MarkAttendanceLoading extends MarkAttendanceState {}

class MarkAttendanceSuccess extends MarkAttendanceState {
  final String message;
  MarkAttendanceSuccess({this.message = 'Attendance Marked'});

  @override
  List<Object> get props => [message];
}

class MarkAttendanceFailure extends MarkAttendanceState {
  final String message;
  MarkAttendanceFailure(this.message);

  @override
  List<Object> get props => [message];
}

class MarkAttendanceCubit extends Cubit<MarkAttendanceState> {
  final MarkAttendanceUseCase markAttendanceUseCase;

  MarkAttendanceCubit({required this.markAttendanceUseCase})
    : super(MarkAttendanceInitial());

  Future<void> markAttendance(
    String lectureId,
    String studentId,
    String qrCode,
    DateTime timestamp,
  ) async {
    print(
      '[CUBIT] Mark attendance triggered: lectureId=$lectureId, studentId=$studentId',
    );
    emit(MarkAttendanceLoading());
    final result = await markAttendanceUseCase(
      MarkAttendanceParams(
        lectureId: lectureId,
        studentId: studentId,
        qrCode: qrCode,
        timestamp: timestamp,
      ),
    );
    result.fold(
      (failure) {
        print('[CUBIT] Mark attendance FAILED: ${failure.message}');
        return emit(MarkAttendanceFailure(failure.message));
      },
      (_) {
        print('[CUBIT] Mark attendance SUCCESS');
        return emit(MarkAttendanceSuccess());
      },
    );
  }

  void reset() => emit(MarkAttendanceInitial());
}
