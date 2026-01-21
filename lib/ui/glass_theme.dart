import 'package:flutter/material.dart';

class GlassTheme {
  static const Color accentColor = Color(0xFFBB86FC);
  static const Color backgroundColor = Color(0xFF121212);
  
  static BoxDecoration glassDecoration({double blur = 20, double opacity = 0.1}) {
    return BoxDecoration(
      color: Colors.white.withOpacity(opacity),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: Colors.white.withOpacity(0.2),
        width: 1.5,
      ),
    );
  }

  static TextStyle get bodyStyle => const TextStyle(
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );

  static TextStyle get titleStyle => const TextStyle(
    color: Colors.white,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.2,
  );
}
