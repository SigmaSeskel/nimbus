import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nimbus/screens/home_screen.dart';
import 'package:nimbus/screens/auth/login_screen.dart';
import 'package:nimbus/screens/auth/onboarding_screen.dart';

void main() async {
  // Must add this before Firebase initialization
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  runApp(const NimbusApp());
}

class NimbusApp extends StatelessWidget {
  const NimbusApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nimbus - E-Book Store',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF64B5F6),
        scaffoldBackgroundColor: const Color(0xFFF5F8FA),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF64B5F6),
          brightness: Brightness.light,
          primary: const Color(0xFF64B5F6),
          secondary: const Color(0xFF81C784),
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF2C3E50),
          iconTheme: IconThemeData(color: Color(0xFF2C3E50)),
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const AuthWrapper(), // Check if user is logged in
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}

// Auth Wrapper to check if user is logged in
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF64B5F6),
              ),
            ),
          );
        }

        // If user is logged in, go to home
        if (snapshot.hasData) {
          return const HomeScreen();
        }

        // Otherwise, show onboarding
        return const OnboardingScreen();
      },
    );
  }
}