
import 'package:flutter/material.dart';

class AppTokens {
  // Brand roles
  static const Color primary = Color(0xFF0B2A4A); // Nile Blue
  static const Color accent = Color(0xFF1BAA7A); // Emerald
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color danger = Color(0xFFDC2626); // Controlled Red
  static const Color neutral = Color(0xFFE6D3B1); // Sand

  // Light surfaces/text
  static const Color bg = Color(0xFFF6F5F2); // warm off-white
  static const Color surface = Color(0xFFFFFFFF);
  static const Color text = Color(0xFF0F172A);
  static const Color text2 = Color(0xFF475569);
  static const Color border = Color(0xFFE5E7EB);

  // Dark surfaces/text
  static const Color bgDark = Color(0xFF0B1220); // near-black navy
  static const Color surfaceDark = Color(0xFF111A2B); // deep slate
  static const Color textDark = Color(0xFFE5E7EB);
  static const Color text2Dark = Color(0xFF9AA6B2);
  static const Color borderDark = Color(0xFF22304A);

  // Tinted surfaces
  static const Color dangerTintLight = Color(0xFFFFF1F2);
  static const Color dangerTintDark = Color(0xFF2A1320);

  // Radii
  static const double rCard = 16;
  static const double rInput = 12;
  static const double rPill = 999;

  // Spacing
  static const double s8 = 8;
  static const double s12 = 12;
  static const double s16 = 16;
  static const double s20 = 20;
  static const double s24 = 24;

  // Shadows (subtle)
  static List<BoxShadow> shadowSoft(Color base) => [
        BoxShadow(
          color: base.withOpacity(0.08),
          blurRadius: 14,
          offset: const Offset(0, 8),
        ),
      ];
}
