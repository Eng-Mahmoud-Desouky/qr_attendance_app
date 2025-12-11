import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'core/network/api_client.dart';
import 'core/network/auth_interceptor.dart';
import 'core/constants/constants.dart';
import 'core/services/device_info_service.dart';

// Auth
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/datasources/auth_local_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';

// Attendance
import 'features/attendance/data/datasources/attendance_remote_data_source.dart';
import 'features/attendance/data/repositories/attendance_repository_impl.dart';
import 'features/attendance/domain/repositories/attendance_repository.dart';
import 'features/attendance/domain/usecases/mark_attendance_usecase.dart';
import 'features/attendance/domain/usecases/develop_mark_presence_usecase.dart';
import 'features/attendance/domain/usecases/get_attendance_history_usecase.dart';
import 'features/attendance/presentation/cubit/mark_attendance_cubit.dart';
import 'features/attendance/presentation/cubit/attendance_history_cubit.dart';

// Student
import 'features/student/data/datasources/student_remote_data_source.dart';
import 'features/student/data/repositories/student_repository_impl.dart';
import 'features/student/domain/repositories/student_repository.dart';
import 'features/student/domain/usecases/get_student_profile_usecase.dart';
import 'features/student/presentation/cubit/student_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Auth
  // Cubit
  sl.registerFactory(
    () => AuthCubit(loginUseCase: sl(), localDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(storage: sl()),
  );

  //! Features - Attendance
  // Cubit
  sl.registerFactory(
    () => MarkAttendanceCubit(
      markAttendanceUseCase: sl(),
      developMarkPresenceUseCase: sl(),
    ),
  );
  sl.registerFactory(() => AttendanceHistoryCubit(getHistoryUseCase: sl()));

  // Use cases
  sl.registerLazySingleton(() => MarkAttendanceUseCase(sl()));
  sl.registerLazySingleton(() => DevelopMarkPresenceUseCase(sl()));
  sl.registerLazySingleton(() => GetAttendanceHistoryUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AttendanceRepository>(
    () => AttendanceRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<AttendanceRemoteDataSource>(
    () => AttendanceRemoteDataSourceImpl(client: sl(), deviceInfoService: sl()),
  );

  //! Features - Student
  // Cubit
  sl.registerFactory(() => StudentCubit(getProfileUseCase: sl()));

  // Use cases
  sl.registerLazySingleton(() => GetStudentProfileUseCase(sl()));

  // Repository
  sl.registerLazySingleton<StudentRepository>(
    () => StudentRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<StudentRemoteDataSource>(
    () => StudentRemoteDataSourceImpl(client: sl()),
  );

  //! Core
  sl.registerLazySingleton(() => DeviceInfoService());
  sl.registerLazySingleton(() => ApiClient(dio: sl()));
  sl.registerLazySingleton(() => AuthInterceptor(authLocalDataSource: sl()));

  //! External
  sl.registerLazySingleton(() {
    final dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
    dio.interceptors.add(sl<AuthInterceptor>());
    return dio;
  });
  sl.registerLazySingleton(() => const FlutterSecureStorage());
}
