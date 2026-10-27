import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  static TextStyle get fontBase => GoogleFonts.inter();
  static TextStyle get fontMono => GoogleFonts.robotoMono();

  // Screen Titles
  static TextStyle screenTitle = GoogleFonts.inter(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static TextStyle headline = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.25,
    letterSpacing: -0.3,
  );

  static TextStyle headlineMedium = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static TextStyle titleMedium = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Body text
  static TextStyle body = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.45,
  );

  static TextStyle bodySecondary = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.45,
  );

  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  // Section Headers (uppercase tracking)
  static TextStyle sectionHeader = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppColors.textMuted,
    letterSpacing: 1.2,
  );

  // Monospace Technical Metadata
  static TextStyle technicalTag = GoogleFonts.robotoMono(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 0.8,
  );

  static TextStyle technicalSub = GoogleFonts.robotoMono(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  // Category labels & chips
  static TextStyle chipLabel = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Button text
  static TextStyle buttonText = GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );

  // Disclaimer text
  static TextStyle disclaimer = GoogleFonts.robotoMono(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
    height: 1.5,
  );
}

