import 'package:flutter/material.dart';
import 'login_page.dart';
import 'register_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Fundo com imagem
          Positioned.fill(
            child: Image.asset(
              "assets/images/bg_runner.jpg", // sua imagem
              fit: BoxFit.cover,
            ),
          ),

          // Gradiente escuro
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withAlpha((255 * 0.3).round()),
                    Colors.black.withAlpha((255 * 0.8).round()),
                  ],
                ),
              ),
            ),
          ),

          // Conteúdo
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Logo
                  Image.asset(
                    "assets/logo/logo.png",
                    width: 60,
                  ),

                  const Spacer(),

                  const Text(
                    "Domine",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.w300,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    "Conquiste o mundo\ncom o seu esforço!",
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Botão Cadastro (outline)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.green),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterPage(),
                          ),
                        );
                      },
                      child: const Text(
                        "Cadastro",
                        style: TextStyle(color: Colors.green, fontSize: 18),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Botão Login (cheio)
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
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginPage(),
                          ),
                        );
                      },
                      child: const Text(
                        "Login",
                        style: TextStyle(color: Colors.black, fontSize: 18),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
