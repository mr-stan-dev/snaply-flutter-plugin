import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:snaply/snaply.dart';
import 'package:snaply/src/data_holders/configuration_holder.dart';
import 'package:snaply/src/data_holders/custom_attributes_holder.dart';
import 'package:snaply/src/data_holders/custom_files_holder.dart';
import 'package:snaply/src/logger/snaply_logger.dart';
import 'package:snaply/src/snaply_reporter_impl.dart';

class MockConfigurationHolder extends Mock implements ConfigurationHolder {
  // Remove this override since we want to mock it normally
  // @override
  // void setMode(SnaplyReporterMode? mode) {}
}

class MockCustomAttributesHolder extends Mock
    implements CustomAttributesHolder {}

class MockCustomFilesHolder extends Mock implements CustomFilesHolder {}

class MockSnaplyLogger extends Mock implements SnaplyLogger {}

void main() {
  late MockConfigurationHolder configHolder;
  late MockCustomAttributesHolder attributesHolder;
  late MockCustomFilesHolder customFilesHolder;
  late MockSnaplyLogger logger;
  late SnaplyReporter reporter;
  late VisibilityNotifier visibilityNotifier;

  setUpAll(() {
    registerFallbackValue(VisibilityNotifier());
    registerFallbackValue(SharingFilesMode());
  });

  setUp(() {
    configHolder = MockConfigurationHolder();
    attributesHolder = MockCustomAttributesHolder();
    customFilesHolder = MockCustomFilesHolder();
    logger = MockSnaplyLogger();
    visibilityNotifier = VisibilityNotifier();

    // Set up default behaviors
    when(() => configHolder.visibility).thenReturn(visibilityNotifier);
    when(() => configHolder.isEnabled).thenReturn(true);
    when(() => configHolder.isVisible)
        .thenAnswer((_) => visibilityNotifier.value);

    reporter = SnaplyReporterImpl(
      configHolder: configHolder,
      attributesHolder: attributesHolder,
      customFilesHolder: customFilesHolder,
      logger: logger,
    );
  });

  group('initialization', () {
    test('isEnabled reflects configuration holder state', () {
      when(() => configHolder.isEnabled).thenReturn(true);
      expect(reporter.isEnabled, isTrue);

      when(() => configHolder.isEnabled).thenReturn(false);
      expect(reporter.isEnabled, isFalse);
    });

    test('init sets default mode when no mode provided', () async {
      when(() => configHolder.isEnabled).thenReturn(false);

      await reporter.init();

      verify(() => configHolder.setMode(any())).called(1);
    });

    test('init sets provided mode', () async {
      when(() => configHolder.isEnabled).thenReturn(false);
      final mode = SharingFilesMode();

      await reporter.init(mode: mode);

      verify(() => configHolder.setMode(mode)).called(1);
    });

    test('init throws when attempting to initialize already enabled reporter',
        () async {
      when(() => configHolder.isEnabled).thenReturn(true);

      when(() => configHolder.setMode(any()))
          .thenThrow(Exception('SnaplyReporterMode can be set only once'));

      expect(
        () => reporter.init(),
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

  group('integration scenarios', () {
    test('initialization enables reporter', () async {
      when(() => configHolder.isEnabled).thenReturn(false);

      await reporter.init();

      verify(() => configHolder.setMode(any())).called(1);
      // After init, subsequent calls should see reporter as enabled
      when(() => configHolder.isEnabled).thenReturn(true);

      // Now we can perform operations
      reporter.setVisibility(isVisible: true);
      expect(visibilityNotifier.value, true);
    });

    test('disabled reporter performs no operations', () async {
      when(() => configHolder.isEnabled).thenReturn(false);

      reporter
        ..setVisibility(isVisible: false)
        ..setAttributes({'key': 'value'})
        ..log(message: 'test');

      expect(visibilityNotifier.value, true);
      verifyNever(() => attributesHolder.addAttributes(any()));
      verifyNever(() => logger.addLog(message: any(named: 'message')));
    });
  });

  group('SnaplyReporter', () {
    test('setVisibility updates configuration when enabled', () {
      reporter.setVisibility(isVisible: true);
      expect(visibilityNotifier.value, true);

      reporter.setVisibility(isVisible: false);
      expect(visibilityNotifier.value, false);
    });

    test('setAttributes updates attributes when enabled', () async {
      when(() => configHolder.isEnabled).thenReturn(true);

      final attributes = {'key': 'value'};
      reporter.setAttributes(attributes);
      verify(() => attributesHolder.addAttributes(attributes)).called(1);
    });

    test('log adds message when enabled', () {
      when(() => configHolder.isEnabled).thenReturn(true);

      const message = 'test message';
      reporter.log(message: message);
      verify(() => logger.addLog(message: message)).called(1);
    });

    test('setVisibility does nothing when reporter is disabled', () {
      when(() => configHolder.isEnabled).thenReturn(false);

      final initialValue = visibilityNotifier.value;
      reporter.setVisibility(isVisible: true);

      // Verify the value didn't change
      expect(visibilityNotifier.value, equals(initialValue));
    });

    test('setAttributes does nothing when reporter is disabled', () async {
      when(() => configHolder.isEnabled).thenReturn(false);
      final attributes = {'key': 'value'};

      reporter.setAttributes(attributes);
      verifyNever(() => attributesHolder.addAttributes(any()));
    });

    test('log does nothing when reporter is disabled', () {
      when(() => configHolder.isEnabled).thenReturn(false);
      when(() => logger.addLog(message: any(named: 'message')))
          .thenAnswer((_) => {});
      const message = 'test message';
      reporter.log(message: message);
      verifyNever(() => logger.addLog(message: message));
    });

    test('setAttributes handles different attribute types', () {
      when(() => configHolder.isEnabled).thenReturn(true);

      final attributes = {
        'string': 'value',
        'number': '42',
        'boolean': 'true',
      };

      reporter.setAttributes(attributes);
      verify(() => attributesHolder.addAttributes(attributes)).called(1);
    });

    test('log handles different message types', () {
      when(() => configHolder.isEnabled).thenReturn(true);

      reporter.log(message: 'simple message');
      verify(() => logger.addLog(message: 'simple message')).called(1);

      reporter.log(message: '');
      verify(() => logger.addLog(message: '')).called(1);

      reporter.log(message: r'message with special chars !@#$%^&*()');
      verify(
        () => logger.addLog(message: r'message with special chars !@#$%^&*()'),
      ).called(1);
    });
  });
}
