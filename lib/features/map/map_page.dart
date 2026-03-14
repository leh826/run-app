import 'package:app_domine/core/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:app_domine/services/notification_service.dart';
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
        FlutterMap(
          options: MapOptions(
            initialCenter: userLocation!,
            initialZoom: 18,
          ),
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
                  child: const Icon(Icons.my_location,
                      color: Colors.green, size: 30),
                )
              ],
            ),
          ],
        ),

        // TOPO
        Container(
          height: 100,
          color: AppColors.green,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Image.asset(
            'assets/logo/logo.png',
            height: 40,
          ),
        ),


        // ALERTA
        if (showTerritoryAlert)
          Positioned(
            top: 60,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                  )
                ],
              ),
              child: Row(
                children: [

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Seu território foi invadido!!",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notificationData?['message'] ?? "Corra se quiser manter ele!",
                          style: const TextStyle(color: AppColors.green),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 10),

                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: AppColors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.warning,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(width: 8),

                  GestureDetector(
                    onTap: () {
                      setState(() {
                        showTerritoryAlert = false;
                      });
                    },
                    child: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
