import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Paleta Industrial Comercializadora Aly
  static const Color primaryDark = Color(0xFF000919); // Azul Medianoche Profundo
  static const Color accentOrange = Color(0xFFFD761A); // Naranja Vibrante
  static const Color surfaceDark = Color(0xFF0A192F); // Superficie Dark
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGray = Color(0xFF94A3B8);
  
  // Gradiantes Industriales
  static const LinearGradient industrialGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)], // Índigo a Violeta
  );

  static ThemeData get industrialTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: primaryDark,
      colorScheme: const ColorScheme.dark(
        primary: accentOrange,
        secondary: Color(0xFF7C3AED),
        surface: surfaceDark,
        onSurface: textWhite,
        background: primaryDark,
      ),
      textTheme: GoogleFonts.interTextTheme().apply(
        bodyColor: textWhite,
        displayColor: textWhite,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: accentOrange, width: 2),
        ),
        labelStyle: const TextStyle(color: textGray),
        prefixIconColor: textGray,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentOrange,
          foregroundColor: Colors.white,
          minimumSize: const Size(64, 44), // Tamaño BASE seguro (no infinito)
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),
    );
  }
}
