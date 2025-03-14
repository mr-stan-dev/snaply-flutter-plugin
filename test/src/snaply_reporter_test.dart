import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:snaply/snaply.dart';
import 'package:snaply/src/data_holders/callbacks_holder.dart';
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

class MockCallbacksHolder extends Mock implements CallbacksHolder {}

void main() {
  late MockConfigurationHolder configHolder;
  late MockCustomAttributesHolder attributesHolder;
  late MockCustomFilesHolder customFilesHolder;
  late MockSnaplyLogger logger;
  late MockSnaplyInitializer initializer;
  late MockCallbacksHolder callbacksHolder;
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
    callbacksHolder = MockCallbacksHolder();
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
      callbacksHolder: callbacksHolder,
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
      when(() => initializer.isInitialized).thenReturn(true);

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
      when(() => initializer.isInitialized).thenReturn(true);

      const message = 'test message';
      reporter.log(message: message);
      verify(() => logger.addLog(message: message)).called(1);
    });

    test('setVisibility does nothing when reporter is not initialized', () {
      when(() => initializer.isInitialized).thenReturn(false);

      final initialValue = visibilityNotifier.value;
      reporter.setVisibility(isVisible: true);

      // Verify the value didn't change
      expect(visibilityNotifier.value, equals(initialValue));
    });

    test('setAttributes does nothing when reporter is not initialized',
        () async {
      when(() => initializer.isInitialized).thenReturn(false);
      const attrKey = 'testKey';
      final attrMap = {'key': 'value'};

      reporter.setAttributes(attrKey: attrKey, attrMap: attrMap);
      verifyNever(
        () => attributesHolder.addAttributes(
          attrKey: any(named: 'attrKey'),
          attrMap: any(named: 'attrMap'),
        ),
      );
    });

    test(
      'log does nothing when reporter is not initialized',
      () {
        when(() => initializer.isInitialized).thenReturn(false);
        when(() => logger.addLog(message: any(named: 'message')))
            .thenAnswer((_) => {});
        const message = 'test message';
        reporter.log(message: message);
        verifyNever(() => logger.addLog(message: message));
      },
    );

    test('setAttributes handles different attribute types', () {
      when(() => initializer.isInitialized).thenReturn(true);

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

    test('setCallbacks updates onReportReview callback', () async {
      Future<void> onReportReview() async {}
      reporter.setCallbacks(onReportReview: onReportReview);
      verify(() => callbacksHolder.onReportReview = onReportReview).called(1);
    });

    test('setCallbacks can remove callback when null is provided', () async {
      Future<void> callback() async {}

      // First set a callback
      reporter.setCallbacks(onReportReview: callback);
      verify(() => callbacksHolder.onReportReview = callback).called(1);

      // Then remove it by setting null
      reporter.setCallbacks();
      verifyNever(() => callbacksHolder.onReportReview = callback);
    });

    test('setCallbacks can be called multiple times', () async {
      Future<void> firstCallback() async {}
      Future<void> secondCallback() async {}

      reporter.setCallbacks(onReportReview: firstCallback);
      verify(() => callbacksHolder.onReportReview = firstCallback).called(1);

      reporter.setCallbacks(onReportReview: secondCallback);
      verify(() => callbacksHolder.onReportReview = secondCallback).called(1);

      // Can also set to null after setting callbacks
      reporter.setCallbacks();
      verifyNever(() => callbacksHolder.onReportReview = firstCallback);
      verifyNever(() => callbacksHolder.onReportReview = secondCallback);
    });

    test('setCallbacks can update callback', () async {
      Future<void> callback() async {}
      Future<void> emptyCallback() async {}

      reporter.setCallbacks(onReportReview: callback);
      verify(() => callbacksHolder.onReportReview = callback).called(1);

      reporter.setCallbacks(onReportReview: emptyCallback);
      verify(() => callbacksHolder.onReportReview = emptyCallback).called(1);
    });

    test('setCallbacks does not work when reporter is not initialized',
        () async {
      when(() => initializer.isInitialized).thenReturn(false);
      Future<void> callback() async {}

      reporter.setCallbacks(onReportReview: callback);
      verifyNever(() => callbacksHolder.onReportReview = callback);

      // Also verify that setting null doesn't work when not initialized
      reporter.setCallbacks();
      verifyNever(() => callbacksHolder.onReportReview = null);
    });

    test('addCustomFile adds file when initialized', () async {
      when(() => initializer.isInitialized).thenReturn(true);

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

    test('addCustomFile does nothing when reporter is not initialized',
        () async {
      when(() => initializer.isInitialized).thenReturn(false);
      const key = 'testFile';
      const path = '/path/to/file.txt';

      reporter.addCustomFile(key: key, path: path);
      verifyNever(
        () => customFilesHolder.addCustomFile(
          key: any(named: 'key'),
          path: any(named: 'path'),
        ),
      );
    });

    test('addCustomFile can be called multiple times with same key', () async {
      when(() => initializer.isInitialized).thenReturn(true);

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
