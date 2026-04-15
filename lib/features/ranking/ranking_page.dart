import 'package:Domine/shared/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RankingPage extends StatefulWidget {
  const RankingPage({super.key});

  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  final supabase = Supabase.instance.client;

  List players = [];
  String? myUserId;

  String formatArea(dynamic value) {
    final area = (value ?? 0).toDouble();

    if (area < 1) {
      return "${(area * 1000).toStringAsFixed(0)} m²";
    } else {
      return "${area.toStringAsFixed(2)} km²";
    }
  }

  @override
  void initState() {
    super.initState();
    loadRanking();
  }

  Future<void> loadRanking() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    myUserId = user.id;

    final data = await supabase
        .from('profiles')
        .select()
        .order('total_area_km2', ascending: false);

    setState(() {
      players = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (players.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final others = players.length > 3 ? players.sublist(3) : [];

    return Scaffold(
      backgroundColor: const Color(0xFF2C2C2C),
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),

            const SizedBox(height: 25),

            // 🔥 TOP 3 (seguro)
            _buildTop3(),

            const SizedBox(height: 25),

            // 🔥 LISTA
            Expanded(
              child: ListView.builder(
                itemCount: others.length,
                itemBuilder: (context, index) {
                  final player = others[index];
                  final position = index + 4;

                  final isMe = player['id'] == myUserId;

                  return _rankingItem(player, position, isMe);
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  // 🔥 TOP 3 DINÂMICO (NÃO QUEBRA)
  Widget _buildTop3() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (players.length > 1)
          _topPlayer(players[1], "2º", 80),

        if (players.isNotEmpty)
          _topPlayer(players[0], "1º", 100),

        if (players.length > 2)
          _topPlayer(players[2], "3º", 80),
      ],
    );
  }

  // 🔥 TOP CARD
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
                backgroundImage: player['photo_url'] != null &&
                        player['photo_url'] != ''
                    ? NetworkImage(player['photo_url'])
                    : null,
                child: (player['photo_url'] == null ||
                        player['photo_url'] == '')
                    ? const Icon(Icons.person)
                    : null,
              ),
              const SizedBox(height: 8),
              Text(player['username'] ?? ''),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.flag, size: 14),
                  const SizedBox(width: 4),
                  Text(formatArea(player['total_area_km2'])),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  // 🔥 ITEM LISTA
  Widget _rankingItem(Map player, int position, bool isMe) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              "$positionº",
              style: const TextStyle(color: Colors.white),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isMe ? Colors.green : Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      player['username'] ?? '',
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.black,
                        fontWeight:
                            isMe ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.flag,
                          size: 14,
                          color: isMe ? Colors.white : Colors.black),
                      const SizedBox(width: 4),
                      Text(
                        formatArea(player['total_area_km2']),
                        style: TextStyle(
                          color: isMe ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    radius: 18,
                    backgroundImage: player['photo_url'] != null &&
                            player['photo_url'] != ''
                        ? NetworkImage(player['photo_url'])
                        : null,
                    child: (player['photo_url'] == null ||
                            player['photo_url'] == '')
                        ? const Icon(Icons.person)
                        : null,
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