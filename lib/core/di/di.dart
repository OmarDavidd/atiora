import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'providers/supabase_provider.dart';
import 'providers/auth_provider.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  await SupabaseProvider.initialize();

  sl
    ..registerLazySingleton<AuthProvider>(
      () => AuthProvider(sl<SupabaseClient>()),
    )
    ..registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);
}
