import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/auth_gate.dart'; 
import 'package:Domine/core/themes/app_colors.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos o SafeArea interno para garantir que o cabeçalho 
    // não fique escondido atrás do notch do celular
    return SafeArea(
      bottom: false,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.green, // Use sua cor padrão aqui
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 6),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Logo na esquerda
            Image.asset('assets/logo/logo.png', height: 32),
            
            // Botão de Sair na direita
            TextButton.icon(
              onPressed: () async {
                await Supabase.instance.client.auth.signOut();
                
                if (!context.mounted) return;
                
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const AuthGate()),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.logout, color: Colors.white, size: 20),
              label: const Text(
                "Sair",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}