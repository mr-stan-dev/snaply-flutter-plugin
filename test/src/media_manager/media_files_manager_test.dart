import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:snaply/src/media_manager/media_files_manager.dart';
import 'package:snaply/src/platform_interface/snaply_platform_interface.dart';

class MockPlatformInterface extends Mock implements SnaplyPlatformInterface {}

void main() {
  late MediaFilesManager manager;
  late MockPlatformInterface platform;
  late Directory tempDir;

  setUp(() async {
    platform = MockPlatformInterface();
    manager = MediaFilesManager(platform);
    // Create a temporary directory for test files
    tempDir = await Directory.systemTemp.createTemp('snaply_test_');
  });

  tearDown(() async {
    // Clean up - delete the temporary directory and its contents
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('takeScreenshot forwards call to platform', () async {
    final bytes = Uint8List(10);
    const index = 1;
    final dirPath = tempDir.path;

    when(() => platform.takeScreenshot()).thenAnswer((_) async => bytes);
    when(() => platform.getSnaplyDirectory()).thenAnswer((_) async => dirPath);

    final result = await manager.takeScreenshot(index);

    expect(result?.filePath, contains('screenshot_2'));
    expect(result?.createdAt, isNotNull);
    verify(() => platform.takeScreenshot()).called(1);
    verify(() => platform.getSnaplyDirectory()).called(1);

    // Verify the file was actually created
    final file = File(result!.filePath);
    expect(file.existsSync(), isTrue);
    expect(file.readAsBytesSync(), bytes);
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

    expect(result.filePath, path);
    expect(result.startedAt, isNotNull);
    expect(result.endedAt, isNotNull);
    verify(() => platform.stopVideoRecording()).called(1);
  });

  test('stopVideoRecording uses provided startedAt time', () async {
    const path = 'test/video.mp4';
    final startTime = DateTime(2024);
    when(() => platform.stopVideoRecording()).thenAnswer((_) async => path);

    final result = await manager.stopVideoRecording(videoStartedAt: startTime);

    expect(result.filePath, path);
    expect(result.startedAt, startTime);
    expect(result.endedAt, isNotNull);
    verify(() => platform.stopVideoRecording()).called(1);
  });
}
