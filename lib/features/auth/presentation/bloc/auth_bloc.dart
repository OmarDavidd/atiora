import 'package:atiora/core/di/injection_container.dart';
import 'package:atiora/core/di/providers/auth_provider.dart';
import 'package:atiora/data/models/user_model.dart';
import 'package:atiora/features/auth/domain/usecases/signin_usecase.dart';
import 'package:atiora/features/auth/domain/usecases/signup_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class AuthEvent {}

class SignInEvent extends AuthEvent {
  final String email, password;
  SignInEvent(this.email, this.password);
}

class SignUpEvent extends AuthEvent {
  final String email, password;
  SignUpEvent(this.email, this.password);
}

class CheckAuthEvent extends AuthEvent {}

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserModel user;
  AuthAuthenticated(this.user);
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInUseCase signInUseCase;
  final SignUpUseCase signUpUseCase;
  final AuthProvider authProvider;

  AuthBloc(this.signInUseCase, this.signUpUseCase, {AuthProvider? authProvider})
    : authProvider = authProvider ?? sl<AuthProvider>(),
      super(AuthInitial()) {
    on<SignInEvent>(_onSignIn);
    on<SignUpEvent>(_onSignUp);
    on<CheckAuthEvent>(_onCheckAuth);
  }

  Future<void> _onSignIn(SignInEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await signInUseCase.execute(event.email, event.password);
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthError('Credenciales inválidas'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignUp(SignUpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await signUpUseCase.execute(event.email, event.password);
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthError('Registro falló'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onCheckAuth(
    CheckAuthEvent event,
    Emitter<AuthState> emit,
  ) async {
    final user = authProvider.currentUser;

    if (user != null) {
      emit(AuthAuthenticated(UserModel(id: user.id, email: user.email ?? '')));
    } else {
      emit(AuthInitial());
    }
  }
}
