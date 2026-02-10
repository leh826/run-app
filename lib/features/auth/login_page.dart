import 'package:app_domine/core/routes/home_shell.dart';
import 'package:app_domine/features/auth/auth_service.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final pass = TextEditingController();
  final auth = AuthService();

  @override
  void dispose() {
    email.dispose();
    pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Chip(
                  label: const Text("Voltar"),
                  backgroundColor: Colors.green,
                  labelStyle: const TextStyle(color: Colors.black),
                ),
              ),

              const SizedBox(height: 40),

              const Text(
                "Bem vindo de volta!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w300,
                ),
              ),

              const SizedBox(height: 40),

              _input("E-mail", email),
              const SizedBox(height: 16),
              _input("Senha", pass, obscure: true),

              const SizedBox(height: 12),

              const Text(
                "Esqueceu sua senha?",
                style: TextStyle(color: Colors.white54),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: () async {
                  try {
                    await auth.login(email.text, pass.text);
                    
                    if (!mounted) return;
                    
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeShell()),
                      (route) => false,
                    );
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Erro: $e")),
                    );
                  }
                },
                child: const Text("Entrar",
                    style: TextStyle(color: Colors.black, fontSize: 18)),
              ),

              const SizedBox(height: 30),

              Row(
                children: const [
                  Expanded(child: Divider(color: Colors.white24)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text("ou", style: TextStyle(color: Colors.white54)),
                  ),
                  Expanded(child: Divider(color: Colors.white24)),
                ],
              ),

              const SizedBox(height: 20),

              _socialButton("Continuar com Google", Icons.g_mobiledata),
              const SizedBox(height: 12),
              _socialButton("Continuar com Apple", Icons.apple),
            ],
          ),
        ),
      ),
    );
  }

  Widget _input(String hint, TextEditingController c,
      {bool obscure = false}) {
    return TextField(
      controller: c,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.green),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.green, width: 2),
        ),
      ),
    );
  }

  Widget _socialButton(String text, IconData icon) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.green),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      onPressed: () {},
      icon: Icon(icon, color: Colors.green),
      label:
          Text(text, style: const TextStyle(color: Colors.green)),
    );
  }

}
