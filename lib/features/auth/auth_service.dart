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

  Future<void> register(
  String email,
  String password, {
  required String username,
  }) async {
    final res = await supabase.auth.signUp(
      email: email,
      password: password,
      data: {'username': username},
    );

    if (res.user == null) {
      throw Exception("Erro ao criar usuário");
    }

    if (res.session == null) {
      throw Exception(
        "Um e-mail de confirmação foi enviado. Verifique sua caixa de entrada.",
      );
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    final res = await supabase
        .from("profiles")
        .select()
        .eq("id", supabase.auth.currentUser!.id)
        .single();
    return res;
  }
}
