import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:app_domine/features/run/run_controller.dart';
import 'package:app_domine/features/run/run_repository.dart';

class RunPage extends StatefulWidget {
  const RunPage({super.key});

  @override
  State<RunPage> createState() => _RunPageState();
}

class _RunPageState extends State<RunPage> {
  final controller = RunController();
  final mapController = MapController();
  final repo = RunRepository();


  Timer? uiTimer;
  bool mapReady = false;

  @override
  void initState() {
    super.initState();
    controller.start();

    uiTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    uiTimer?.cancel();
    controller.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = controller.session;

    if (session == null || session.path.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (mapReady) {
      mapController.move(
        session.path.last,
        mapController.camera.zoom == 0 ? 18 : mapController.camera.zoom,
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: session.path.first,
              initialZoom: 18,
              onMapReady: () {
                setState(() => mapReady = true);
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png",
                subdomains: const ['a', 'b', 'c', 'd'],
              ),
              if (session.path.length > 2)
                PolygonLayer(
                  polygons: [
                    Polygon(
                      points: session.path,
                      color: Colors.green.withValues(alpha: 0.4),
                      borderColor: Colors.green,
                      borderStrokeWidth: 2,
                    )
                  ],
                ),
            ],
          ),

          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    info("Tempo", _format(session.duration)),
                    info("Km", session.distanceKm.toStringAsFixed(2)),
                    info("Pace", session.pace.toStringAsFixed(1)),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 30,
            left: 40,
            right: 40,
            child: ElevatedButton(
              onPressed: _confirmFinish,
              child: const Text("Finalizar corrida"),
            ),
          ),
        ],
      ),
    );
  }

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  Widget info(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label),
      ],
    );
  }

  void _confirmFinish() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Finalizar corrida"),
        content: const Text(
          "Deseja finalizar a corrida e verificar o território conquistado?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () async {
              controller.stop();

              final session = controller.session;
              if (session != null) {
                await repo.saveRun(
                  session,
                  controller.conqueredAreaM2,
                );
              }

              if (!mounted) return;

              Navigator.pop(context); // fecha dialog
              Navigator.pop(context); // volta pra home
            },
            child: const Text("Finalizar"),
          ),
        ],
      ),
    );
  }
}
