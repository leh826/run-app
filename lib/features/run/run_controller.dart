import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'run_model.dart';
import 'dart:math';

class RunController {
  final _distance = Distance();
  RunSession? _session;
  StreamSubscription<Position>? _sub;
  Timer? _timer;

  RunSession? get session => _session;

  void start() {
    _session = RunSession(
      startTime: DateTime.now(),
      path: [],
    );

    // Atualiza o tempo a cada segundo
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_session != null) {
        _session!.endTime = DateTime.now();
      }
    });

    _sub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 5,
      ),
    ).listen(_onLocation);
  }

  void _onLocation(Position pos) {
    if (_session == null) return;

    final point = LatLng(pos.latitude, pos.longitude);

    if (_session!.path.isEmpty) {
      _session!.path.add(point);
      return;
    }

    final last = _session!.path.last;
    final d = _distance.as(LengthUnit.Meter, last, point);

    if (d > 3) {
      _session!.distanceKm += d / 1000;
      _session!.path.add(point);
    }
  }

  void stop() {
    _sub?.cancel();
    _timer?.cancel();
    _session?.endTime = DateTime.now();
  }

  List<LatLng> get closedPolygon {
    if (session == null || session!.path.length < 3) return [];
    final points = List<LatLng>.from(session!.path);
    points.add(points.first);
    return points;
  }

  double get conqueredAreaM2 {
    final poly = closedPolygon;
    if (poly.length < 4) return 0;

    const earthRadius = 6378137.0;
    double area = 0;

    for (int i = 0; i < poly.length - 1; i++) {
      final p1 = poly[i];
      final p2 = poly[i + 1];

      area += (p2.longitude - p1.longitude) *
          (2 +
              sin(p1.latitude * pi / 180) +
              sin(p2.latitude * pi / 180));
    }

    area = area * earthRadius * earthRadius / 2;
    return area.abs();
  }
}