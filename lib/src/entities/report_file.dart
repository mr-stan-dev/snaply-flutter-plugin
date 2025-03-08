import 'package:snaply/src/data_holders/custom_files_holder.dart'
    show CustomFilesHolder;
import 'package:snaply/src/logger/log_record.dart';

abstract interface class MediaFile {
  String get fileName;
}

sealed class ReportFile {
  const ReportFile();

  String get fileName;

  bool get isMediaFile => this is MediaFile;
}

class ScreenVideoFile extends ReportFile implements MediaFile {
  const ScreenVideoFile({
    required this.filePath,
    required this.startedAt,
    required this.endedAt,
  });

  final String filePath;
  final DateTime startedAt;
  final DateTime endedAt;

  @override
  String get fileName => Uri.file(filePath).pathSegments.last;
}

class ScreenshotFile extends ReportFile implements MediaFile {
  const ScreenshotFile({
    required this.filePath,
    required this.createdAt,
  });

  static String getFullPath({
    required String dirPath,
    required int index,
  }) =>
      '$dirPath/snaply_screenshot_${index + 1}.png';

  final String filePath;
  final DateTime createdAt;

  @override
  String get fileName => Uri.file(filePath).pathSegments.last;
}

class LogsFile extends ReportFile {
  const LogsFile({
    required this.logs,
  });

  @override
  String get fileName => 'snaply_logs.txt';

  final List<LogRecord> logs;
}

class AttributesFile extends ReportFile {
  const AttributesFile({
    required this.attrs,
  });

  @override
  String get fileName => 'snaply_attributes.txt';

  final Map<String, Map<String, String>> attrs;
}

class CustomFile extends ReportFile {
  const CustomFile({
    required this.filePath,
    required this.exists,
    required this.length,
  });

  final String filePath;
  final bool exists;
  final int length;

  bool get isValidSize => length <= CustomFilesHolder.maxFilesSize;

  bool get isValid => exists && isValidSize;

  @override
  String get fileName => Uri.file(filePath).pathSegments.last;
}
