import 'dart:math';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'run_model.dart';

class RunRepository {
  final supabase = Supabase.instance.client;

  // tolerâncias
  static const double areaTolerance = 0.15; // 15%
  static const double distanceToleranceKm = 0.2; // 200 metros

  // ----------------- SALVAR CORRIDA -----------------
  Future<Map<String, dynamic>> saveRun(RunSession s, double area) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception("Usuário não autenticado");

    // SEMPRE no histórico
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

    // buscar territórios existentes
    final existing = await supabase
        .from("territories")
        .select("id, user_id, area_m2, path");

    // centro do trajeto atual
    final center = _calculateCenter(s.path);

    // comparar com territórios existentes
    for (final r in existing) {
      final double dbArea = (r["area_m2"] as num).toDouble();

      final dbPath = (r["path"] as List)
          .map((p) => LatLng(p["lat"], p["lng"]))
          .toList();

      final dbCenter = _calculateCenter(dbPath);

      final areaDiff = (area - dbArea).abs() / dbArea;

      final distance = _haversineKm(
        center.latitude,
        center.longitude,
        dbCenter.latitude,
        dbCenter.longitude,
      );

      if (areaDiff < areaTolerance &&
          distance < distanceToleranceKm) {

        // território já existe

        if (r["user_id"] != user.id) {
          //CAPTURA TERRITÓRIO
          await supabase
              .from("territories")
              .update({
                "user_id": user.id
              })
              .eq("id", r["id"]);

          return {
            "status": "CAPTURADO",
            "previousOwner": r["user_id"],
            "territoryId": r["id"],
          };

        } else {
          // território repetido
          return {
            "status": "REPETIDO",
            "territoryId": r["id"],
          };
        }
      }
    }

    // território novo
    final newTerritory = await supabase
        .from("territories")
        .insert({
          "user_id": user.id,
          "area_m2": area,
          "path": s.path
              .map((p) => {"lat": p.latitude, "lng": p.longitude})
              .toList(),
        })
        .select()
        .single();

    return {
      "status": "NOVO",
      "territoryId": newTerritory["id"],
    };
    
  }

  // ----------------- HISTÓRICO -----------------
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

  // ----------------- GEOMETRIA -----------------

  // centro do polígono
  LatLng _calculateCenter(List<LatLng> points) {
    double lat = 0, lng = 0;

    for (var p in points) {
      lat += p.latitude;
      lng += p.longitude;
    }

    return LatLng(lat / points.length, lng / points.length);
  }

  // distância real entre dois pontos
  double _haversineKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const R = 6371;

    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) *
            cos(_deg2rad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c;
  }

  double _deg2rad(double d) => d * pi / 180;
}