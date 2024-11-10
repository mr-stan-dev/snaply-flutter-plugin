import 'dart:convert';

import 'package:snaply/src/archive/archive_entry.dart';
import 'package:snaply/src/entities/report_file.dart';

class FileToArchiveEntryMapper {
  ArchiveEntry map(ReportFile file) {
    switch (file) {
      case AttributesFile():
        return ArchiveEntry.fromBytes(
          fileName: file.fileName,
          fileBytes: _toBytes(file.attrs),
        );
      case ScreenVideoFile():
        return ArchiveEntry.fromPath(filePath: file.filePath);
      case ScreenshotFile():
        return ArchiveEntry.fromBytes(
          fileName: file.fileName,
          fileBytes: file.bytes,
        );
      case LogsFile():
        return ArchiveEntry.fromBytes(
          fileName: file.fileName,
          fileBytes: _toBytes(file.logs),
        );
    }
  }

  List<int> _toBytes(Object object) {
    // Convert an object JSON string and then to bytes using UTF8
    return utf8.encode(jsonEncode(object));
  }
}
