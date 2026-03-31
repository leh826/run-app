import 'package:Domine/core/themes/app_colors.dart';
import 'package:Domine/shared/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:Domine/services/notification_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  LatLng? userLocation;

  bool showTerritoryAlert = false;
  Map? notificationData;
  @override
  void initState() {
    super.initState();
    _getLocation();

    final user = Supabase.instance.client.auth.currentUser;

    if (user != null) {
      NotificationService().listenNotifications(user.id, (notification) {
        setState(() {
          notificationData = notification;
          showTerritoryAlert = true;
        });
      });
    }
  }

  Future<void> _getLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    final pos = await Geolocator.getCurrentPosition();
    setState(() {
      userLocation = LatLng(pos.latitude, pos.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (userLocation == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        // MAPA
        SafeArea(
          bottom: false,
          child: FlutterMap(
            options: MapOptions(initialCenter: userLocation!, initialZoom: 18),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: 'com.example.run_territory',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: userLocation!,
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.my_location,
                      color: Colors.green,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // TOPO
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: AppHeader(),
        ),

        // ALERTA
        Positioned(
          top: 80,
          left: 20,
          right: 20,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: showTerritoryAlert ? 1 : 0,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 10),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.orange),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Território invadido!",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          notificationData?['message'] ?? "",
                          style: const TextStyle(
                            color: AppColors.green,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  GestureDetector(
                    onTap: () {
                      setState(() => showTerritoryAlert = false);
                    },
                    child: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
          ),
        ),

        Positioned(
          bottom: 100,
          right: 20,
          child: FloatingActionButton(
            mini: true,
            backgroundColor: Colors.white,
            onPressed: _getLocation,
            child: const Icon(Icons.my_location, color: Colors.black),
          ),
        ),
      ],
    );
  }
}
