import 'package:flutter/material.dart';
import 'package:app_domine/features/auth/auth_service.dart';
import 'package:app_domine/features/auth/CheckEmailPage.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final username = TextEditingController();
  final email = TextEditingController();
  final pass = TextEditingController();
  final confirm = TextEditingController();

  final auth = AuthService();
  bool loading = false;

  @override
  void dispose() {
    username.dispose();
    email.dispose();
    pass.dispose();
    confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top,
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Chip(
                      label: Text("Voltar"),
                      backgroundColor: Colors.green,
                      labelStyle: TextStyle(color: Colors.black),
                    ),
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    "Realize seu cadastro!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w300,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    "Insira seus dados",
                    style: TextStyle(color: Colors.white54),
                  ),

                  const SizedBox(height: 30),

                  _input("Nome de usuário", username),
                  const SizedBox(height: 16),
                  _input("E-mail", email),
                  const SizedBox(height: 16),
                  _input("Digite sua senha", pass, obscure: true),
                  const SizedBox(height: 16),
                  _input("Confirme sua senha", confirm, obscure: true),

                  const Spacer(),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: loading ? null : _register,
                      child: loading
                          ? const CircularProgressIndicator(color: Colors.black)
                          : const Text(
                              "Continuar",
                              style: TextStyle(
                                  color: Colors.black, fontSize: 18),
                            ),
                    ),
                  ),
                ],
              ),
            ),
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

  Future<void> _register() async {
    if (pass.text != confirm.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("As senhas não coincidem")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      await auth.register(
        email.text.trim(),
        pass.text.trim(),
        username: username.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cadastro realizado! Confirme seu e-mail."),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const CheckEmailPage(),
        ),
      );

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro: $e")),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }
}
