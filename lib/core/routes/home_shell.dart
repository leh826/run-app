import 'package:app_domine/features/map/map_page.dart';
import 'package:flutter/material.dart';
import 'package:app_domine/core/themes/app_colors.dart';

import 'package:app_domine/features/history/history_page.dart';
import 'package:app_domine/features/profile/profile_page.dart';
import 'package:app_domine/features/run/run_page.dart';

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
  Placeholder(), // botão central depois
  HistoryPage(),
  ProfilePage(),
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
  final selected = index == i;

  return GestureDetector(
    onTap: () => setState(() => index = i),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: selected ? Colors.white : Colors.black),
        Text(label,
            style: TextStyle(
              fontSize: 12,
              color: selected ? Colors.white : Colors.black,
            )),
      ],
    ),
  );
}

  Widget startButton() {
  return GestureDetector(
    onTap: () {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const RunPage()),
      );
    },
    child: Container(
      width: 70,
      height: 70,
      decoration: const BoxDecoration(
        color: Colors.black,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.directions_run,
          color: Colors.green, size: 30),
    ),
  );
}

}
