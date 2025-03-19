import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:snaply/snaply.dart';
import 'package:snaply/src/data_holders/configuration_holder.dart';
import 'package:snaply/src/data_holders/custom_attributes_holder.dart';
import 'package:snaply/src/data_holders/custom_files_holder.dart';
import 'package:snaply/src/logger/snaply_logger.dart';
import 'package:snaply/src/snaply_reporter_impl.dart';

class MockConfigurationHolder extends Mock implements ConfigurationHolder {
  @override
  bool get isInitialized => true;
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
  });

  setUp(() {
    configHolder = MockConfigurationHolder();
    attributesHolder = MockCustomAttributesHolder();
    customFilesHolder = MockCustomFilesHolder();
    logger = MockSnaplyLogger();
    visibilityNotifier = VisibilityNotifier();

    // Set up default behaviors
    when(() => configHolder.visibility).thenReturn(visibilityNotifier);
    when(() => configHolder.isVisible)
        .thenAnswer((_) => visibilityNotifier.value);

    reporter = SnaplyReporterImpl(
      configHolder: configHolder,
      attributesHolder: attributesHolder,
      customFilesHolder: customFilesHolder,
      logger: logger,
    );
  });

  group('SnaplyReporter', () {
    test('setVisibility updates configuration when initialized', () {
      reporter.setVisibility(isVisible: true);
      expect(visibilityNotifier.value, true);

      reporter.setVisibility(isVisible: false);
      expect(visibilityNotifier.value, false);
    });

    test('setAttributes updates attributes when initialized', () async {
      const attrKey = 'testKey';
      final attrMap = {'key': 'value'};
      reporter.setAttributes(attrKey: attrKey, attrMap: attrMap);
      verify(
        () => attributesHolder.addAttributes(
          attrKey: attrKey,
          attrMap: attrMap,
        ),
      ).called(1);
    });

    test('log adds message when initialized', () {
      const message = 'test message';
      reporter.log(message: message);
      verify(() => logger.addLog(message: message)).called(1);
    });

    test('setAttributes handles different attribute types', () {
      const attrKey = 'testKey';
      final attrMap = {
        'string': 'value',
        'number': '42',
        'boolean': 'true',
      };

      reporter.setAttributes(attrKey: attrKey, attrMap: attrMap);
      verify(
        () => attributesHolder.addAttributes(
          attrKey: attrKey,
          attrMap: attrMap,
        ),
      ).called(1);
    });

    test('log handles different message types', () {
      reporter.log(message: 'simple message');
      verify(() => logger.addLog(message: 'simple message')).called(1);

      reporter.log(message: '');
      verify(() => logger.addLog(message: '')).called(1);

      reporter.log(message: r'message with special chars !@#$%^&*()');
      verify(
        () => logger.addLog(message: r'message with special chars !@#$%^&*()'),
      ).called(1);
    });

    test('addCustomFile adds file', () async {
      const key = 'testFile';
      const path = '/path/to/file.txt';
      reporter.addCustomFile(key: key, path: path);
      verify(
        () => customFilesHolder.addCustomFile(
          key: key,
          path: path,
        ),
      ).called(1);
    });

    test('addCustomFile can be called multiple times with same key', () async {
      const key = 'testFile';
      const path1 = '/path/to/file1.txt';
      const path2 = '/path/to/file2.txt';

      reporter
        ..addCustomFile(key: key, path: path1)
        ..addCustomFile(key: key, path: path2);

      verifyInOrder([
        () => customFilesHolder.addCustomFile(key: key, path: path1),
        () => customFilesHolder.addCustomFile(key: key, path: path2),
      ]);
    });
  });
}
