import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart'; // 🔹 Added
import 'firebase_options.dart';

// Screens
import 'package:nimbus/screens/splash_screen.dart';
import 'package:nimbus/screens/home_screen.dart';
import 'package:nimbus/screens/auth/login_screen.dart';
import 'package:nimbus/screens/auth/onboarding_screen.dart';

// 🔹 Added: Theme + Notifications
import 'package:nimbus/theme/theme_notifier.dart';
import 'package:nimbus/notifications/push.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Enable Firestore offline persistence
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  // 🔹 Initialize push notifications (before runApp)
  await initPush();

  // 🔹 Wrap with Provider for Theme switching
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: const NimbusApp(),
    ),
  );
}

class NimbusApp extends StatelessWidget {
  const NimbusApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 🔹 Watch the current theme
    final themeNotifier = context.watch<ThemeNotifier>();

    return MaterialApp(
      title: 'Nimbus - E-Book Store',
      debugShowCheckedModeBanner: false,

      // 🔹 Apply theme mode
      themeMode: themeNotifier.mode,

      // 🔹 Light theme
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
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFE3F2FD),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFF64B5F6),
              width: 2,
            ),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF64B5F6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),

      // 🔹 Dark theme
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF64B5F6),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),

      home: const SplashScreen(),
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/authWrapper': (context) => const AuthWrapper(),
      },
    );
  }
}

/// Auth Wrapper to check login state after splash
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
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

        if (snapshot.hasData) {
          return const HomeScreen();
        }
        return const OnboardingScreen();
      },
    );
  }
}
