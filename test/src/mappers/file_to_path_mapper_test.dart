import 'dart:io';

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

      expect(result, equals('test/video.mp4'));
    });

    test('maps ScreenshotFile to new file with bytes', () async {
      const index = 3;
      final filePath = '$tempDir/snaply_screenshot_${index + 1}.png';
      final file = ScreenshotFile(
        filePath: filePath,
        createdAt: DateTime.now(),
      );

      final result = await mapper.map(appDirPath: tempDir, file: file);

      expect(result, equals(filePath));
    });

    test('maps AttributesFile to new file with encoded content', () async {
      final attrs = {
        'device': {'model': 'Test Device'},
        'system': {'memory': '4 GB'},
      };
      final file = AttributesFile(attrs: attrs);

      final filePath = await mapper.map(appDirPath: tempDir, file: file);
      final ioFile = File(filePath!);

      expect(filePath, equals('$tempDir/snaply_attributes.txt'));
      expect(ioFile.existsSync(), isTrue);
      final content = await ioFile.readAsString();
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

      final filePath = await mapper.map(appDirPath: tempDir, file: file);
      final ioFile = File(filePath!);

      expect(ioFile.path, equals('$tempDir/snaply_logs.txt'));
      expect(ioFile.existsSync(), isTrue);
      final content = await ioFile.readAsString();
      expect(content, contains('log1'));
      expect(content, contains('log2'));
    });

    test('maps existing CustomFile to its path', () async {
      final customFilePath = '$tempDir/custom_file.txt';
      await File(customFilePath).writeAsString('test content');

      final file = CustomFile(
        filePath: customFilePath,
        exists: true,
        length: 100,
      );

      final result = await mapper.map(appDirPath: tempDir, file: file);

      expect(result, equals(customFilePath));
      expect(File(result!).existsSync(), isTrue);
    });

    test('maps non-existent CustomFile to null', () async {
      final file = CustomFile(
        filePath: '$tempDir/non_existent.txt',
        exists: false,
        length: 0,
      );

      final result = await mapper.map(appDirPath: tempDir, file: file);

      expect(result, isNull);
    });

    test('maps CustomFile larger than 10MB to null', () async {
      const maxFileSize = 5 * 1024 * 1024; // 5MB
      final file = CustomFile(
        filePath: '$tempDir/large_file.txt',
        exists: true,
        length: maxFileSize + 1, // Exceeds max size by 1 byte
      );

      final result = await mapper.map(appDirPath: tempDir, file: file);

      expect(result, isNull);
    });
  });
}
