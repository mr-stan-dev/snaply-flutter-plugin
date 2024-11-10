import 'package:flutter/material.dart';
import 'package:snaply/src/entities/report_file.dart';
import 'package:snaply/src/ui/widgets/report_creator/report_files/preview/report_file_preview.dart';
import 'package:snaply/src/utils/list_utils.dart';

class ExtraFilesPreviewLayout extends StatelessWidget {
  const ExtraFilesPreviewLayout({
    required this.extraFiles,
    super.key,
  });

  final List<ReportFile> extraFiles;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Extra files',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: extraFiles.mapIndexed(
              (i, f) => ReportFilePreview(index: i, file: f),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
