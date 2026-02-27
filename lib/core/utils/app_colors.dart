import 'package:flutter/material.dart';

class AppColors {
  // Primary Brand
  static const Color primary = Color(
    0xFF19b399,
  ); // Verde principal - Botones, CTAs
  static const Color primaryDark = Color(
    0xFF147A6E,
  ); // Verde oscuro - Hover, active
  static const Color secondary = Color(
    0xFF1f8a93,
  ); // Verde-azul - Logo, highlights

  // Neutrals & Backgrounds
  static const Color backgroundPrimary = Color(
    0xFF121F20,
  ); // Fondo principal dark
  static const Color surfacePrimary = Color(0xFF24272B); // Cards, panels
  static const Color neutral0 = Color(0xFFFFFFFF); // Blanco puro
  static const Color neutral900 = Color(0xFF0F172A); // Negro casi
  static const Color neutral600 = Color(0xFF475569); // Gris medio oscuro
  static const Color neutral500 = Color(0xFF64748B); // Gris medio
  static const Color neutral400 = Color(0xFF94A3B8); // Gris claro

  // Status & Book States
  static const Color reading = Color(0xFF32A8DB); // Azul "📖 Leyendo"
  //static const Color completed = Color(0xFF4CC767); // Verde "✅ Completado"
  static const Color completed = Color(0xFF4CC767);
  static const Color paused = Color(0xFFF28D2B); // Naranja "⏸ Pausado"
  static const Color pending = Color(0xFFFBBF24); // Amarillo "📚 Pendiente"

  // Ratings & Accents
  static const Color ratingGold = Color(0xFFEBE3B5); // Oro estrellas
  static const Color success = Color(0xFF22C55E); // Verde éxito
  static const Color warning = Color(0xFFf59e0b); // Amarillo advertencia
  static const Color error = Color(0xFFef4444); // Rojo error

  // Shadows
  static const Color shadowColor = Color(
    0x40000000,
  ); // Sombra negra 25% opacidad
}
