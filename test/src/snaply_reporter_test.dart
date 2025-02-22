import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:snaply/snaply.dart';
import 'package:snaply/src/data_holders/configuration_holder.dart';
import 'package:snaply/src/data_holders/custom_attributes_holder.dart';
import 'package:snaply/src/logger/snaply_logger.dart';
import 'package:snaply/src/snaply_reporter_impl.dart';

class MockConfigurationHolder extends Mock implements ConfigurationHolder {}

class MockCustomAttributesHolder extends Mock
    implements CustomAttributesHolder {}

class MockSnaplyLogger extends Mock implements SnaplyLogger {}

void main() {
  late MockConfigurationHolder configHolder;
  late MockCustomAttributesHolder attributesHolder;
  late MockSnaplyLogger logger;
  late SnaplyReporter reporter;
  late VisibilityNotifier visibilityNotifier;

  setUpAll(() {
    registerFallbackValue(VisibilityNotifier());
  });

  setUp(() {
    configHolder = MockConfigurationHolder();
    attributesHolder = MockCustomAttributesHolder();
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
      logger: logger,
    );
  });

  group('SnaplyReporter', () {
    test('setVisibility updates configuration when enabled', () {
      reporter.setVisibility(true);
      expect(visibilityNotifier.value, true);

      reporter.setVisibility(false);
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
      reporter.setVisibility(true);

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

      reporter.log(message: 'message with special chars !@#\$%^&*()');
      verify(() =>
              logger.addLog(message: 'message with special chars !@#\$%^&*()'))
          .called(1);
    });
  });
}
