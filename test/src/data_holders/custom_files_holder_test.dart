import 'package:flutter_test/flutter_test.dart';
import 'package:snaply/src/data_holders/custom_files_holder.dart';

void main() {
  late CustomFilesHolder holder;

  setUp(() {
    holder = CustomFilesHolder.instance;
    holder.customFiles.clear();
  });

  group('CustomFilesHolder', () {
    group('singleton', () {
      test('returns same instance', () {
        final instance1 = CustomFilesHolder.instance;
        final instance2 = CustomFilesHolder.instance;

        expect(identical(instance1, instance2), isTrue);
      });

      test('constants are set correctly', () {
        expect(CustomFilesHolder.maxFilesSize, equals(5 * 1024 * 1024)); // 5MB
        expect(CustomFilesHolder.maxFiles, equals(5));
      });
    });

    group('addCustomFile', () {
      test('adds files up to max limit', () {
        // Add 6 files, only first 5 should be added
        for (var i = 0; i < 6; i++) {
          holder.addCustomFile(
            key: 'file${i + 1}',
            path: 'path${i + 1}',
          );
        }

        expect(holder.customFiles.length, equals(CustomFilesHolder.maxFiles));
        expect(holder.customFiles.containsKey('file6'), isFalse);
        expect(holder.customFiles['file1'], equals('path1'));
        expect(holder.customFiles['file5'], equals('path5'));
      });

      test('preserves existing files when adding new ones', () {
        holder
          ..addCustomFile(key: 'file1', path: 'path1')
          ..addCustomFile(key: 'file2', path: 'path2')
          ..addCustomFile(key: 'file3', path: 'path3')
          ..addCustomFile(key: 'file4', path: 'path4');

        expect(holder.customFiles.length, equals(4));
        expect(
          holder.customFiles,
          equals({
            'file1': 'path1',
            'file2': 'path2',
            'file3': 'path3',
            'file4': 'path4',
          }),
        );
      });

      test('updates existing file when at max limit', () {
        // Fill up to max
        for (var i = 0; i < 5; i++) {
          holder.addCustomFile(
            key: 'file${i + 1}',
            path: 'path${i + 1}',
          );
        }

        // Update an existing file
        holder.addCustomFile(key: 'file3', path: 'new_path3');

        expect(holder.customFiles.length, equals(CustomFilesHolder.maxFiles));
        expect(holder.customFiles['file3'], equals('new_path3'));
        expect(
          holder.customFiles.keys,
          containsAll(['file1', 'file2', 'file3', 'file4', 'file5']),
        );
      });

      test('ignores new files when at max limit', () {
        // Fill up to max
        for (var i = 0; i < 5; i++) {
          holder.addCustomFile(
            key: 'file${i + 1}',
            path: 'path${i + 1}',
          );
        }

        // Try to add a new file
        holder.addCustomFile(key: 'file6', path: 'path6');

        expect(holder.customFiles.length, equals(CustomFilesHolder.maxFiles));
        expect(holder.customFiles.containsKey('file6'), isFalse);
      });
    });

    group('clear', () {
      test('removes all files', () {
        holder
          ..addCustomFile(key: 'file1', path: 'path1')
          ..addCustomFile(key: 'file2', path: 'path2');

        holder.customFiles.clear();

        expect(holder.customFiles, isEmpty);
      });
    });
  });
}
