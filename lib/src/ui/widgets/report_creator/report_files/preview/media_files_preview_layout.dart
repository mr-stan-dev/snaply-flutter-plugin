import 'package:flutter/material.dart';
import 'package:snaply/src/entities/report_file.dart';
import 'package:snaply/src/ui/state/snaply_state_action.dart';
import 'package:snaply/src/ui/state/snaply_state_provider.dart';
import 'package:snaply/src/ui/widgets/report_creator/report_files/preview/report_file_preview.dart';

class MediaFilesPreviewLayout extends StatelessWidget {
  const MediaFilesPreviewLayout({
    required this.mediaFiles,
    super.key,
  });

  final List<ReportFile> mediaFiles;

  @override
  Widget build(BuildContext context) {
    if (mediaFiles.isEmpty) {
      return const Center(
        child: Text('No media files attached'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Media files',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () => context.act(AddMediaFiles()),
              label: const Text('Add'),
              icon: const Icon(
                Icons.add,
                size: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: _mediaFilesPreview(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  List<Widget> _mediaFilesPreview() {
    List<Widget> widgets = [];
    for (int i = 0; i < mediaFiles.length; i++) {
      widgets.add(ReportFilePreview(index: i, file: mediaFiles[i]));
    }
    return widgets;
  }
}
