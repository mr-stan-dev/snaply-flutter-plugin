import 'dart:convert';
import 'dart:io';

import 'package:snaply/src/entities/report_file.dart';

class FileToPathMapper {
  Future<File> map({
    required String appDirPath,
    required ReportFile file,
  }) async {
    switch (file) {
      case ScreenVideoFile():
        return File(file.filePath);
      case ScreenshotFile():
        final tempFile = File('$appDirPath/${file.fileName}');
        return await tempFile.writeAsBytes(file.bytes);
      case LogsFile():
        final tempFile = File('$appDirPath/${file.fileName}');
        return await tempFile.writeAsBytes(_toBytes(file.logs));
      case AttributesFile():
        final tempFile = File('$appDirPath/${file.fileName}');
        return await tempFile.writeAsBytes(_toBytes(file.attrs));
    }
  }

  List<int> _toBytes(Object object) {
    // Convert an object JSON string and then to bytes using UTF8
    return utf8.encode(jsonEncode(object));
  }
}
