import 'package:flutter/material.dart';

/// App color palette inspired by maternal care and warmth
class AppColors {
  // Primary Colors - Soft pink/rose tones for maternal warmth
  static const Color primary = Color(0xFFFF6B9D); // Warm pink
  static const Color primaryLight = Color(0xFFFFB3D9);
  static const Color primaryDark = Color(0xFFE91E63);
  
  // Secondary Colors - Calming purple/lavender
  static const Color secondary = Color(0xFF9C27B0);
  static const Color secondaryLight = Color(0xFFE1BEE7);
  static const Color secondaryDark = Color(0xFF7B1FA2);
  
  // Accent Colors
  static const Color accent = Color(0xFFFF4081);
  static const Color accentLight = Color(0xFFFF80AB);
  
  // Background Colors
  static const Color background = Color(0xFFFFF5F7);
  static const Color cardBackground = Colors.white;
  static const Color surfaceLight = Color(0xFFFFF0F3);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF2D2D2D);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFFBDBDBD);
  static const Color textWhite = Colors.white;
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // Medication Status Colors
  static const Color taken = Color(0xFF66BB6A);
  static const Color missed = Color(0xFFEF5350);
  static const Color pending = Color(0xFFFFB74D);
  static const Color skipped = Color(0xFF9E9E9E);
  
  // Feature-specific Colors
  static const Color aiAssistant = Color(0xFF7C4DFF);
  static const Color consultation = Color(0xFF26C6DA);
  static const Color emergency = Color(0xFFE53935);
  static const Color reward = Color(0xFFFFD54F);
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF6B9D), Color(0xFFFF4081)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFF9C27B0), Color(0xFF7B1FA2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient softGradient = LinearGradient(
    colors: [Color(0xFFFFF5F7), Color(0xFFFFE4E9)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // Shadow Colors
  static const Color shadowLight = Color(0x1AFF6B9D);
  static const Color shadowMedium = Color(0x33FF6B9D);
  
  // Divider and Border Colors
  static const Color divider = Color(0xFFEEEEEE);
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderLight = Color(0xFFF5F5F5);
}
