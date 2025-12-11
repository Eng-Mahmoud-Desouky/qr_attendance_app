import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../data/datasources/auth_local_data_source.dart';
import '../../data/models/student_model.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase loginUseCase;
  final AuthLocalDataSource localDataSource;

  AuthCubit({required this.loginUseCase, required this.localDataSource})
    : super(AuthInitial());

  Future<void> login(String username, String password) async {
    emit(AuthLoading());
    final result = await loginUseCase(
      LoginParams(username: username, password: password),
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (student) => emit(AuthAuthenticated(student)),
    );
  }

  /// Check if user is authenticated by loading stored student data
  Future<void> checkAuthStatus() async {
    try {
      print('[AUTH CUBIT] Checking authentication status...');

      final token = await localDataSource.getAccessToken();
      final studentData = await localDataSource.getStudentData();

      if (token != null && studentData != null) {
        print('[AUTH CUBIT] Found stored credentials');
        print('[AUTH CUBIT] Token: ${token.substring(0, 20)}...');
        print('[AUTH CUBIT] Student ID: ${studentData['id']}');

        final student = StudentModel.fromJson(studentData);
        emit(AuthAuthenticated(student));
        print('[AUTH CUBIT] ✅ Authentication restored successfully');
      } else {
        print('[AUTH CUBIT] ❌ No stored credentials found');
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      print('[AUTH CUBIT] ❌ Error checking auth status: $e');
      emit(AuthUnauthenticated());
    }
  }

  /// Logout and clear all stored data
  Future<void> logout() async {
    try {
      print('[AUTH CUBIT] Logging out...');
      await localDataSource.clearAll();
      emit(AuthUnauthenticated());
      print('[AUTH CUBIT] ✅ Logout successful');
    } catch (e) {
      print('[AUTH CUBIT] ❌ Error during logout: $e');
      emit(AuthError('Failed to logout: $e'));
    }
  }
}
