import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/auth/auth_service.dart';
import 'core/routes/home_shell.dart';
import 'features/auth/login_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder(
        stream: auth.onAuthChange,
        builder: (context, snapshot) {
          final session =
              Supabase.instance.client.auth.currentSession;

          if (session != null) {
            return const HomeShell();
          }

          return const LoginPage();
        },
      ),
    );
  }
}
