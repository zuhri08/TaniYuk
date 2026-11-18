import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'awal/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => const TaniYukApp(),
    ),
  );
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
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF132E25),
          primary: const Color(0xFF132E25),
          secondary: const Color(0xFF2C5E4A),
        ),
        scaffoldBackgroundColor: const Color(0xFFFFF4E1),
        useMaterial3: true,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2C5E4A),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF2C5E4A),
          selectedItemColor: Colors.white,
          unselectedItemColor: Color(0xFF89D7B7),
        ),
        cardTheme: const CardThemeData(
          color: Colors.white,
          elevation: 2,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            side: BorderSide(color: Color(0xFF2C5E4A), width: 0.2),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2C5E4A), width: 0.3),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: const Color(0xFF2C5E4A).withValues(alpha: 0.25), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2C5E4A), width: 1.5),
          ),
        ),
      ),
      // Seluruh layar memakai palet terang, jadi tema gelap sistem tidak
      // dipakai agar kontras teks tetap terjaga.
      themeMode: ThemeMode.light,
      home: const SplashScreen(),
    );
  }
}
