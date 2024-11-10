import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:snaply/src/entities/report_file.dart';
import 'package:snaply/src/logger/log_record.dart';
import 'package:snaply/src/mappers/file_to_archive_entry_mapper.dart';

void main() {
  late FileToArchiveEntryMapper mapper;

  setUp(() {
    mapper = FileToArchiveEntryMapper();
  });

  group('FileToArchiveEntryMapper', () {
    test('maps ScreenVideoFile to ArchiveEntry with path', () {
      final file = ScreenVideoFile(
        filePath: 'test/snaply_screen_video.mp4',
        startedAt: DateTime.now(),
        endedAt: DateTime.now(),
      );

      final entry = mapper.map(file);

      expect(entry.filePath, equals('test/snaply_screen_video.mp4'));
      expect(entry.fileBytes, isNull);
      expect(entry.fileName, equals('snaply_screen_video.mp4'));
    });

    test('maps ScreenshotFile to ArchiveEntry with bytes', () {
      final bytes = Uint8List.fromList([1, 2, 3]);
      const index = 3;
      final file = ScreenshotFile(
        bytes: bytes,
        index: index,
        createdAt: DateTime.now(),
      );

      final entry = mapper.map(file);

      expect(entry.fileBytes, equals(bytes));
      expect(entry.filePath, isNull);
      expect(entry.fileName, equals('snaply_screenshot_${index + 1}.png'));
    });

    test('maps AttributesFile to ArchiveEntry with encoded bytes', () {
      final attrs = {
        'device': {'model': 'Test Device'},
        'system': {'memory': '4 GB'},
      };
      final file = AttributesFile(attrs: attrs);

      final entry = mapper.map(file);

      expect(entry.fileBytes, isNotNull);
      expect(entry.filePath, isNull);
      expect(entry.fileName, equals('snaply_attributes.txt'));
    });

    test('maps LogsFile to ArchiveEntry with encoded bytes', () {
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

      final entry = mapper.map(file);

      expect(entry.fileBytes, isNotNull);
      expect(entry.filePath, isNull);
      expect(entry.fileName, equals('snaply_logs.txt'));
    });
  });
}
