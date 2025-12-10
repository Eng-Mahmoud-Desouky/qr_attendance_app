import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/entities/student.dart';
import '../repositories/student_repository.dart';

class GetStudentProfileUseCase implements UseCase<Student, NoParams> {
  final StudentRepository repository;

  GetStudentProfileUseCase(this.repository);

  @override
  Future<Either<Failure, Student>> call(NoParams params) async {
    return await repository.getProfile();
  }
}
