import 'package:flutter/material.dart';
import 'awal/splash_screen.dart';

void main() {
  runApp(const TaniYukApp());
}

// Alias for backwards compatibility with tests
typedef MyApp = TaniYukApp;

class TaniYukApp extends StatelessWidget {
  const TaniYukApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaniYuk',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F623F),
          primary: const Color(0xFF0F623F),
          secondary: const Color(0xFF15803D),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const SplashScreen(),
    );
  }
}
