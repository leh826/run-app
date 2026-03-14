import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/auth_gate.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final username =
        user?.userMetadata?['username'] ?? 'Usuário';

    return Scaffold(
      backgroundColor: const Color(0xFF2C2C2C),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER VERDE
            Container(
              height: 80,
              color: const Color(0xFF3EB400),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(), // espaço esquerdo

                  IconButton(
                    onPressed: () async {
                      await Supabase.instance.client.auth
                          .signOut();

                      if (!context.mounted) return;

                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                const AuthGate()),
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.logout,
                        color: Colors.white),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 👤 FOTO
            CircleAvatar(
              radius: 70,
              backgroundImage: const NetworkImage(
                "https://i.pravatar.cc/300",
              ),
            ),

            const SizedBox(height: 15),

            // 👤 NOME
            Text(
              username,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "Editar",
              style: TextStyle(
                color: Colors.white54,
              ),
            ),

            const SizedBox(height: 30),

            // 📊 CARDS
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  _statCard("136 Km",
                      "Distância\npercorrida"),
                  _statCard("5",
                      "Territórios\nConquistado"),
                ],
              ),
            ),

            const SizedBox(height: 40),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Badges",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String value, String label) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF3EB400),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}