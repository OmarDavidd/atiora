import 'package:flutter/rendering.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider {
  final SupabaseClient client;

  AuthProvider(this.client);

  Future<AuthResponse> signUp(String email, String password) async {
    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
      );
      return response;
    } catch (e, stackTrace) {
      debugPrint("AuthProvider.signUp failed for '$email': $e");
      debugPrint('$stackTrace');
      rethrow;
    }
  }

  Future<AuthResponse> signIn(String email, String password) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e, stackTrace) {
      debugPrint("AuthProvider.signIn failed for '$email': $e");
      debugPrint('$stackTrace');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await client.auth.signOut();
    } catch (e, stackTrace) {
      debugPrint('AuthProvider.signOut failed: $e');
      debugPrint('$stackTrace');
      rethrow;
    }
  }

  User? get currentUser => client.auth.currentUser;
}
