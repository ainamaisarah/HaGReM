import 'dart:async';
import 'package:flutter/material.dart';
import 'package:project/auth/auth_service.dart';
import 'package:project/home/admin_page.dart';
import 'package:project/home/homepage.dart';
import 'package:project/welcome.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:project/theme/app_colors.dart';
import 'package:project/theme/app_theme.dart';
import 'package:project/theme/theme_provider.dart';
import 'firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, themeMode, child) {
        return MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          home: const SplashScreen(),
        );
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Wait for 3 seconds to show splash screen
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    // Check if user is already logged in
    var user = authService.value.currentUser;

    if (user != null) {
      // User is logged in, check if admin
      var userDetails = await authService.value.getUserDetails(user.uid);

      if (userDetails != null && userDetails['username'] == 'admin') {
        // Navigate to Admin Page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminPage()),
        );
      } else {
        // Navigate to HomePage for regular users
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } else {
      // No user logged in, go to Welcome Screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color.fromARGB(255, 0, 6, 15), AppColors.splashGradientEnd],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 60),
              Center(
                // Logo
                child: Image.asset(
                  'assets/pics/logo_remove.png',
                  width: 300,
                  height: 300,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 40),

              // Title
              const Text(
                "HaGrem",
                style: TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 10),

              // Subtitle
              Text(
                "Hand Gesture Rehabilitation\nMobile Application",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),


              const Spacer(),

              // KICT Logo
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(8.0),
                child: Image.asset('assets/pics/kict_logo.png', width: 80),
              ),

              const SizedBox(height: 60),

              // Version
              const Text(
                "VERSION 1.0",
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}