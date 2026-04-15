import 'dart:developer';
import 'package:Domine/features/auth/login_page.dart';
import 'package:Domine/shared/widgets/snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:Domine/features/auth/auth_service.dart';
import 'package:Domine/core/routes/home_shell.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:Domine/shared/utils/erro_handler.dart';

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
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final auth = AuthService();
  bool loading = false;
  
  // Controle de loading para o botão do Google
  bool _isLoadingGoogle = false; 

  @override
  void dispose() {
    username.dispose();
    email.dispose();
    pass.dispose();
    confirm.dispose();
    super.dispose();
  }

  // --- FUNÇÃO DO GOOGLE (Serve para Login E Cadastro) ---
  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoadingGoogle = true;
    });

    try {
      final supabase = Supabase.instance.client;

      // 1. Acessa a instância única do GoogleSignIn
      final googleSignIn = GoogleSignIn.instance;

      // 2. Inicializa o serviço passando as chaves do seu .env
      await googleSignIn.initialize(
        serverClientId: dotenv.env['WEB_CLIENT_ID']!,
        clientId: dotenv.env['IOS_CLIENT_ID'],
      );

      // 3. Abre a janelinha nativa do Google usando authenticate()
      final googleUser = await googleSignIn.authenticate();
      
      // Se o usuário fechar a janela sem logar

      final googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw 'Faltam tokens de autenticação.';
      }

      // 4. Envia APENAS o idToken para o Supabase criar a sessão
      supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );

      if (!mounted) return;

      // Navega para a Home em caso de sucesso
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeShell()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
       showError(context, ErrorHandler.getMessage(e));
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingGoogle = false;
        });
      }
    }
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
              minHeight:
                  MediaQuery.of(context).size.height -
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
                  _input("Digite sua senha", pass, isPassword: true),
                  const SizedBox(height: 16),
                  _input("Confirme sua senha", confirm, isConfirm: true),

                  const SizedBox(height: 45),

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
                                color: Colors.black,
                                fontSize: 18,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // --- LINHAS E BOTÃO DO GOOGLE ADICIONADOS AQUI ---
                  Row(
                    children: const [
                      Expanded(child: Divider(color: Colors.white24)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          "ou",
                          style: TextStyle(color: Colors.white54),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.white24)),
                    ],
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: _socialButton(
                      "Cadastrar com Google", 
                      Icons.g_mobiledata, 
                      _isLoadingGoogle ? null : _signInWithGoogle,
                      _isLoadingGoogle
                    ),
                  ),
                  
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _input(
    String hint,
    TextEditingController c, {
    bool isPassword = false,
    bool isConfirm = false,
  }) {
    bool isObscureField = isPassword || isConfirm;

    return TextField(
      controller: c,
      obscureText: isPassword
          ? _obscurePassword
          : isConfirm
          ? _obscureConfirmPassword
          : false,
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
        suffixIcon: isObscureField
            ? IconButton(
                icon: Icon(
                  isPassword
                      ? (_obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility)
                      : (_obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility),
                  color: Colors.green,
                ),
                onPressed: () {
                  setState(() {
                    if (isPassword) {
                      _obscurePassword = !_obscurePassword;
                    } else if (isConfirm) {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    }
                  });
                },
              )
            : null,
      ),
    );
  }

  // --- NOVO WIDGET DE BOTÃO DO GOOGLE ---
  Widget _socialButton(String text, IconData icon, VoidCallback? onPressed, bool isLoading) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.green),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      onPressed: onPressed,
      icon: isLoading 
          ? const SizedBox(
              width: 24, 
              height: 24, 
              child: CircularProgressIndicator(color: Colors.green, strokeWidth: 2)
            )
          : Icon(icon, color: Colors.green, size: 28),
      label: Text(
        isLoading ? "Aguarde..." : text, 
        style: const TextStyle(color: Colors.green, fontSize: 16)
      ),
    );
  }

  Future<void> _register() async {
    if (pass.text != confirm.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("As senhas não coincidem")));
      return;
    }
    if (email.text.isEmpty || pass.text.isEmpty || username.text.isEmpty) {
      showError(context, "Preencha todos os campos");
      return;
    }

    if (!email.text.contains('@')) {
      showError(context, "Digite um email válido");
      return;
    }
    if (pass.text.length < 6) {
      showError(context, "A senha deve ter pelo menos 6 caracteres");
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
          builder: (_) => const LoginPage(),
        ),
      );
    } catch (e, stackTrace) {
      if (!mounted) return;
      log("Erro ao cadastrar usuário", error: e, stackTrace: stackTrace,);
      showError(context, ErrorHandler.getMessage(e));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }
}