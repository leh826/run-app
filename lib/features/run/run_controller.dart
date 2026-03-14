import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'run_model.dart';
import 'dart:math';

class RunController {
  RunSession? _session;
  StreamSubscription<Position>? _sub;
  Timer? _timer;

  RunSession? get session => _session;

  void start() {
    _session = RunSession(
      startTime: DateTime.now(),
      path: [],
    );

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

    final d = _haversineKm(
      last.latitude,
      last.longitude,
      point.latitude,
      point.longitude,
    );

    if (d > 0.003) {
      _session!.distanceKm += d;
      _session!.path.add(point);
    }
  }

  void stop() {
    _sub?.cancel();
    _timer?.cancel();
    _session?.endTime = DateTime.now();
  }

  // ---------------- DETECTAR LINHA RETA ----------------

  bool get isStraightLine {
    if (session == null || session!.path.length < 3) return true;

    double totalDistance = 0;

    for (int i = 0; i < session!.path.length - 1; i++) {
      final p1 = session!.path[i];
      final p2 = session!.path[i + 1];

      totalDistance += _haversineKm(
        p1.latitude,
        p1.longitude,
        p2.latitude,
        p2.longitude,
      );
    }

    final start = session!.path.first;
    final end = session!.path.last;

    final directDistance = _haversineKm(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );

    if (directDistance == 0) return true;

    final ratio = totalDistance / directDistance;

    return ratio < 1.2;
  }

  // ---------------- ALPHA SHAPE (CONCAVE HULL SIMPLIFICADO) ----------------

  List<LatLng> get alphaShapePolygon {
    if (session == null || session!.path.length < 4) return [];

    if (isStraightLine) return [];

    final simplified = _simplifyPath(session!.path, 0.00002);
    final points = List<LatLng>.from(simplified);

    points.sort((a, b) => a.longitude.compareTo(b.longitude));

    final hull = <LatLng>[];

    for (final p in points) {
      while (hull.length >= 2 &&
          _cross(hull[hull.length - 2], hull[hull.length - 1], p) <= 0) {
        hull.removeLast();
      }
      hull.add(p);
    }

    final lowerSize = hull.length;

    for (int i = points.length - 2; i >= 0; i--) {
      final p = points[i];

      while (hull.length > lowerSize &&
          _cross(hull[hull.length - 2], hull[hull.length - 1], p) <= 0) {
        hull.removeLast();
      }

      hull.add(p);
    }

    hull.add(hull.first);

    return hull;
  }

  double _cross(LatLng o, LatLng a, LatLng b) {
    return (a.longitude - o.longitude) * (b.latitude - o.latitude) -
        (a.latitude - o.latitude) * (b.longitude - o.longitude);
  }

  // ---------------- AREA DO TERRITÓRIO ----------------

  double get conqueredAreaM2 {
    final poly = alphaShapePolygon;

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
// ---------------- SIMPLIFICAÇÃO DO TRAJETO (DOUGLAS-PEUCKER) ----------------

List<LatLng> _simplifyPath(List<LatLng> points, double tolerance) {
  if (points.length < 3) return points;

  int index = -1;
  double maxDist = 0;

  for (int i = 1; i < points.length - 1; i++) {
    final dist = _perpendicularDistance(points[i], points.first, points.last);

    if (dist > maxDist) {
      index = i;
      maxDist = dist;
    }
  }

  if (maxDist > tolerance) {
    final left = _simplifyPath(points.sublist(0, index + 1), tolerance);
    final right = _simplifyPath(points.sublist(index), tolerance);

    return [...left.sublist(0, left.length - 1), ...right];
  }

  return [points.first, points.last];
}

double _perpendicularDistance(
  LatLng p,
  LatLng lineStart,
  LatLng lineEnd,
) {
  final x0 = p.longitude;
  final y0 = p.latitude;

  final x1 = lineStart.longitude;
  final y1 = lineStart.latitude;

  final x2 = lineEnd.longitude;
  final y2 = lineEnd.latitude;

  final num =
      ((y2 - y1) * x0 - (x2 - x1) * y0 + x2 * y1 - y2 * x1).abs();

  final den = sqrt(pow(y2 - y1, 2) + pow(x2 - x1, 2));

  return num / den;
}
  // ---------------- HAVERSINE ----------------

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