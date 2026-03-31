import 'dart:developer';
import 'dart:io';

import 'package:Domine/shared/widgets/header.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:image_picker/image_picker.dart';

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

    try {
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
    } catch (e) {
      log("Erro ao carregar perfil: $e");
      setState(() => loading = false);
    }
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

  // Lógica extraída para ser chamada por dentro do dialog
  Future<void> updateProfileData(File? imageFile, String newUsername) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    String? avatarUrl;

    if (imageFile != null) {
      try {
        final fileName = "${user.id}.jpg";
        await supabase.storage.from('avatars').upload(
              fileName,
              imageFile,
              fileOptions: const FileOptions(upsert: true),
            );

        // Adicionamos um timestamp no final da URL para forçar o Flutter a 
        // recarregar a imagem e não usar a versão antiga do cache.
        final publicUrl = supabase.storage.from('avatars').getPublicUrl(fileName);
        avatarUrl = "$publicUrl?t=${DateTime.now().millisecondsSinceEpoch}";
      } catch (e) {
        log("Erro ao enviar imagem: $e");
      }
    }

    final updateData = {'username': newUsername};
    if (avatarUrl != null) {
      updateData['photo_url'] = avatarUrl;
    }

    await supabase.from('profiles').update(updateData).eq('id', user.id);
    await loadProfile();
  }

  void openEditDialog() {
    final TextEditingController dialogUsernameController =
        TextEditingController(text: username);
    File? dialogImageFile;
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false, // Impede que feche clicando fora enquanto salva
      builder: (context) {
        // StatefulBuilder permite atualizar a interface APENAS dentro do dialog
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Editar Perfil"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: dialogUsernameController,
                    decoration: const InputDecoration(labelText: "Username"),
                    enabled: !isSaving, // Desabilita edição enquanto salva
                  ),
                  const SizedBox(height: 15),
                  
                  // Mostra um preview da foto escolhida
                  if (dialogImageFile != null) ...[
                    ClipOval(
                      child: Image.file(
                        dialogImageFile!,
                        height: 80,
                        width: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],

                  ElevatedButton.icon(
                    onPressed: isSaving
                        ? null
                        : () async {
                            final picker = ImagePicker();
                            final picked = await picker.pickImage(
                                source: ImageSource.gallery);

                            if (picked != null) {
                              setDialogState(() {
                                dialogImageFile = File(picked.path);
                              });
                            }
                          },
                    icon: const Icon(Icons.photo_camera),
                    label: const Text("Escolher Foto"),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(context),
                  child: const Text("Cancelar"),
                ),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          // Inicia o modo de carregamento no dialog
                          setDialogState(() => isSaving = true);

                          await updateProfileData(
                            dialogImageFile,
                            dialogUsernameController.text,
                          );

                          if (!context.mounted) return;
                          Navigator.pop(context); // Fecha o dialog com segurança
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text("Salvar"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF2C2C2C),
        body: Center(child: CircularProgressIndicator(color: Colors.green)),
      );
    }

    final LatLng center = territoryPolygons.isNotEmpty
        ? territoryPolygons.first.first
        : const LatLng(-3.2, -52.2);

    return Scaffold(
      backgroundColor: const Color(0xFF2C2C2C),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const AppHeader(),
              const SizedBox(height: 25),

              // FOTO
              Stack(
                children: [
                  CircleAvatar(
                    radius: 65,
                    backgroundColor: Colors.green,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[800],
                      backgroundImage: photoUrl.isNotEmpty
                          ? NetworkImage(photoUrl)
                          : null,
                      child: photoUrl.isEmpty
                          ? const Icon(Icons.person, size: 50, color: Colors.white)
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: openEditDialog,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit, size: 18, color: Colors.green),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 15),

              // NOME
              Text(
                username,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),

              GestureDetector(
                onTap: openEditDialog,
                child: const Text(
                  "Editar perfil",
                  style: TextStyle(color: Colors.green, fontSize: 14),
                ),
              ),
              const SizedBox(height: 25),

              // CARDS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _statCard("${totalKm.toStringAsFixed(0)} Km", "Distância", Icons.route),
                    _statCard("$territories", "Territórios", Icons.map),
                  ],
                ),
              ),
              const SizedBox(height: 25),

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
                        initialZoom: 15,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.none,
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: "https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png",
                          subdomains: const ['a', 'b', 'c'],
                          userAgentPackageName: 'com.Domine.run',
                        ),
                        PolygonLayer(
                          polygons: territoryPolygons
                              .map(
                                (poly) => Polygon(
                                  points: poly,
                                  color: Colors.green.withAlpha((255 * 0.4).round()),
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

  Widget _statCard(String value, String label, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.green),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.green, size: 28),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}