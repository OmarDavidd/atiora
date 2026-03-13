import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:atiora/data/models/user_model.dart';
import 'package:atiora/features/auth/domain/repositories/auth_repository.dart';
import 'package:atiora/features/auth/domain/usecases/signin_usecase.dart';
import 'package:atiora/features/auth/domain/usecases/signup_usecase.dart';
import 'package:atiora/features/auth/domain/usecases/signout_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepository;
  late SignInUseCase signInUseCase;
  late SignUpUseCase signUpUseCase;
  late SignoutUseCase signOutUseCase;

  setUp(() {
    mockRepository = MockAuthRepository();
    signInUseCase = SignInUseCase(mockRepository);
    signUpUseCase = SignUpUseCase(mockRepository);
    signOutUseCase = SignoutUseCase(mockRepository);
  });

  setUpAll(() {
    registerFallbackValue(
      UserModel(id: 'fallback', email: 'fallback@test.com'),
    );
  });

  group('SignInUseCase', () {
    const testEmail = 'test@example.com';
    const testPassword = 'password123';
    const testUser = UserModel(id: 'user-123', email: 'test@example.com');

    test('should return user when sign in is successful', () async {
      when(
        () => mockRepository.signIn(testEmail, testPassword),
      ).thenAnswer((_) async => testUser);

      final result = await signInUseCase.execute(testEmail, testPassword);

      expect(result, equals(testUser));
      verify(() => mockRepository.signIn(testEmail, testPassword)).called(1);
    });

    test('should return null when credentials are invalid', () async {
      when(
        () => mockRepository.signIn(testEmail, testPassword),
      ).thenAnswer((_) async => null);

      final result = await signInUseCase.execute(testEmail, testPassword);

      expect(result, isNull);
    });

    test('should throw exception when repository throws', () async {
      when(
        () => mockRepository.signIn(testEmail, testPassword),
      ).thenThrow(Exception('Network error'));

      expect(
        () => signInUseCase.execute(testEmail, testPassword),
        throwsException,
      );
    });
  });

  group('SignUpUseCase', () {
    const testEmail = 'newuser@example.com';
    const testPassword = 'password123';
    const testUser = UserModel(id: 'user-456', email: 'newuser@example.com');

    test('should return user when sign up is successful', () async {
      when(
        () => mockRepository.signUp(testEmail, testPassword),
      ).thenAnswer((_) async => testUser);

      final result = await signUpUseCase.execute(testEmail, testPassword);

      expect(result, equals(testUser));
      verify(() => mockRepository.signUp(testEmail, testPassword)).called(1);
    });

    test('should return null when sign up fails', () async {
      when(
        () => mockRepository.signUp(testEmail, testPassword),
      ).thenAnswer((_) async => null);

      final result = await signUpUseCase.execute(testEmail, testPassword);

      expect(result, isNull);
    });

    test('should throw exception when repository throws', () async {
      when(
        () => mockRepository.signUp(testEmail, testPassword),
      ).thenThrow(Exception('Email already in use'));

      expect(
        () => signUpUseCase.execute(testEmail, testPassword),
        throwsException,
      );
    });
  });

  group('SignoutUseCase', () {
    test('should call repository signOut', () async {
      when(() => mockRepository.signOut()).thenAnswer((_) async {});

      await signOutUseCase.execute();

      verify(() => mockRepository.signOut()).called(1);
    });

    test('should throw exception when repository throws', () async {
      when(
        () => mockRepository.signOut(),
      ).thenThrow(Exception('Sign out failed'));

      expect(() => signOutUseCase.execute(), throwsException);
    });
  });
}
