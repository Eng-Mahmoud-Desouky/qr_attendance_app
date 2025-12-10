import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/student.dart';

abstract class AuthRepository {
  Future<Either<Failure, Student>> login(String username, String password);
}
