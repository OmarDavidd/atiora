import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:atiora/core/di/providers/auth_provider.dart';
import 'package:atiora/data/models/user_model.dart';
import 'package:atiora/features/auth/domain/usecases/signin_usecase.dart';
import 'package:atiora/features/auth/domain/usecases/signup_usecase.dart';
import 'package:atiora/features/auth/presentation/bloc/auth_bloc.dart';

class MockSignInUseCase extends Mock implements SignInUseCase {}

class MockSignUpUseCase extends Mock implements SignUpUseCase {}

class MockAuthProvider extends Mock implements AuthProvider {}

class MockUser extends Mock implements User {}

void main() {
  late MockSignInUseCase mockSignInUseCase;
  late MockSignUpUseCase mockSignUpUseCase;
  late MockAuthProvider mockAuthProvider;

  setUpAll(() {
    registerFallbackValue(
      const UserModel(id: 'fallback', email: 'fallback@test.com'),
    );
  });

  setUp(() {
    mockSignInUseCase = MockSignInUseCase();
    mockSignUpUseCase = MockSignUpUseCase();
    mockAuthProvider = MockAuthProvider();
  });

  group('AuthBloc', () {
    const testUser = UserModel(id: 'user-123', email: 'test@example.com');

    test('initial state should be AuthInitial', () {
      when(
        () => mockSignInUseCase.execute(any(), any()),
      ).thenAnswer((_) async => null);
      when(
        () => mockSignUpUseCase.execute(any(), any()),
      ).thenAnswer((_) async => null);

      final bloc = AuthBloc(
        mockSignInUseCase,
        mockSignUpUseCase,
        authProvider: mockAuthProvider,
      );

      expect(bloc.state, isA<AuthInitial>());
    });

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when SignInEvent succeeds',
      build: () {
        when(
          () => mockSignInUseCase.execute(any(), any()),
        ).thenAnswer((_) async => testUser);
        return AuthBloc(
          mockSignInUseCase,
          mockSignUpUseCase,
          authProvider: mockAuthProvider,
        );
      },
      act: (bloc) => bloc.add(SignInEvent('test@example.com', 'password123')),
      expect: () => [isA<AuthLoading>(), isA<AuthAuthenticated>()],
      verify: (_) {
        verify(
          () => mockSignInUseCase.execute('test@example.com', 'password123'),
        ).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when SignInEvent returns null',
      build: () {
        when(
          () => mockSignInUseCase.execute(any(), any()),
        ).thenAnswer((_) async => null);
        return AuthBloc(
          mockSignInUseCase,
          mockSignUpUseCase,
          authProvider: mockAuthProvider,
        );
      },
      act: (bloc) => bloc.add(SignInEvent('test@example.com', 'wrongpassword')),
      expect: () => [isA<AuthLoading>(), isA<AuthError>()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when SignInEvent throws',
      build: () {
        when(
          () => mockSignInUseCase.execute(any(), any()),
        ).thenThrow(Exception('Network error'));
        return AuthBloc(
          mockSignInUseCase,
          mockSignUpUseCase,
          authProvider: mockAuthProvider,
        );
      },
      act: (bloc) => bloc.add(SignInEvent('test@example.com', 'password123')),
      expect: () => [isA<AuthLoading>(), isA<AuthError>()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when SignUpEvent succeeds',
      build: () {
        when(
          () => mockSignUpUseCase.execute(any(), any()),
        ).thenAnswer((_) async => testUser);
        return AuthBloc(
          mockSignInUseCase,
          mockSignUpUseCase,
          authProvider: mockAuthProvider,
        );
      },
      act: (bloc) => bloc.add(SignUpEvent('new@example.com', 'password123')),
      expect: () => [isA<AuthLoading>(), isA<AuthAuthenticated>()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when SignUpEvent throws',
      build: () {
        when(
          () => mockSignUpUseCase.execute(any(), any()),
        ).thenThrow(Exception('Email already in use'));
        return AuthBloc(
          mockSignInUseCase,
          mockSignUpUseCase,
          authProvider: mockAuthProvider,
        );
      },
      act: (bloc) =>
          bloc.add(SignUpEvent('existing@example.com', 'password123')),
      expect: () => [isA<AuthLoading>(), isA<AuthError>()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthInitial] when CheckAuthEvent finds no user',
      build: () {
        when(() => mockAuthProvider.currentUser).thenReturn(null);
        return AuthBloc(
          mockSignInUseCase,
          mockSignUpUseCase,
          authProvider: mockAuthProvider,
        );
      },
      act: (bloc) => bloc.add(CheckAuthEvent()),
      expect: () => [isA<AuthInitial>()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthAuthenticated] when CheckAuthEvent finds user',
      build: () {
        final mockUser = MockUser();
        when(() => mockUser.id).thenReturn('user-123');
        when(() => mockUser.email).thenReturn('test@example.com');
        when(() => mockAuthProvider.currentUser).thenReturn(mockUser);
        return AuthBloc(
          mockSignInUseCase,
          mockSignUpUseCase,
          authProvider: mockAuthProvider,
        );
      },
      act: (bloc) => bloc.add(CheckAuthEvent()),
      expect: () => [isA<AuthAuthenticated>()],
    );
  });
}
