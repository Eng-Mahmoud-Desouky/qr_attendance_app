import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../auth/domain/entities/student.dart';
import '../../domain/usecases/get_student_profile_usecase.dart';
import '../../../../core/usecases/usecase.dart';

abstract class StudentState extends Equatable {
  @override
  List<Object> get props => [];
}

class StudentInitial extends StudentState {}

class StudentLoading extends StudentState {}

class StudentLoaded extends StudentState {
  final Student student;
  StudentLoaded(this.student);
}

class StudentFailure extends StudentState {
  final String message;
  StudentFailure(this.message);
}

class StudentCubit extends Cubit<StudentState> {
  final GetStudentProfileUseCase getProfileUseCase;

  StudentCubit({required this.getProfileUseCase}) : super(StudentInitial());

  Future<void> loadProfile() async {
    emit(StudentLoading());
    final result = await getProfileUseCase(NoParams());
    result.fold(
      (failure) => emit(StudentFailure(failure.message)),
      (student) => emit(StudentLoaded(student)),
    );
  }
}
