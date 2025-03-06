import 'package:flutter/material.dart';
import 'package:snaply/src/ui/theme/snaply_colors.dart';

class SnaplyTheme {
  SnaplyTheme._();

  static ThemeData get defaultTheme => ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: SnaplyColors.accent,
          onSurface: SnaplyColors.onSurface,
        ),
        useMaterial3: true,
      );
}
