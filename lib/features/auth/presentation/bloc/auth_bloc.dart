import 'package:atiora/data/models/user_model.dart';
import 'package:atiora/features/auth/domain/usecases/signin_usecase.dart';
import 'package:atiora/features/auth/domain/usecases/signup_usecase.dart';
import 'package:flutter/cupertino.dart';
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

  AuthBloc(this.signInUseCase, this.signUpUseCase) : super(AuthInitial()) {
    on<SignInEvent>(_onSignIn);
    on<SignUpEvent>(_onSignUp);
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
      emit(AuthError('Error de login: ${e.toString()}'));
    }
  }

  Future<void> _onSignUp(SignUpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await signUpUseCase.execute(event.email, event.password);
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthError('Error de registro'));
      }
    } catch (e) {
      emit(AuthError('Error: ${e.toString()}'));
    }
  }
}
