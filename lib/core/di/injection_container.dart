import 'package:atiora/core/di/providers/auth_provider.dart';
import 'package:atiora/core/di/providers/supabase_provider.dart';
import 'package:atiora/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:atiora/features/auth/domain/repositories/auth_repository.dart';
import 'package:atiora/features/auth/domain/usecases/signup_usecase.dart';
import 'package:atiora/features/books/data/datasources/books_remote_datasource.dart';
import 'package:atiora/features/books/data/repositories/books_repositorie_impl.dart';
import 'package:atiora/features/books/domain/repositories/book_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:atiora/core/storage/hive_service.dart';
import 'package:atiora/features/books/data/datasources/books_local_datasource.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:atiora/features/auth/domain/usecases/signin_usecase.dart';
import 'package:atiora/features/auth/domain/usecases/signout_usecase.dart';
import 'package:atiora/features/auth/presentation/bloc/auth_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Supabase
  await SupabaseProvider.initialize();
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  // Hive
  final hive = HiveService.instance;
  await hive.init();
  sl.registerLazySingleton<HiveService>(() => hive);

  // AuthProvider
  sl.registerLazySingleton<AuthProvider>(
    () => AuthProvider(sl<SupabaseClient>()),
  );

  // Auth stack
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthProvider>()),
  );
  sl.registerLazySingleton<SignInUseCase>(
    () => SignInUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<SignUpUseCase>(
    () => SignUpUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<SignoutUseCase>(
    () => SignoutUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<AuthBloc>(
    () => AuthBloc(sl<SignInUseCase>(), sl<SignUpUseCase>()),
  );
  sl.registerLazySingleton<BooksLocalDataSource>(
    () => BooksLocalDataSource(sl<HiveService>()),
  );
  sl.registerFactoryParam<BooksRemoteDataSource, String, dynamic>(
    (userId, _) => BooksRemoteDataSource(sl<SupabaseClient>(), userId),
  );
  sl.registerFactoryParam<BooksRepository, String, dynamic>(
    (userId, _) => BooksRepositoryImpl(
      sl<BooksLocalDataSource>(),
      sl<BooksRemoteDataSource>(param1: userId),
      userId,
    ),
  );
}
