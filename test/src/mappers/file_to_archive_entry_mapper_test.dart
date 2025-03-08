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

      expect(entry!.filePath, equals('test/snaply_screen_video.mp4'));
      expect(entry.fileBytes, isNull);
      expect(entry.fileName, equals('snaply_screen_video.mp4'));
    });

    test('maps ScreenshotFile to ArchiveEntry with bytes', () {
      const index = 3;
      const filePath = 'folder/snaply_screenshot_${index + 1}.png';
      final file = ScreenshotFile(
        filePath: filePath,
        createdAt: DateTime.now(),
      );

      final entry = mapper.map(file);

      expect(entry!.filePath, filePath);
      expect(entry.fileName, equals('snaply_screenshot_${index + 1}.png'));
    });

    test('maps AttributesFile to ArchiveEntry with encoded bytes', () {
      final attrs = {
        'device': {'model': 'Test Device'},
        'system': {'memory': '4 GB'},
      };
      final file = AttributesFile(attrs: attrs);

      final entry = mapper.map(file);

      expect(entry!.fileBytes, isNotNull);
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

      expect(entry!.fileBytes, isNotNull);
      expect(entry.filePath, isNull);
      expect(entry.fileName, equals('snaply_logs.txt'));
    });

    test('maps CustomFile to ArchiveEntry with path', () {
      const file = CustomFile(
        filePath: 'test/custom_file.txt',
        exists: true,
        length: 100,
      );

      final entry = mapper.map(file);

      expect(entry!.filePath, equals('test/custom_file.txt'));
      expect(entry.fileBytes, isNull);
      expect(entry.fileName, equals('custom_file.txt'));
    });

    test('maps non-existent CustomFile to null', () {
      const file = CustomFile(
        filePath: 'test/non_existent.txt',
        exists: false,
        length: 0,
      );

      final entry = mapper.map(file);

      expect(entry, isNull);
    });

    test('maps CustomFile larger than 10MB to null', () {
      const maxFileSize = 5 * 1024 * 1024; // 5MB
      const file = CustomFile(
        filePath: 'test/large_file.txt',
        exists: true,
        length: maxFileSize + 1, // Exceeds max size by 1 byte
      );

      final entry = mapper.map(file);

      expect(entry, isNull);
    });
  });
}
