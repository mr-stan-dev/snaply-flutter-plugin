import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:snaply/src/entities/report_file.dart';
import 'package:snaply/src/logger/log_record.dart';
import 'package:snaply/src/mappers/file_to_path_mapper.dart';

void main() {
  late FileToPathMapper mapper;
  late String tempDir;

  setUp(() {
    mapper = FileToPathMapper();
    tempDir = Directory.systemTemp.createTempSync('snaply_test_').path;
  });

  tearDown(() {
    final dir = Directory(tempDir);
    if (dir.existsSync()) {
      dir.deleteSync(recursive: true);
    }
  });

  group('FileToPathMapper', () {
    test('maps ScreenVideoFile to existing file path', () async {
      final file = ScreenVideoFile(
        filePath: 'test/video.mp4',
        startedAt: DateTime.now(),
        endedAt: DateTime.now(),
      );

      final result = await mapper.map(appDirPath: tempDir, file: file);

      expect(result.path, equals('test/video.mp4'));
    });

    test('maps ScreenshotFile to new file with bytes', () async {
      final bytes = Uint8List.fromList([1, 2, 3]);
      const index = 1;
      final file = ScreenshotFile(
        bytes: bytes,
        index: index,
        createdAt: DateTime.now(),
      );

      final result = await mapper.map(appDirPath: tempDir, file: file);

      expect(
          result.path, equals('$tempDir/snaply_screenshot_${index + 1}.png'));
      expect(await result.exists(), isTrue);
      expect(await result.readAsBytes(), equals(bytes));
    });

    test('maps AttributesFile to new file with encoded content', () async {
      final attrs = {
        'device': {'model': 'Test Device'},
        'system': {'memory': '4 GB'},
      };
      final file = AttributesFile(attrs: attrs);

      final result = await mapper.map(appDirPath: tempDir, file: file);

      expect(result.path, equals('$tempDir/snaply_attributes.txt'));
      expect(await result.exists(), isTrue);
      final content = await result.readAsString();
      expect(content, contains('device'));
      expect(content, contains('model'));
      expect(content, contains('Test Device'));
    });

    test('maps LogsFile to new file with encoded content', () async {
      final logs = [
        LogRecord(
          timestamp: DateTime(1),
          message: 'log1',
        ),
        LogRecord(
          timestamp: DateTime(1),
          message: 'log2',
        ),
      ];
      final file = LogsFile(logs: logs);

      final result = await mapper.map(appDirPath: tempDir, file: file);

      expect(result.path, equals('$tempDir/snaply_logs.txt'));
      expect(await result.exists(), isTrue);
      final content = await result.readAsString();
      expect(content, contains('log1'));
      expect(content, contains('log2'));
    });
  });
}
