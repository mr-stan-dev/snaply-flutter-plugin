import 'dart:typed_data';

import 'package:flutter/material.dart';

class FullViewScreenshot extends StatelessWidget {
  const FullViewScreenshot({
    required this.bytes,
    super.key,
  });

  final Uint8List bytes;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.grey,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(bytes),
          ),
        ),
      ],
    );
  }
}
