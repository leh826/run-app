import 'package:flutter/material.dart';

class CheckEmailPage extends StatelessWidget {
  const CheckEmailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.mark_email_read, color: Colors.green, size: 80),
                SizedBox(height: 24),
                Text(
                  "Confirme seu e-mail",
                  style: TextStyle(fontSize: 26, color: Colors.white),
                ),
                SizedBox(height: 12),
                Text(
                  "Enviamos um link para seu e-mail.\nAbra-o para ativar sua conta.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
