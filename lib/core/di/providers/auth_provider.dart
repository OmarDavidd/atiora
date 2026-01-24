import 'package:flutter/rendering.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider {
  final SupabaseClient client;

  AuthProvider(this.client);

  Future<AuthResponse> signUp(String email, String password) async {
    try {
      debugPrint("lLEGA AL PROVIDERs");
      final response = await client.auth.signUp(
        email: email,
        password: password,
      );
      debugPrint("AAA");

      debugPrint(response.user?.email);
      return response;
    } catch (e, stackTrace) {
      debugPrint("🔴 ERROR signUp '$email': $e");
      debugPrint("📍 StackTrace: $stackTrace");
      rethrow; // Mantiene error para Bloc
    }
  }

  Future<AuthResponse> signIn(String email, String password) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await client.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  User? get currentUser => client.auth.currentUser;
}
