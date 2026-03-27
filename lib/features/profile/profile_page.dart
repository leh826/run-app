import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/auth_gate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final supabase = Supabase.instance.client;

  String username = "Usuário";
  String photoUrl = "";
  double totalKm = 0;
  int territories = 0;

  final TextEditingController usernameController = TextEditingController();
  File? imageFile;

  List<List<LatLng>> territoryPolygons = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final profile = await supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();

    final territoryCount = await supabase
        .from('territories')
        .select()
        .eq('user_id', user.id);

    await loadTerritories();

    setState(() {
      username = profile['username'] ?? "Usuário";
      photoUrl = profile['photo_url'] ?? "";
      totalKm = (profile['total_km'] ?? 0).toDouble();
      territories = territoryCount.length;
      loading = false;
    });
  }

  Future<void> loadTerritories() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final data = await supabase
        .from('territories')
        .select('path')
        .eq('user_id', user.id);

    final List<List<LatLng>> temp = [];

    for (var t in data) {
      final List path = t['path'];

      temp.add(path.map((p) => LatLng(p['lat'], p['lng'])).toList());
    }

    setState(() {
      territoryPolygons = temp;
    });
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();

    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        imageFile = File(picked.path);
      });
    }
  }

  Future<String?> uploadAvatar(String userId) async {
    if (imageFile == null) return null;

    final fileName = "$userId.jpg";

    await supabase.storage
        .from('avatars')
        .upload(
          fileName,
          imageFile!,
          fileOptions: const FileOptions(upsert: true),
        );

    final publicUrl = supabase.storage.from('avatars').getPublicUrl(fileName);

    return publicUrl;
  }

  Future<void> updateProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    String? avatarUrl;

    if (imageFile != null) {
      avatarUrl = await uploadAvatar(user.id);
    }

    final updateData = {'username': usernameController.text};

    if (avatarUrl != null) {
      updateData['photo_url'] = avatarUrl;
    }

    await supabase.from('profiles').update(updateData).eq('id', user.id);

    imageFile = null; // limpa preview

    await loadProfile(); // recarrega dados reais do banco

    setState(() {});
  }

  void openEditDialog() {
    usernameController.text = username;

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Editar Perfil"),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: "Username"),
              ),

              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: pickImage,
                child: const Text("Escolher Foto"),
              ),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancelar"),
            ),

            ElevatedButton(
              onPressed: () async {
                await updateProfile();

                if (!mounted) return;

                Navigator.pop(context);
              },
              child: const Text("Salvar"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final LatLng center = territoryPolygons.isNotEmpty
        ? territoryPolygons.first.first
        : const LatLng(-3.2, -52.2); // centro aproximado do Pará

    return Scaffold(
      backgroundColor: const Color(0xFF2C2C2C),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // HEADER
              Container(
                height: 80,
                color: const Color(0xFF3EB400),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(),

                    IconButton(
                      onPressed: () async {
                        await supabase.auth.signOut();

                        if (!context.mounted) return;

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const AuthGate()),
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.logout, color: Colors.white),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // FOTO
              GestureDetector(
                onTap: pickImage,
                child: CircleAvatar(
                  radius: 70,
                  backgroundImage: imageFile != null
                      ? FileImage(imageFile!)
                      : (photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null)
                            as ImageProvider?,
                  child: photoUrl.isEmpty && imageFile == null
                      ? const Icon(Icons.person, size: 50)
                      : null,
                ),
              ),

              const SizedBox(height: 15),

              // NOME
              Text(
                username,
                style: const TextStyle(color: Colors.white, fontSize: 22),
              ),

              const SizedBox(height: 8),

              GestureDetector(
                onTap: openEditDialog,
                child: const Text(
                  "Editar",
                  style: TextStyle(color: Colors.white54),
                ),
              ),

              const SizedBox(height: 30),

              // CARDS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _statCard(
                      "${totalKm.toStringAsFixed(0)} Km",
                      "Distância\npercorrida",
                    ),

                    _statCard(
                      territories.toString(),
                      "Territórios\nConquistados",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // MINI MAPA
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  height: 180,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: center,
                        initialZoom: 13,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.none,
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              "https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png",
                          subdomains: const ['a', 'b', 'c'],
                          userAgentPackageName: 'com.Domine.run',
                        ),

                        PolygonLayer(
                          polygons: territoryPolygons
                              .map(
                                (poly) => Polygon(
                                  points: poly,
                                  color: Colors.green.withAlpha(
                                    (255 * 0.4).round(),
                                  ),
                                  borderColor: Colors.green,
                                  borderStrokeWidth: 2,
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(String value, String label) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF3EB400),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
