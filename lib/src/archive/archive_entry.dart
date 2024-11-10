import 'dart:io';

/// A model for a file to be archived. This allows files to be added dynamically either via a path or from bytes.
class ArchiveEntry {
  final String fileName;
  final List<int>? fileBytes;
  final String? filePath;

  ArchiveEntry.fromPath({
    required String this.filePath,
  })  : fileBytes = null,
        fileName = File(filePath).uri.pathSegments.last;

  ArchiveEntry.fromBytes({
    required this.fileName,
    required this.fileBytes,
  }) : filePath = null;
}
