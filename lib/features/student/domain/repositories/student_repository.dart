import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/student.dart';

abstract class StudentRepository {
  Future<Either<Failure, Student>> getProfile();
}
