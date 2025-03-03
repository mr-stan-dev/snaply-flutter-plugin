import 'dart:io';

import 'package:flutter/material.dart';

class FullViewScreenshot extends StatelessWidget {
  const FullViewScreenshot({
    required this.file,
    super.key,
  });

  final File file;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.file(
        file,
        fit: BoxFit.contain,
      ),
    );
  }
}
