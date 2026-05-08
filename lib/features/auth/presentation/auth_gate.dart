import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'home_navigation_wrapper.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // If the user is logged in, show the home navigation wrapper
        if (snapshot.hasData) {
          return const HomeNavigationWrapper(key: ValueKey('home_wrapper'));
        }

        // Otherwise, show the login screen
        return const LoginScreen(key: ValueKey('login_screen'));
      },
    );
  }
}

