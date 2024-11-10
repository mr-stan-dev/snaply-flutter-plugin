import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:snaply/src/archive/archive_entry.dart';

class ArchiveCreator {
  static const _reportFilename = 'snaply_report.tar';

  /// Creates an archive based on the provided ArchiveEntry list.
  ///
  /// - If only one file is provided, the file is compressed (GZip) by default.
  /// - If multiple files are provided, they are archived as a ZIP file.
  Future<String> create({
    required String dirPath,
    required List<ArchiveEntry> entries,
  }) async {
    if (entries.isEmpty) {
      throw Exception("No archive entries provided.");
    }

    final String outputPath = '$dirPath/$_reportFilename';
    await _archiveEntries(entries, outputPath);
    debugPrint("TAR archive created at $outputPath");
    return outputPath;
  }

  /// Helper method to get file bytes from an ArchiveEntry.
  Future<List<int>> _getFileBytes(ArchiveEntry entry) async {
    if (entry.fileBytes != null) {
      return entry.fileBytes!;
    } else if (entry.filePath != null) {
      final file = File(entry.filePath!);
      if (!await file.exists()) {
        throw Exception("Input file does not exist: ${entry.filePath}");
      }
      return await file.readAsBytes();
    } else {
      throw Exception("No file data provided for ${entry.fileName}");
    }
  }

  Uint8List _createTarHeader(String fileName, int fileSize) {
    final header = Uint8List(512); // TAR header is always 512 bytes

    // File name (100 bytes)
    final nameBytes = utf8.encode(fileName);
    if (nameBytes.length > 100) {
      throw Exception("File name too long: $fileName");
    }
    header.setRange(0, nameBytes.length, nameBytes);

    // File mode (8 bytes) - "0000644 "
    header.setRange(100, 108, utf8.encode('0000644 '));

    // Owner's numeric user ID (8 bytes)
    header.setRange(108, 116, utf8.encode('0000000 '));

    // Group's numeric user ID (8 bytes)
    header.setRange(116, 124, utf8.encode('0000000 '));

    // File size in octal (12 bytes)
    final sizeString = '${fileSize.toRadixString(8).padLeft(11, '0')} ';
    header.setRange(124, 136, utf8.encode(sizeString));

    // Last modification time in octal (12 bytes)
    final mtime = (DateTime.now().millisecondsSinceEpoch ~/ 1000)
        .toRadixString(8)
        .padLeft(11, '0');
    final mtimeString = '$mtime ';
    header.setRange(136, 148, utf8.encode(mtimeString));

    // Checksum placeholder (8 bytes)
    header.setRange(148, 156, utf8.encode('        '));

    // Type flag (1 byte) - '0' for regular file
    header[156] = '0'.codeUnitAt(0);

    // Calculate checksum
    int checksum = 0;
    for (int i = 0; i < 512; i++) {
      checksum += header[i];
    }

    // Write real checksum (6 bytes + null + space)
    final checksumString = '${checksum.toRadixString(8).padLeft(6, '0')}\x00 ';
    header.setRange(148, 156, utf8.encode(checksumString));

    return header;
  }

  /// Archives multiple files into a ZIP archive using ArchiveEntry.
  Future<void> _archiveEntries(
    List<ArchiveEntry> entries,
    String outputPath,
  ) async {
    final outputFile = File(outputPath);
    final sink = outputFile.openWrite();

    try {
      for (final entry in entries) {
        final fileBytes = await _getFileBytes(entry);

        // Write header
        final header = _createTarHeader(entry.fileName, fileBytes.length);
        sink.add(header);

        // Write file data
        sink.add(fileBytes);

        // Pad to 512-byte boundary
        final padding = 512 - (fileBytes.length % 512);
        if (padding < 512) {
          sink.add(Uint8List(padding));
        }
      }

      // End marker (two 512-byte blocks of zeros)
      sink.add(Uint8List(1024));
    } finally {
      await sink.close();
    }
  }
}
