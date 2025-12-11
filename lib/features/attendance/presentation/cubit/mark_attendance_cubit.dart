import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/usecases/mark_attendance_usecase.dart';
import '../../domain/usecases/develop_mark_presence_usecase.dart';

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
  final DevelopMarkPresenceUseCase developMarkPresenceUseCase;

  MarkAttendanceCubit({
    required this.markAttendanceUseCase,
    required this.developMarkPresenceUseCase,
  }) : super(MarkAttendanceInitial());

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

  Future<void> developMarkPresence(
    String lectureId,
    String studentId,
    String qrCodeId,
  ) async {
    print(
      '[CUBIT] Develop mark presence triggered: lectureId=$lectureId, studentId=$studentId, qrCodeId=$qrCodeId',
    );
    emit(MarkAttendanceLoading());
    final result = await developMarkPresenceUseCase(
      lectureId,
      studentId,
      qrCodeId,
    );
    result.fold(
      (failure) {
        print('[CUBIT] Develop mark presence FAILED: ${failure.message}');
        return emit(MarkAttendanceFailure(failure.message));
      },
      (success) {
        print('[CUBIT] Develop mark presence result: $success');
        if (success) {
          return emit(
            MarkAttendanceSuccess(message: 'تم تسجيل حضورك للمحاضرة بنجاح! ✅'),
          );
        } else {
          return emit(
            MarkAttendanceFailure('فشل تسجيل الحضور. يرجى المحاولة مرة أخرى.'),
          );
        }
      },
    );
  }

  void reset() => emit(MarkAttendanceInitial());
}
