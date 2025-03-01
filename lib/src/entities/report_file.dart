import 'dart:typed_data';

import 'package:snaply/src/logger/log_record.dart';

const videoFileType = 'video';
const imageFileType = 'image';

sealed class ReportFile {
  const ReportFile({
    required this.fileName,
    required this.type,
    required this.subtype,
  });

  final String fileName;
  final String type;
  final String subtype;

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
          fileName: 'snaply_screen_video.mp4',
          type: videoFileType,
          subtype: 'mp4',
        );

  final String filePath;
  final DateTime startedAt;
  final DateTime endedAt;

  @override
  Map<String, String> get metadata => {
        'startedAt': startedAt.toIso8601String(),
        'endedAt': endedAt.toIso8601String(),
      };
}

class ScreenshotFile extends ReportFile {
  const ScreenshotFile({
    required this.bytes,
    required this.index,
    required this.createdAt,
  }) : super(
          fileName: 'snaply_screenshot_${index + 1}.png',
          type: imageFileType,
          subtype: 'png',
        );

  final Uint8List bytes;
  final int index;
  final DateTime createdAt;

  @override
  Map<String, String> get metadata => {
        'createdAt': createdAt.toIso8601String(),
      };
}

class LogsFile extends ReportFile {
  const LogsFile({
    required this.logs,
  }) : super(
          fileName: 'snaply_logs.txt',
          type: 'txt',
          subtype: 'plain',
        );

  final List<LogRecord> logs;

  @override
  Map<String, String> get metadata => {};
}

class AttributesFile extends ReportFile {
  const AttributesFile({
    required this.attrs,
  }) : super(
          fileName: 'snaply_attributes.txt',
          type: 'txt',
          subtype: 'plain',
        );

  final Map<String, Map<String, String>> attrs;

  @override
  Map<String, String> get metadata => {};
}
