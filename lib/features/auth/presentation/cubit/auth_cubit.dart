import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/login_usecase.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase loginUseCase;

  AuthCubit({required this.loginUseCase}) : super(AuthInitial());

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

  // Could add checkAuthStatus here if we implement checking token on startup
}
