import 'package:flutter/material.dart';
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
      appBar: AppBar(title: const Text("Histórico")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : runs.isEmpty
          ? const Center(child: Text("Nenhuma corrida registrada"))
          : ListView.builder(
              itemCount: runs.length,
              itemBuilder: (_, i) => _tile(runs[i]),
            ),
    );
  }

  Widget _tile(Map<String, dynamic> run) {
    final started = DateTime.parse(run["started_at"]);
    final km = (run["distance_km"] as num).toDouble();
    final pace = (run["pace"] as num).toDouble();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        title: Text("${km.toStringAsFixed(2)} km"),
        subtitle: Text(
          "${started.day}/${started.month} às ${started.hour}:${started.minute.toString().padLeft(2, '0')} • Pace ${pace.toStringAsFixed(1)}",
        ),
        trailing: const Icon(Icons.map),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => RunMapView(run: run)),
          );
        },
      ),
    );
  }
}
