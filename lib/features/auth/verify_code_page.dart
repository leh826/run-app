import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VerifyCodePage extends StatefulWidget {
  final String email;
  const VerifyCodePage({super.key, required this.email});

  @override
  State<VerifyCodePage> createState() => _VerifyCodePageState();
}

class _VerifyCodePageState extends State<VerifyCodePage> {
  final code = TextEditingController();

  Future<void> verify() async {
    try {
      await Supabase.instance.client.auth.verifyOTP(
        type: OtpType.email,
        email: widget.email,
        token: code.text,
      );

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, "/home");
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Código inválido")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Digite o código enviado por email",
              style: TextStyle(color: Colors.white, fontSize: 22),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: code,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: verify,
              child: const Text("Confirmar"),
            ),
          ],
        ),
      ),
    );
  }
}
