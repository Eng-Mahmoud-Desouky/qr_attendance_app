import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/student.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../datasources/auth_local_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, Student>> login(
    String username,
    String password,
  ) async {
    try {
      final loginResponse = await remoteDataSource.login(username, password);

      // Save tokens
      await localDataSource.saveTokens(
        loginResponse.accessToken,
        loginResponse.refreshToken,
      );

      // Save student data for persistence
      final studentData = {
        'id': loginResponse.student.id,
        'name': loginResponse.student.name,
        'email': loginResponse.student.email,
        'enrolledCourses': loginResponse.student.enrolledCourses,
      };
      await localDataSource.saveStudentData(studentData);

      print('[AUTH REPO] Successfully saved tokens and student data');
      print('[AUTH REPO] Student ID: ${loginResponse.student.id}');

      return Right(loginResponse.student);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
