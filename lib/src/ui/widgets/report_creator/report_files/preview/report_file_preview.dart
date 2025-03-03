import 'dart:io';

import 'package:flutter/material.dart';
import 'package:snaply/src/entities/report_file.dart';
import 'package:snaply/src/ui/state/snaply_state_action.dart';
import 'package:snaply/src/ui/state/snaply_state_provider.dart';
import 'package:snaply/src/ui/widgets/report_creator/report_files/preview/video_file_preview.dart';

class ReportFilePreview extends StatelessWidget {
  const ReportFilePreview({
    required this.index,
    required this.file,
    super.key,
  });

  final int index;
  final ReportFile file;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Stack(
        children: [
          InkWell(
            onTap: () =>
                context.act(ViewFileFullScreen(file.isMediaFile, index)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.grey,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: _filePreview(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (file.isMediaFile)
            Positioned(
              top: 4,
              right: 4,
              child: _deleteButton(context),
            ),
        ],
      ),
    );
  }

  Widget _filePreview() {
    switch (file) {
      case ScreenVideoFile f:
        return VideoFilePreview(file: f);
      case ScreenshotFile f:
        return Stack(
          children: [
            SizedBox.expand(
              child: Image.file(
                File(f.filePath),
                fit: BoxFit.cover,
              ),
            ),
            Container(color: Colors.black.withOpacity(0.3)),
          ],
        );
      case LogsFile():
        return const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.text_snippet_rounded,
              size: 32,
            ),
            SizedBox(height: 8),
            Text('Logs')
          ],
        );
      case AttributesFile():
        return const Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.text_snippet_rounded,
                size: 32,
              ),
              SizedBox(height: 8),
              Text(
                'Attributes',
                textAlign: TextAlign.center,
              )
            ],
          ),
        );
    }
  }

  Widget _deleteButton(BuildContext context) {
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        padding: EdgeInsets.zero,
        shape: const CircleBorder(),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ).copyWith(
        minimumSize: WidgetStateProperty.all(const Size(24, 24)),
        fixedSize: WidgetStateProperty.all(const Size(24, 24)),
      ),
      onPressed: () => _showDeleteDialog(context),
      child: const Icon(
        Icons.close,
        size: 16,
        color: Colors.white,
      ),
    );
  }

  Future<void> _showDeleteDialog(BuildContext parentContext) {
    return showDialog(
      context: parentContext,
      builder: (context) => AlertDialog(
        title: const Text('Delete file?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              parentContext.act(DeleteMediaFile(file.fileName));
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
