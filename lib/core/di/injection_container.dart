import 'package:atiora/core/di/providers/auth_provider.dart';
import 'package:atiora/core/di/providers/supabase_provider.dart';
import 'package:atiora/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:atiora/features/auth/domain/repositories/auth_repository.dart';
import 'package:atiora/features/auth/domain/usecases/signup_usecase.dart';
import 'package:atiora/features/auth/domain/usecases/signin_usecase.dart';
import 'package:atiora/features/auth/domain/usecases/signout_usecase.dart';
import 'package:atiora/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:atiora/features/books/data/datasources/books_local_datasource.dart';
import 'package:atiora/features/books/data/datasources/books_remote_datasource.dart';
import 'package:atiora/features/books/data/repositories/books_repositorie_impl.dart';
import 'package:atiora/features/books/domain/repositories/book_repository.dart';
import 'package:atiora/features/books/presentation/bloc/books_bloc.dart';
import 'package:atiora/features/dashboards/presentation/bloc/home_stats_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:atiora/core/storage/hive_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! External
  await SupabaseProvider.initialize();

  // Core
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  // Storage
  final hive = HiveService.instance;
  await hive.init();
  sl.registerLazySingleton<HiveService>(() => hive);

  // Auth Provider
  sl.registerLazySingleton<AuthProvider>(
    () => AuthProvider(sl<SupabaseClient>()),
  );

  // Auth Repository & UseCases
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerLazySingleton<SignInUseCase>(
    () => SignInUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<SignUpUseCase>(
    () => SignUpUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<SignoutUseCase>(
    () => SignoutUseCase(sl<AuthRepository>()),
  );

  // Auth Bloc
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(sl<SignInUseCase>(), sl<SignUpUseCase>()),
  );

  // Books Local
  sl.registerLazySingleton<BooksLocalDataSource>(
    () => BooksLocalDataSource(sl<HiveService>()),
  );

  // Books Remote
  sl.registerLazySingleton<BooksRemoteDataSource>(
    () => BooksRemoteDataSource(sl<SupabaseClient>()),
  );

  // Books Repository
  sl.registerLazySingleton<BooksRepository>(
    () => BooksRepositoryImpl(
      sl<BooksLocalDataSource>(),
      sl<BooksRemoteDataSource>(),
    ),
  );

  // Books Bloc
  sl.registerFactory<BooksBloc>(() => BooksBloc(sl<BooksRepository>()));

  // Home stats Bloc
  sl.registerFactory<HomeStatsBloc>(() => HomeStatsBloc(sl<BooksRepository>()));

}
