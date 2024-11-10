import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:snaply/src/media_manager/media_files_manager.dart';
import 'package:snaply/src/platform_interface/snaply_platform_interface.dart';

class MockPlatformInterface extends Mock implements SnaplyPlatformInterface {}

void main() {
  late MediaFilesManager manager;
  late MockPlatformInterface platform;

  setUp(() {
    platform = MockPlatformInterface();
    manager = MediaFilesManager(platform);
  });

  test('takeScreenshot forwards call to platform', () async {
    final bytes = Uint8List(10);
    when(() => platform.takeScreenshot()).thenAnswer((_) async => bytes);

    final result = await manager.takeScreenshot();

    expect(result, bytes);
    verify(() => platform.takeScreenshot()).called(1);
  });

  test('startVideoRecording forwards call to platform', () async {
    when(() => platform.startVideoRecording()).thenAnswer((_) async => {});

    await manager.startVideoRecording();

    verify(() => platform.startVideoRecording()).called(1);
  });

  test('stopVideoRecording forwards call to platform', () async {
    const path = 'test/video.mp4';
    when(() => platform.stopVideoRecording()).thenAnswer((_) async => path);

    final result = await manager.stopVideoRecording();

    expect(result, path);
    verify(() => platform.stopVideoRecording()).called(1);
  });
}
