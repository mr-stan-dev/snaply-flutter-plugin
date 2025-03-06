import 'package:flutter_test/flutter_test.dart';
import 'package:snaply/src/data_holders/configuration_holder.dart';
import 'package:snaply/src/snaply_reporter_mode.dart';

void main() {
  late ConfigurationHolder holder;

  setUp(() {
    holder = ConfigurationHolder.instance;
  });

  group('ConfigurationHolder', () {
    test('instance is singleton', () {
      final holder1 = ConfigurationHolder.instance;
      final holder2 = ConfigurationHolder.instance;
      expect(identical(holder1, holder2), isTrue);
    });

    group('mode management', () {
      // As holder is a singleton - the order of tests matters
      test('isEnabled is false when mode is not set', () {
        expect(holder.isEnabled, isFalse);
      });

      test('mode throws when accessed before being set', () {
        expect(
          () => ConfigurationHolder.instance.mode,
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Attempt to get mode when it is not enabled'),
            ),
          ),
        );
      });

      test('setMode sets mode and enables holder', () {
        final mode = SharingFilesMode();
        holder.setMode(mode);
        expect(holder.isEnabled, isTrue);
        expect(holder.mode, isA<SharingFilesMode>());
      });

      test('setMode throws when called twice', () {
        expect(
          () => ConfigurationHolder.instance.setMode(SharingFilesMode()),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('SnaplyReporterMode can be set only once'),
            ),
          ),
        );
      });
    });

    group('visibility', () {
      test('visibility starts as true', () {
        expect(holder.visibility.value, isTrue);
        expect(holder.isVisible, isTrue);
      });

      test('isVisible reflects visibility value', () {
        holder.visibility.value = false;
        expect(holder.isVisible, isFalse);

        holder.visibility.value = true;
        expect(holder.isVisible, isTrue);
      });
    });

    group('configuration parsing', () {
      test('useMediaProjection is false by default', () {
        expect(holder.useMediaProjection, isFalse);
      });
    });
  });
}
