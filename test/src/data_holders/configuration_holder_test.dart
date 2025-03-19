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

    group('initialization', () {
      test('isInitialized is false before configure', () {
        expect(holder.isInitialized, isFalse);
      });

      test('mode throws when accessed before configuration', () {
        expect(
          () => holder.mode,
          throwsA(anything),
        );
      });

      test('configure sets mode and enables holder', () async {
        const mode = SharingFilesMode();
        await holder.configure(mode);

        expect(holder.isInitialized, isTrue);
        expect(holder.mode, equals(mode));
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
