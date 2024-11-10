import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:snaply/src/platform_interface/snaply_platform_impl.dart';

class MockMethodChannel extends Mock implements MethodChannel {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SnaplyPlatformImpl', () {
    late MockMethodChannel methodChannel;
    late SnaplyPlatformImpl platform;

    setUp(() {
      methodChannel = MockMethodChannel();
      platform = SnaplyPlatformImpl(methodChannel);
    });

    test('takeScreenshot returns bytes', () async {
      final bytes = Uint8List.fromList([1, 2, 3]);
      when(() => methodChannel.invokeMethod<Uint8List?>('takeScreenshotMethod'))
          .thenAnswer((_) async => bytes);

      final result = await platform.takeScreenshot();
      expect(result, bytes);
    });

    test('startVideoRecording completes successfully', () async {
      when(() => methodChannel.invokeMethod<void>('startScreenRecordingMethod'))
          .thenAnswer((_) async => Future.value());

      await expectLater(platform.startVideoRecording(), completes);
    });

    test('stopVideoRecording returns path', () async {
      const path = '/test/video.mp4';
      when(() =>
              methodChannel.invokeMethod<String?>('stopScreenRecordingMethod'))
          .thenAnswer((_) async => path);

      final result = await platform.stopVideoRecording();
      expect(result, path);
    });

    test('shareFiles calls method with paths', () async {
      final paths = ['/test/file1.jpg', '/test/file2.mp4'];
      when(() => methodChannel
              .invokeMethod<void>('shareFilesMethod', {'filePaths': paths}))
          .thenAnswer((_) async => Future.value());

      await expectLater(platform.shareFiles(paths), completes);
    });

    test('getSnaplyDirectory returns directory path', () async {
      const expectedPath = '/test/path';
      when(() =>
              methodChannel.invokeMethod<String?>('getSnaplyDirectoryMethod'))
          .thenAnswer((_) async => expectedPath);

      final result = await platform.getSnaplyDirectory();
      expect(result, expectedPath);
    });

    test('getDeviceInfo returns device info map', () async {
      final expectedInfo = {
        'device': {'model': 'test'},
        'system': {'os': 'test_os'}
      };
      when(() => methodChannel.invokeMethod<Map?>('getDeviceInfoMethod'))
          .thenAnswer((_) async => expectedInfo);

      final result = await platform.getDeviceInfo();
      expect(result, expectedInfo);
    });

    group('error handling', () {
      test('methods throw on platform exception', () async {
        when(() =>
                methodChannel.invokeMethod<Uint8List?>('takeScreenshotMethod'))
            .thenThrow(PlatformException(code: 'ERROR', message: 'Test error'));
        when(() =>
                methodChannel.invokeMethod<void>('startScreenRecordingMethod'))
            .thenThrow(PlatformException(code: 'ERROR', message: 'Test error'));
        when(() => methodChannel
                .invokeMethod<String?>('stopScreenRecordingMethod'))
            .thenThrow(PlatformException(code: 'ERROR', message: 'Test error'));
        when(() => methodChannel.invokeMethod<void>('shareFilesMethod', any()))
            .thenThrow(PlatformException(code: 'ERROR', message: 'Test error'));
        when(() =>
                methodChannel.invokeMethod<String?>('getSnaplyDirectoryMethod'))
            .thenThrow(PlatformException(code: 'ERROR', message: 'Test error'));
        when(() => methodChannel.invokeMethod<Map?>('getDeviceInfoMethod'))
            .thenThrow(PlatformException(code: 'ERROR', message: 'Test error'));

        await expectLater(platform.takeScreenshot(), throwsException);
        await expectLater(platform.startVideoRecording(), throwsException);
        await expectLater(platform.stopVideoRecording(), throwsException);
        await expectLater(platform.shareFiles([]), throwsException);
        await expectLater(platform.getSnaplyDirectory(), throwsException);
        await expectLater(platform.getDeviceInfo(), throwsException);
      });
    });
  });
}
