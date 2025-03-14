import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:snaply/snaply.dart';
import 'package:snaply/src/data_holders/configuration_holder.dart';
import 'package:snaply/src/data_holders/custom_attributes_holder.dart';
import 'package:snaply/src/data_holders/custom_files_holder.dart';
import 'package:snaply/src/logger/snaply_logger.dart';
import 'package:snaply/src/snaply_initializer.dart';
import 'package:snaply/src/snaply_reporter_impl.dart';

class MockConfigurationHolder extends Mock implements ConfigurationHolder {}

class MockCustomAttributesHolder extends Mock
    implements CustomAttributesHolder {}

class MockCustomFilesHolder extends Mock implements CustomFilesHolder {}

class MockSnaplyLogger extends Mock implements SnaplyLogger {}

class MockSnaplyInitializer extends Mock implements SnaplyInitializer {}

void main() {
  late MockConfigurationHolder configHolder;
  late MockCustomAttributesHolder attributesHolder;
  late MockCustomFilesHolder customFilesHolder;
  late MockSnaplyLogger logger;
  late MockSnaplyInitializer initializer;
  late SnaplyReporter reporter;
  late VisibilityNotifier visibilityNotifier;

  setUpAll(() {
    registerFallbackValue(VisibilityNotifier());
  });

  setUp(() {
    configHolder = MockConfigurationHolder();
    attributesHolder = MockCustomAttributesHolder();
    customFilesHolder = MockCustomFilesHolder();
    logger = MockSnaplyLogger();
    initializer = MockSnaplyInitializer();
    visibilityNotifier = VisibilityNotifier();

    // Set up default behaviors
    when(() => configHolder.visibility).thenReturn(visibilityNotifier);
    when(() => configHolder.isVisible)
        .thenAnswer((_) => visibilityNotifier.value);
    when(() => initializer.isInitialized).thenReturn(true);

    reporter = SnaplyReporterImpl(
      initializer: initializer,
      configHolder: configHolder,
      attributesHolder: attributesHolder,
      customFilesHolder: customFilesHolder,
      logger: logger,
    );
  });

  group('SnaplyReporter', () {
    test('setVisibility updates configuration when enabled', () {
      reporter.setVisibility(isVisible: true);
      expect(visibilityNotifier.value, true);

      reporter.setVisibility(isVisible: false);
      expect(visibilityNotifier.value, false);
    });

    test('setAttributes updates attributes when enabled', () async {
      when(() => initializer.isInitialized).thenReturn(true);

      final attributes = {'key': 'value'};
      reporter.setAttributes(attributes);
      verify(() => attributesHolder.addAttributes(attributes)).called(1);
    });

    test('log adds message when enabled', () {
      when(() => initializer.isInitialized).thenReturn(true);

      const message = 'test message';
      reporter.log(message: message);
      verify(() => logger.addLog(message: message)).called(1);
    });

    test('setVisibility does nothing when reporter is disabled', () {
      when(() => initializer.isInitialized).thenReturn(false);

      final initialValue = visibilityNotifier.value;
      reporter.setVisibility(isVisible: true);

      // Verify the value didn't change
      expect(visibilityNotifier.value, equals(initialValue));
    });

    test('setAttributes does nothing when reporter is disabled', () async {
      when(() => initializer.isInitialized).thenReturn(false);
      final attributes = {'key': 'value'};

      reporter.setAttributes(attributes);
      verifyNever(() => attributesHolder.addAttributes(any()));
    });

    test('log does nothing when reporter is disabled', () {
      when(() => initializer.isInitialized).thenReturn(false);
      when(() => logger.addLog(message: any(named: 'message')))
          .thenAnswer((_) => {});
      const message = 'test message';
      reporter.log(message: message);
      verifyNever(() => logger.addLog(message: message));
    });

    test('setAttributes handles different attribute types', () {
      when(() => initializer.isInitialized).thenReturn(true);

      final attributes = {
        'string': 'value',
        'number': '42',
        'boolean': 'true',
      };

      reporter.setAttributes(attributes);
      verify(() => attributesHolder.addAttributes(attributes)).called(1);
    });

    test('log handles different message types', () {
      when(() => initializer.isInitialized).thenReturn(true);

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
