import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:Domine/core/themes/app_colors.dart';
import 'package:Domine/features/run/run_repository.dart';
import 'package:Domine/features/map/run_map_view.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final repo = RunRepository();
  List<Map<String, dynamic>> runs = [];
  bool loading = true;

  List<LatLng> _buildPath(List path) {
    return path.map((p) => LatLng(p['lat'], p['lng'])).toList();
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await repo.getMyRuns();
    setState(() {
      runs = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C2C2C),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER VERDE
            Container(
              height: 70,
              color: AppColors.green,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Image.asset(
                "assets/logo/logo.png",
                height: 35,
              ),
            ),

            const SizedBox(height: 10),

            // LABEL
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.green,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Corridas",
                style: TextStyle(color: Colors.black),
              ),
            ),

            const SizedBox(height: 10),

            // LISTA
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : runs.isEmpty
                      ? const Center(
                          child: Text(
                            "Nenhuma corrida registrada",
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: runs.length,
                          itemBuilder: (_, i) => _card(runs[i]),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(Map<String, dynamic> run) {
    final started = DateTime.parse(run["started_at"]);
    final km = (run["distance_km"] as num).toDouble();
    final pace = (run["pace"] as num).toDouble();

    final path = run["path"] ?? [];
    final points = path.isNotEmpty ? _buildPath(path) : <LatLng>[];

    final center = points.isNotEmpty
        ? points[points.length ~/ 2]
        : const LatLng(-3.2, -52.2);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => RunMapView(run: run)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFD9D9D9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // TEXTO
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${started.day}/${started.month}/${started.year}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  _info(Icons.straighten, "${km.toStringAsFixed(1)} km"),
                  _info(Icons.directions_run,
                      "${pace.toStringAsFixed(1)} min/km"),
                  _info(Icons.timer,
                      "${run['duration_min'] ?? 0} min"),
                ],
              ),
            ),

            // MINI MAPA REAL
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 100,
                height: 100,
                child: points.isEmpty
                    ? Container(
                        color: Colors.grey,
                        child: const Icon(Icons.map, color: Colors.white),
                      )
                    : FlutterMap(
                        options: MapOptions(
                          initialCenter: center,
                          initialZoom: 15,
                          interactionOptions: const InteractionOptions(
                            flags: InteractiveFlag.none,
                          ),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                            userAgentPackageName: 'com.example.run_territory',
                          ),

                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: points,
                                strokeWidth: 4,
                                color: Colors.green,
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _info(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(text),
        ],
      ),
    );
  }
}