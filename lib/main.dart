import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/auth_gate.dart';
import 'firebase_options.dart';
import 'core/utils/navigator_key.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const PecheTechApp());
}

class PecheTechApp extends StatefulWidget {
  const PecheTechApp({super.key});

  @override
  State<PecheTechApp> createState() => _PecheTechAppState();
}

class _PecheTechAppState extends State<PecheTechApp> {
  @override
  void initState() {
    super.initState();
    // Listen to auth state changes to clear navigation stack on logout
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        // If logged out, pop all screens back to the root (AuthGate)
        navigatorKey.currentState?.popUntil((route) => route.isFirst);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PecheTech',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthGate(),
    );
  }
}
