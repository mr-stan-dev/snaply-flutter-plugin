import 'package:flutter/material.dart';
import 'package:snaply/src/entities/report_file.dart';
import 'package:snaply/src/ui/state/snaply_state_action.dart';
import 'package:snaply/src/ui/state/snaply_state_provider.dart';
import 'package:snaply/src/ui/widgets/report_creator/report_files/preview/preview_screenshot_file.dart';
import 'package:snaply/src/ui/widgets/report_creator/report_files/preview/preview_video_file.dart';

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
      child: InkWell(
        onTap: () => context.act(
          ViewFileFullScreen(
            isMediaFiles: file.isMediaFile,
            index: index,
          ),
        ),
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
    );
  }

  Widget _filePreview() {
    switch (file) {
      case final ScreenVideoFile f:
        return PreviewVideoFile(file: f);
      case final ScreenshotFile f:
        return PreviewScreenshotFile(file: f);
      case LogsFile():
        return _extraFilePreview(fileName: 'Logs');
      case AttributesFile():
        return _extraFilePreview(fileName: 'Attributes');
    }
  }

  Widget _extraFilePreview({
    required String fileName,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.text_snippet_rounded,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            fileName,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
