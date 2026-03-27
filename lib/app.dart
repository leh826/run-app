import 'package:Domine/features/auth/auth_gate.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: ThemeData(fontFamily: "Poppins"),

      home: const AuthGate(),
    );
  }
}
