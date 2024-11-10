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

  setUp(() {
    configHolder = MockConfigurationHolder();
    attributesHolder = MockCustomAttributesHolder();
    logger = MockSnaplyLogger();

    // Set up default behaviors
    when(() => configHolder.visibility).thenReturn(VisibilityNotifier());

    reporter = SnaplyReporterImpl(
      isEnabled: true,
      configHolder: configHolder,
      attributesHolder: attributesHolder,
      logger: logger,
    );
  });

  group('SnaplyReporter', () {
    test('setVisibility updates configuration when enabled', () {
      final notifier = VisibilityNotifier();
      when(() => configHolder.visibility).thenReturn(notifier);

      reporter.setVisibility(true);

      verify(() => configHolder.visibility.value = true).called(1);
    });

    test('setAttributes updates attributes when enabled', () async {
      final attributes = {'key': 'value'};
      reporter.setAttributes(attributes);
      verify(() => attributesHolder.addAttributes(attributes)).called(1);
    });

    test('log adds message when enabled', () {
      const message = 'test message';
      reporter.log(message: message);
      verify(() => logger.addLog(message: message)).called(1);
    });

    test('setVisibility does nothing when reporter is disabled', () {
      reporter = SnaplyReporterImpl(
        isEnabled: false,
        configHolder: configHolder,
        attributesHolder: attributesHolder,
        logger: logger,
      );

      reporter.setVisibility(true);
      verifyNever(() => configHolder.visibility.value = true);
    });

    test('setAttributes does nothing when reporter is disabled', () async {
      reporter = SnaplyReporterImpl(
        isEnabled: false,
        configHolder: configHolder,
        attributesHolder: attributesHolder,
        logger: logger,
      );

      final attributes = {'key': 'value'};
      reporter.setAttributes(attributes);
      verifyNever(() => attributesHolder.addAttributes(attributes));
    });

    test('log does nothing when reporter is disabled', () {
      reporter = SnaplyReporterImpl(
        isEnabled: false,
        configHolder: configHolder,
        attributesHolder: attributesHolder,
        logger: logger,
      );

      const message = 'test message';
      reporter.log(message: message);
      verifyNever(() => logger.addLog(message: message));
    });

    test('setAttributes handles null attributes', () async {
      reporter.setAttributes({});
      verify(() => attributesHolder.addAttributes({})).called(1);
    });

    test('setAttributes handles empty attributes', () async {
      reporter.setAttributes({});
      verify(() => attributesHolder.addAttributes({})).called(1);
    });
  });
}
