import 'dart:io';

import 'package:flutter/material.dart';
import 'package:snaply/src/entities/report_file.dart';
import 'package:snaply/src/ui/widgets/report_creator/report_files/preview/delete_media_file_button.dart';

class PreviewScreenshotFile extends StatelessWidget {
  const PreviewScreenshotFile({
    required this.file,
    super.key,
  });

  final ScreenshotFile file;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox.expand(
          child: Image.file(
            File(file.filePath),
            fit: BoxFit.cover,
          ),
        ),
        Container(color: Colors.black.withOpacity(0.3)),
        Positioned(
          top: 4,
          right: 4,
          child: DeleteMediaFileButton(mediaFile: file),
        ),
      ],
    );
  }
}
