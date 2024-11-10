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
      child: InkWell(
        onTap: () => context.act(ViewFileFullScreen(file.isMediaFile, index)),
        child: Row(
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
      case ScreenVideoFile f:
        return VideoFilePreview(file: f);
      case ScreenshotFile f:
        return Stack(
          children: [
            SizedBox.expand(
              child: Image.memory(
                f.bytes,
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
}
