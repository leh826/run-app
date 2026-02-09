import 'package:latlong2/latlong.dart';

class RunSession {
  final DateTime startTime;
  DateTime? endTime;
  final List<LatLng> path;
  double distanceKm;

  RunSession({
    required this.startTime,
    required this.path,
    this.endTime,
    this.distanceKm = 0,
  });

  Duration get duration =>
      (endTime ?? DateTime.now()).difference(startTime);

  double get pace =>
      distanceKm == 0 ? 0 : duration.inMinutes / distanceKm;
}