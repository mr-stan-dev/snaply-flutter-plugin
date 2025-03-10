import 'package:flutter_test/flutter_test.dart';
import 'package:snaply/src/data_holders/custom_files_holder.dart';

void main() {
  late CustomFilesHolder holder;

  setUp(() {
    holder = CustomFilesHolder.instance..clear();
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

    group('setCustomFiles', () {
      test('adds files up to max limit', () {
        final files = Map.fromEntries(
          List.generate(6, (i) => MapEntry('file${i + 1}', 'path${i + 1}')),
        );

        holder.setCustomFiles(files);

        expect(holder.customFiles.length, equals(CustomFilesHolder.maxFiles));
        expect(holder.customFiles.containsKey('file6'), isFalse);
        expect(holder.customFiles['file1'], equals('path1'));
        expect(holder.customFiles['file5'], equals('path5'));
      });

      test('preserves existing files when adding new ones', () {
        holder
          ..setCustomFiles({
            'file1': 'path1',
            'file2': 'path2',
          })
          ..setCustomFiles({
            'file3': 'path3',
            'file4': 'path4',
          });

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
        holder
          ..setCustomFiles(
            Map.fromEntries(
              List.generate(5, (i) => MapEntry('file${i + 1}', 'path${i + 1}')),
            ),
          )
          ..setCustomFiles({'file3': 'new_path3'});

        expect(holder.customFiles.length, equals(CustomFilesHolder.maxFiles));
        expect(holder.customFiles['file3'], equals('new_path3'));
        expect(
          holder.customFiles.keys,
          containsAll(['file1', 'file2', 'file3', 'file4', 'file5']),
        );
      });

      test('ignores new files when at max limit', () {
        // Fill up to max
        holder
          ..setCustomFiles(
            Map.fromEntries(
              List.generate(5, (i) => MapEntry('file${i + 1}', 'path${i + 1}')),
            ),
          )
          ..setCustomFiles({'file6': 'path6'});

        expect(holder.customFiles.length, equals(CustomFilesHolder.maxFiles));
        expect(holder.customFiles.containsKey('file6'), isFalse);
      });

      test('preserves files when setting empty map', () {
        holder
          ..setCustomFiles({
            'file1': 'path1',
            'file2': 'path2',
          })
          ..setCustomFiles({});

        expect(
          holder.customFiles,
          equals({
            'file1': 'path1',
            'file2': 'path2',
          }),
        );
      });
    });

    group('clear', () {
      test('removes all files', () {
        holder
          ..setCustomFiles({
            'file1': 'path1',
            'file2': 'path2',
          })
          ..clear();

        expect(holder.customFiles, isEmpty);
      });
    });
  });
}
