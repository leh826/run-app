import 'package:app_domine/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // MAPA (depois você troca por GoogleMap)
        Container(color: Colors.black87),

        // BARRA SUPERIOR VERDE
        Container(
          height: 100,
          color: AppColors.green,
        ),

        // ALERTA
        Positioned(
          top: 60,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Seu território foi invadido!!",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Corra se quiser manter ele!",
                        style: TextStyle(color: AppColors.green),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: AppColors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.warning, size: 18, color: Colors.white),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
