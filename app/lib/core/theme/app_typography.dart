import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  static TextStyle timer({double fontSize = 96}) => GoogleFonts.ibmPlexMono(
        fontSize: fontSize,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        letterSpacing: -2,
      );

  static TextStyle display({double fontSize = 40}) => GoogleFonts.archivo(
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.1,
      );

  static TextStyle headline({double fontSize = 24}) => GoogleFonts.archivo(
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  static TextStyle body({double fontSize = 15, Color? color}) => GoogleFonts.archivo(
        fontSize: fontSize,
        fontWeight: FontWeight.w400,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle label({double fontSize = 11, Color? color}) => GoogleFonts.archivo(
        fontSize: fontSize,
        fontWeight: FontWeight.w500,
        color: color ?? AppColors.textMuted,
        letterSpacing: 1.4,
      );

  static TextStyle mono({double fontSize = 13, Color? color}) => GoogleFonts.ibmPlexMono(
        fontSize: fontSize,
        fontWeight: FontWeight.w400,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle button() => GoogleFonts.archivo(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.background,
        letterSpacing: 1.6,
      );
}
