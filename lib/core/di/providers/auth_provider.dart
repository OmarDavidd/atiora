import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider {
  final SupabaseClient client;

  AuthProvider(this.client);

  Future<AuthResponse> signUp(String email, String password) {
    return client.auth.signUp(email: email, password: password);
  }

  Future<AuthResponse> signIn(String email, String password) {
    return client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() {
    return client.auth.signOut();
  }

  Future<void> updatePassword(String newPassword) {
    return client.auth.updateUser(UserAttributes(password: newPassword));
  }

  User? get currentUser => client.auth.currentUser;
}
