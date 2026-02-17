import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class RunMapView extends StatelessWidget {
  final Map<String, dynamic> run;

  const RunMapView({super.key, required this.run});

  @override
  Widget build(BuildContext context) {
    final path = (run["path"] as List)
        .map((p) => LatLng(p["lat"], p["lng"]))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Trajeto")),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: path.first,
          initialZoom: 17,
        ),
        children: [
          TileLayer(
            urlTemplate:
                "https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png",
            subdomains: const ['a', 'b', 'c', 'd'],
          ),
          PolygonLayer(
            polygons: [
              Polygon(
                points: path,
                color: Colors.green.withValues(alpha: 0.4),
                borderColor: Colors.green,
                borderStrokeWidth: 2,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
