import 'package:flutter/material.dart';
import 'package:Domine/features/run/run_controller.dart';

class RunControls extends StatelessWidget {
  final RunController controller;
  final VoidCallback onFinish;
  final VoidCallback onCancel;
  final VoidCallback onUpdate;

  const RunControls({
    super.key,
    required this.controller,
    required this.onFinish,
    required this.onCancel,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // ⏸️ PAUSE / RESUME
        ElevatedButton(
          onPressed: () {
            if (controller.isPaused) {
              controller.resume();
            } else {
              controller.pause();
            }
            onUpdate();
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          child: Text(controller.isPaused ? "Retomar" : "Pausar"),
        ),

        // ❌ CANCELAR
        ElevatedButton(
          onPressed: onCancel,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text("Cancelar"),
        ),

        // 🏁 FINALIZAR
        ElevatedButton(
          onPressed: onFinish,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: const Text("Finalizar"),
        ),
      ],
    );
  }
}