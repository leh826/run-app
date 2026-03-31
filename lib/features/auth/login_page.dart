import 'package:Domine/core/routes/home_shell.dart';
import 'package:Domine/features/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final pass = TextEditingController();
  final auth = AuthService();
  
  bool _obscurePassword = true;
  bool _isLoadingGoogle = false; // Controle de loading para o botão do Google

  @override
  void dispose() {
    email.dispose();
    pass.dispose();
    super.dispose();
  }

  // --- NOVA FUNÇÃO DE LOGIN COM GOOGLE ---
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
      await supabase.auth.signInWithIdToken(
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro no login com Google: $e")),
      );
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Chip(
                        label: Text("Voltar"),
                        backgroundColor: Colors.green,
                        labelStyle: TextStyle(color: Colors.black),
                      ),
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
                  _input("Senha", pass, isPassword: true),

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
                        borderRadius: BorderRadius.circular(30),
                      ),
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
                            SnackBar(content: Text("Erro: $e")));
                      }
                    },
                    child: const Text(
                      "Entrar",
                      style: TextStyle(color: Colors.black, fontSize: 18),
                    ),
                  ),

                  const SizedBox(height: 30),

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

                  // Atualizamos a chamada do botão aqui
                  _socialButton(
                    "Continuar com Google", 
                    Icons.g_mobiledata, 
                    _isLoadingGoogle ? null : _signInWithGoogle,
                    _isLoadingGoogle
                  ),
                  
                  const SizedBox(height: 12),

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
  }) {
    return TextField(
      controller: c,
      obscureText: isPassword ? _obscurePassword : false,
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
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.green,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              )
            : null,
      ),
    );
  }

  // Atualizamos o botão para aceitar a função e exibir o loading
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
        style: const TextStyle(color: Colors.green)
      ),
    );
  }
}