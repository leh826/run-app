import 'package:Domine/features/map/map_page.dart';
import 'package:Domine/features/ranking/ranking_page.dart';
import 'package:flutter/material.dart';
import 'package:Domine/core/themes/app_colors.dart';

import 'package:Domine/features/history/history_page.dart';
import 'package:Domine/features/profile/profile_page.dart';
import 'package:Domine/features/run/run_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  static HomeShellState? of(BuildContext context) =>
      context.findAncestorStateOfType<HomeShellState>();

  @override
  State<HomeShell> createState() => HomeShellState();
}

class HomeShellState extends State<HomeShell> {
  int index = 0;

  void goToHistory() {
    setState(() => index = 2);
  }

  final pages = const [
    MapPage(),
    RankingPage(),
    Placeholder(), // botão central depois
    HistoryPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: pages[index],

      floatingActionButton: Container(
        // Aumentamos um pouquinho a altura e largura para acomodar o texto
        height: 75,
        width: 75,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black,
          boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 8)],
        ),
        child: GestureDetector(
          onTap: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const RunPage()));
          },
          //collumn
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.directions_run, color: Colors.green, size: 28),
              SizedBox(height: 4), // Pequeno espaço entre ícone e texto
              Text(
                "Iniciar Corrida",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          // ------------------------------------------
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: Container(
        height: 75,
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.green,
          borderRadius: BorderRadius.circular(25),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 8)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            navItem(Icons.home, "Home", 0),
            navItem(Icons.emoji_events, "Ranking", 1),

            // Aumentamos o espaço vazio para o novo botão maior
            const SizedBox(width: 80),

            navItem(Icons.history, "Histórico", 3),
            navItem(Icons.person, "Perfil", 4),
          ],
        ),
      ),
    );
  }

  Widget navItem(IconData icon, String label, int i) {
    final selected = index == i;

    return GestureDetector(
      onTap: () => setState(() => index = i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? Colors.black : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 26, color: selected ? Colors.green : Colors.black),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                color: selected ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget startButton() {
    return GestureDetector(
      onTap: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const RunPage()));
      },
      child: Container(
        width: 70,
        height: 70,
        decoration: const BoxDecoration(
          color: Colors.black,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.directions_run, color: Colors.green, size: 30),
      ),
    );
  }
}
