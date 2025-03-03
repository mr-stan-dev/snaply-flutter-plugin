import 'package:snaply/src/logger/log_record.dart';

const videoFileType = 'video';
const imageFileType = 'image';

sealed class ReportFile {
  const ReportFile({
    required this.type,
    required this.subtype,
  });

  final String type;
  final String subtype;

  String get fileName;

  Map<String, String> get metadata;

  bool get isMediaFile {
    switch (this) {
      case ScreenVideoFile():
      case ScreenshotFile():
        return true;
      case LogsFile():
      case AttributesFile():
        return false;
    }
  }
}

class ScreenVideoFile extends ReportFile {
  const ScreenVideoFile({
    required this.filePath,
    required this.startedAt,
    required this.endedAt,
  }) : super(
          type: videoFileType,
          subtype: 'mp4',
        );

  final String filePath;
  final DateTime startedAt;
  final DateTime endedAt;

  @override
  String get fileName => Uri.file(filePath).pathSegments.last;

  @override
  Map<String, String> get metadata => {
        'startedAt': startedAt.toIso8601String(),
        'endedAt': endedAt.toIso8601String(),
      };
}

class ScreenshotFile extends ReportFile {
  const ScreenshotFile({
    required this.filePath,
    required this.createdAt,
  }) : super(
          type: imageFileType,
          subtype: 'png',
        );

  static String getPath({
    required String dirPath,
    required int index,
  }) =>
      '$dirPath/snaply_screenshot_${index + 1}.png';

  final String filePath;
  final DateTime createdAt;

  @override
  String get fileName => Uri.file(filePath).pathSegments.last;

  @override
  Map<String, String> get metadata => {
        'createdAt': createdAt.toIso8601String(),
      };
}

class LogsFile extends ReportFile {
  const LogsFile({
    required this.logs,
  }) : super(
          type: 'txt',
          subtype: 'plain',
        );

  @override
  String get fileName => 'snaply_logs.txt';

  final List<LogRecord> logs;

  @override
  Map<String, String> get metadata => {};
}

class AttributesFile extends ReportFile {
  const AttributesFile({
    required this.attrs,
  }) : super(
          type: 'txt',
          subtype: 'plain',
        );

  @override
  String get fileName => 'snaply_attributes.txt';

  final Map<String, Map<String, String>> attrs;

  @override
  Map<String, String> get metadata => {};
}
