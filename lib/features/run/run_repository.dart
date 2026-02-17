import 'package:supabase_flutter/supabase_flutter.dart';
import 'run_model.dart';

class RunRepository {
  final supabase = Supabase.instance.client;

  Future<void> saveRun(RunSession s, double area) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception("Usuário não autenticado");

    await supabase.from("runs").insert({
      "user_id": user.id,
      "started_at": s.startTime.toIso8601String(),
      "ended_at": s.endTime!.toIso8601String(),
      "duration_sec": s.duration.inSeconds,
      "distance_km": s.distanceKm,
      "pace": s.pace,
      "area_m2": area,
      "path": s.path
          .map((p) => {"lat": p.latitude, "lng": p.longitude})
          .toList(),
    });
  }

  Future<List<Map<String, dynamic>>> getMyRuns() async {
    final user = supabase.auth.currentUser;
    if (user == null) return [];

    final data = await supabase
        .from("runs")
        .select()
        .eq("user_id", user.id)
        .order("started_at", ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }
}
