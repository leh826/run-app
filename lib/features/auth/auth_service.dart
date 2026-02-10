import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final supabase = Supabase.instance.client;

  bool get isLogged => supabase.auth.currentSession != null;

  Stream<AuthState> get onAuthChange =>
      supabase.auth.onAuthStateChange;

  Future<void> login(String email, String password) async {
    final res = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (res.session == null) {
      throw Exception("Login inválido");
    }
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
  }
}
