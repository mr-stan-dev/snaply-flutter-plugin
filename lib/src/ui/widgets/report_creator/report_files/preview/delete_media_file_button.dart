import 'package:flutter/material.dart';
import 'package:snaply/src/entities/report_file.dart';
import 'package:snaply/src/ui/state/snaply_state_action.dart';
import 'package:snaply/src/ui/state/snaply_state_provider.dart';

class DeleteMediaFileButton extends StatelessWidget {
  const DeleteMediaFileButton({
    required this.mediaFile,
    super.key,
  });

  final MediaFile mediaFile;

  @override
  Widget build(BuildContext context) {
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
              parentContext.act(DeleteMediaFile(mediaFile.fileName));
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
