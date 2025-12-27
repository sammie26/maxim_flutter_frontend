import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF212121),
      secondary: Color(0xFF333333),
      // background: Color(0xFFF7F7F7),
      surface: Colors.white,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.w900,
        fontSize: 32,
      ),
      headlineLarge: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 24,
      ),
      bodyLarge: TextStyle(color: Colors.black, fontSize: 16),
      bodyMedium: TextStyle(color: Colors.grey, fontSize: 14),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      hintStyle: TextStyle(color: Colors.grey.shade400),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 16.0,
        horizontal: 16.0,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(color: Color(0xFF333333), width: 2),
      ),
    ),
    useMaterial3: true,
    appBarTheme: AppBarThemeData().copyWith(
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    scaffoldBackgroundColor: Colors.black, // or your specific dark/light color
    canvasColor: Colors.black, // Fallback for other widgets
  );
}

class AppColors {
  static Color kRed = Color(0xfff94144);
  static Color kGreen = Color(0xff90be6d);

  // Other
  static Color kAtomic = Color(0xfff3722c);
  static Color kSeagrass = Color(0xff43aa8b);
  static Color kCarrot = Color(0xfff8961e);
  static Color kCoral = Color(0xfff9844a);
  static Color kTuscan = Color(0xfff9c74f);
  static Color kDark = Color(0xff4d908e);
  static Color kBlue = Color(0xff577590);
  static Color kCerulean = Color(0xff277da1);

  static const Color kDarkBackground = Color(0xFF222222);
  static const Color kDeepestDark = Color(0xFF111111);
  static const Color kLightBackground = Color(0xFFF0F0F0);
  static const Color kAccentWhite = Colors.white;
  static const Color kAccentGrey = Colors.white70;
  static const Color kDullTextColor = Colors.black54;
  static const Color kAccentBlue = Color(0xFF007AFF);
  static const Color kErrorRed = Color(0xFFE57373);

  static const Color kBronze = Color(0xFF8C5A2B);
  static const Color kSilver = Color(0xFFB0B0B0);
  static const Color kGold = Color(0xFFD4AF37);
  static const Color kPlatinum = Color(0xFFE5E4E2);
  static const Color kAscendant = Color(0xFF1A1A1A);
  static const Color kSuccessGreen = Color(0xFF4CAF50);
  static const Color kHostAccentColor = Color(0xFF555555);
  static const Color kProgressColor = kDarkBackground;
}
