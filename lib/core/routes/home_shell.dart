import 'package:app_domine/features/map/map_page.dart';
import 'package:flutter/material.dart';
import 'package:app_domine/core/themes/app_colors.dart';
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int index = 0;

  final pages = const [
    MapPage(),
    Placeholder(),
    Placeholder(),
    Placeholder(),
    Placeholder(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: Container(
        height: 75,
        decoration: const BoxDecoration(
          color: AppColors.green,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            navItem(Icons.home, "Home", 0),
            navItem(Icons.emoji_events, "Ranking", 1),
            startButton(),
            navItem(Icons.history, "Histórico", 3),
            navItem(Icons.person, "Perfil", 4),
          ],
        ),
      ),
    );
  }

  Widget navItem(IconData icon, String label, int i) {
    return GestureDetector(
      onTap: () => setState(() => index = i),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.black),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget startButton() {
    return Container(
      width: 70,
      height: 70,
      decoration: const BoxDecoration(
        color: Colors.black,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.directions_run, color: Colors.green, size: 30),
    );
  }
}
