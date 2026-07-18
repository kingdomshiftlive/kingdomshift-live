import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/auth/login_screen.dart';
import 'screens/shell/main_shell.dart';
import 'services/push_notification_service.dart';
import 'theme/ks_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Supabase.initialize(
    url: 'https://cotcogrkmtgibbpwhxrg.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNvdGNvZ3JrbXRnaWJicHdoeHJnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAwMjA4MzEsImV4cCI6MjA5NTU5NjgzMX0.MtO1vEYaUoUX1Yj4JdDjF8E5kkAhcuPYC4nnJ0m9Ql0',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KingdomShift.Live',
      debugShowCheckedModeBanner: false,
      theme: KSTheme.themeData,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<firebase_auth.User?>(
      stream: firebase_auth.FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: Color(0xFF00C9C8))),
          );
        }
        if (snapshot.hasData) {
          PushNotificationService.initialize();
          return const MainShell();
        }
        return const LoginScreen();
      },
    );
  }
}
