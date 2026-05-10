import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/auth_gate.dart';
import 'firebase_options.dart';
import 'core/utils/navigator_key.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'features/auth/data/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (kDebugMode) {
    // Disable app verification for testing (Phone Auth)
    await FirebaseAuth.instance.setSettings(appVerificationDisabledForTesting: true);
    print('Firebase Auth: App verification disabled for testing.');
  }

  // Initialize AuthService for Google Sign-In
  await AuthService().init();

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
    // Listen to auth state changes to clear navigation stack on login/logout
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      debugPrint('Auth State Changed: User is ${user?.uid ?? "null"}');
      if (user == null && navigatorKey.currentState != null) {
        // Clear all sub-pages and return to AuthGate
        debugPrint('Logging out: Clearing navigation stack.');
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
