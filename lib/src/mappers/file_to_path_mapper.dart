import 'dart:convert';
import 'dart:io';

import 'package:snaply/src/entities/report_file.dart';

class FileToPathMapper {
  Future<String?> map({
    required String appDirPath,
    required ReportFile file,
  }) async {
    switch (file) {
      case ScreenVideoFile():
        return file.filePath;
      case ScreenshotFile():
        return file.filePath;
      case LogsFile():
        final tempFile = File('$appDirPath/${file.fileName}');
        await tempFile.writeAsBytes(_toBytes(file.logs));
        return tempFile.path;
      case AttributesFile():
        final tempFile = File('$appDirPath/${file.fileName}');
        await tempFile.writeAsBytes(_toBytes(file.attrs));
        return tempFile.path;
      case CustomFile():
        if (file.isValid) {
          // Need to copy into snaply dir to be able to share a file
          final originalFile = File(file.filePath);
          final snaplyDirCopyPath = '$appDirPath/${file.fileName}';
          await originalFile.copy(snaplyDirCopyPath);
          return snaplyDirCopyPath;
        } else {
          return null;
        }
    }
  }

  List<int> _toBytes(Object object) {
    // Convert an object JSON string and then to bytes using UTF8
    return utf8.encode(jsonEncode(object));
  }
}
