import 'package:Domine/shared/widgets/header.dart';
import 'package:flutter/material.dart';

class RankingPage extends StatelessWidget {
  const RankingPage({super.key});

  // 🔥 MOCK (depois você troca pelo Supabase)
  List<Map<String, dynamic>> get players => [
        {
          "name": "Marcia Ribeiro",
          "score": 500,
          "photo": "https://i.pravatar.cc/150?img=1"
        },
        {
          "name": "Ruth Gomes",
          "score": 300,
          "photo": "https://i.pravatar.cc/150?img=2"
        },
        {
          "name": "Caio Sampaio",
          "score": 200,
          "photo": "https://i.pravatar.cc/150?img=3"
        },
        {
          "name": "Alberto Roberto",
          "score": 180,
          "photo": "https://i.pravatar.cc/150?img=4"
        },
        {
          "name": "Lidia Martins",
          "score": 150,
          "photo": "https://i.pravatar.cc/150?img=5"
        },
        {
          "name": "Rafael Cardoso",
          "score": 120,
          "photo": "https://i.pravatar.cc/150?img=6"
        },
        {
          "name": "Joana Farias",
          "score": 115,
          "photo": "https://i.pravatar.cc/150?img=7"
        },
        {
          "name": "Thiago Gouvêa",
          "score": 100,
          "photo": "https://i.pravatar.cc/150?img=8"
        },
      ];

  @override
  Widget build(BuildContext context) {
    final top3 = players.take(3).toList();
    final others = players.skip(3).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF2C2C2C),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            const AppHeader(),

            const SizedBox(height: 25),

            //
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _topPlayer(top3[1], "2º", 80),
                _topPlayer(top3[0], "1º", 100),
                _topPlayer(top3[2], "3º", 80),
              ],
            ),

            const SizedBox(height: 25),

            //LISTA
            Expanded(
              child: ListView.builder(
                itemCount: others.length,
                itemBuilder: (context, index) {
                  final player = others[index];
                  final position = index + 4;

                  return _rankingItem(player, position);
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  // TOP 3 CARD
  Widget _topPlayer(Map player, String position, double size) {
    return Column(
      children: [
        Text(
          position,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),

        const SizedBox(height: 8),

        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: size / 2.5,
                backgroundImage: NetworkImage(player['photo']),
              ),
              const SizedBox(height: 8),
              Text(player['name']),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.flag, size: 14),
                  const SizedBox(width: 4),
                  Text("${player['score']} m²"),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  // LIST ITEM
  Widget _rankingItem(Map player, int position) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              "${position}º",
              style: const TextStyle(color: Colors.white),
            ),
          ),

          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(player['name']),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.flag, size: 14),
                      const SizedBox(width: 4),
                      Text("${player['score']} m²"),
                    ],
                  ),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    radius: 18,
                    backgroundImage: NetworkImage(player['photo']),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}