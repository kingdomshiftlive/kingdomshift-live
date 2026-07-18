import 'package:flutter/material.dart';

class KSTheme {
  // Colors
  static const Color bgDark = Color(0xFF0A1628);
  static const Color bgCard = Color(0xFF112240);
  static const Color teal = Color(0xFF00C9C8);
  static const Color bgCardLight = Color(0xFF1A3A5C);
  
  static const Color gold = Color(0xFFC9A227);
  static const Color pink = Color(0xFFFF2D9B);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF8899AA);
  static const Color divider = Color(0xFF1E3A5A);

  // Gradients
  static const LinearGradient tealGradient = LinearGradient(
    colors: [Color(0xFF00C9C8), Color(0xFF0095A8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFC9A227), Color(0xFFE8C547)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient bgGradient = LinearGradient(
    colors: [Color(0xFF0A1628), Color(0xFF0D1F3C)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Text Styles
  static const TextStyle heading = TextStyle(
    color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.5,
  );
  static const TextStyle subheading = TextStyle(
    color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600,
  );
  static const TextStyle body = TextStyle(color: Colors.white, fontSize: 14);
  static const TextStyle caption = TextStyle(color: Color(0xFF8899AA), fontSize: 12);

  // Button style
  static ButtonStyle tealButton = ElevatedButton.styleFrom(
    backgroundColor: teal,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  );

  static ButtonStyle goldButton = ElevatedButton.styleFrom(
    backgroundColor: gold,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  );

  // Card decoration
  static BoxDecoration cardDecoration = BoxDecoration(
    color: bgCard,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: divider, width: 1),
  );

  // Theme data
  static ThemeData themeData = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: bgDark,
    colorScheme: const ColorScheme.dark(
      primary: teal,
      secondary: gold,
      surface: bgCard,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: bgDark,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
    ),
    tabBarTheme: const TabBarThemeData(
      indicatorColor: teal,
      labelColor: teal,
      unselectedLabelColor: Color(0xFF8899AA),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: bgCard,
      selectedItemColor: teal,
      unselectedItemColor: Color(0xFF8899AA),
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),
    iconTheme: const IconThemeData(color: Colors.white),
    dividerColor: divider,
  );
}
