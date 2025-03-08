import 'package:flutter/material.dart';
import 'package:snaply/src/data_holders/custom_files_holder.dart';
import 'package:snaply/src/entities/report_file.dart';
import 'package:snaply/src/ui/state/snaply_state_action.dart';
import 'package:snaply/src/ui/state/snaply_state_provider.dart';

class FullViewCustomFile extends StatelessWidget {
  const FullViewCustomFile({
    required this.file,
    super.key,
  });

  final CustomFile file;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Text(
                  'Custom file',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () => context.act(ShareReportFile(file: file)),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: double.maxFinite,
              color: Theme.of(context).colorScheme.surfaceContainer,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),
                    Text('Name: ${file.fileName}'),
                    const SizedBox(height: 16),
                    Text('Size: ${_formatFileSize(file.length)}'),
                    const SizedBox(height: 16),
                    if (!file.isValidSize) ..._fileIsTooLargeWidgets(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _fileIsTooLargeWidgets() {
    return [
      const Icon(
        Icons.warning,
        color: Colors.orangeAccent,
        size: 40,
      ),
      const SizedBox(height: 16),
      Text(
        '(File is too large. Max size '
        '${_formatFileSize(CustomFilesHolder.maxFilesSize)})',
      ),
      const SizedBox(height: 16),
    ];
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
