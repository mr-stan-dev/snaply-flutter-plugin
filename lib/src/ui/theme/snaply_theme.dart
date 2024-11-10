import 'package:flutter/material.dart';
import 'package:snaply/src/ui/theme/snaply_colors.dart';

class SnaplyTheme {
  SnaplyTheme._();

  static get defaultTheme => ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: SnaplyColors.accent,
          onSurface: SnaplyColors.onSurface,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      );
}
