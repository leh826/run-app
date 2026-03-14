import 'package:app_domine/features/map/map_page.dart';
import 'package:flutter/material.dart';
import 'package:app_domine/core/themes/app_colors.dart';

import 'package:app_domine/features/history/history_page.dart';
import 'package:app_domine/features/profile/profile_page.dart';
import 'package:app_domine/features/run/run_page.dart';

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
    setState(() => index = 3);
  }

  final pages = const [
  MapPage(),
  Placeholder(), // botão central depois
  HistoryPage(),
  ProfilePage(),
];

  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: pages[index],

    floatingActionButton: FloatingActionButton(
      backgroundColor: Colors.black,
      elevation: 6,
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const RunPage()),
        );
      },
      child: const Icon(
        Icons.directions_run,
        color: Colors.green,
        size: 28,
      ),
    ),

    floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

    bottomNavigationBar: BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      color: AppColors.green,
      child: SizedBox(
        height: 65,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [

            navItem(Icons.home, "Home", 0),

            const SizedBox(width: 40), // espaço do botão central

            navItem(Icons.history, "Histórico", 2),
            navItem(Icons.person, "Perfil", 3),
          ],
        ),
      ),
    ),
  );
}

  Widget navItem(IconData icon, String label, int i) {
  final selected = index == i;

  return InkWell(
    onTap: () => setState(() => index = i),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: selected ? Colors.white : Colors.black,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: selected ? Colors.white : Colors.black,
          ),
        ),
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
