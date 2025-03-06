import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:snaply/src/archive/archive_creator.dart';
import 'package:snaply/src/archive/archive_entry.dart';
import 'package:snaply/src/entities/report_file.dart';
import 'package:snaply/src/mappers/file_to_archive_entry_mapper.dart';
import 'package:snaply/src/mappers/file_to_path_mapper.dart';
import 'package:snaply/src/platform_interface/snaply_platform_interface.dart';
import 'package:snaply/src/usecase/share_files_usecase.dart';

class MockArchiveCreator extends Mock implements ArchiveCreator {}

class MockPlatformInterface extends Mock implements SnaplyPlatformInterface {}

class MockArchiveEntryMapper extends Mock implements FileToArchiveEntryMapper {}

class MockFileToPathMapper extends Mock implements FileToPathMapper {}

void main() {
  const tempDir = 'snaply_test_temp_dir';
  const videoPath = 'tempDir/video.mp4';
  const screenshotIndex = 2;
  const screenshotPath = '$tempDir/screenshot_${screenshotIndex + 1}.png';

  final videoFile = ScreenVideoFile(
    filePath: videoPath,
    startedAt: DateTime.now(),
    endedAt: DateTime.now(),
  );

  final screenshotFile = ScreenshotFile(
    filePath: screenshotPath,
    createdAt: DateTime.now(),
  );

  late ShareFilesUsecase usecase;
  late MockArchiveCreator archiveCreator;
  late MockPlatformInterface platformInterface;
  late MockArchiveEntryMapper archiveEntryMapper;
  late MockFileToPathMapper fileToPathMapper;

  setUp(() {
    archiveCreator = MockArchiveCreator();
    platformInterface = MockPlatformInterface();
    archiveEntryMapper = MockArchiveEntryMapper();
    fileToPathMapper = MockFileToPathMapper();

    usecase = ShareFilesUsecase(
      archiveCreator: archiveCreator,
      platformInterface: platformInterface,
      archiveEntryMapper: archiveEntryMapper,
      fileToPathMapper: fileToPathMapper,
    );

    // Set up default behaviors
    when(() => platformInterface.shareFiles(any())).thenAnswer((_) async {});
    when(() => platformInterface.getSnaplyDirectory())
        .thenAnswer((_) async => tempDir);
  });

  test(
      'share single file creates a single archive file and calls platform '
      'interface with correct path', () async {
    const archivePath = '$tempDir/snaply_report.tar';
    final videoEntry = ArchiveEntry.fromPath(filePath: videoPath);

    when(() => archiveEntryMapper.map(videoFile)).thenReturn(videoEntry);
    when(
      () => archiveCreator.create(
        dirPath: tempDir,
        entries: [videoEntry],
      ),
    ).thenAnswer((_) async => archivePath);

    await usecase.call(
      reportFiles: [videoFile],
      asArchive: true,
    );

    verify(() => platformInterface.getSnaplyDirectory()).called(1);
    verify(() => archiveEntryMapper.map(videoFile)).called(1);
    verify(
      () => archiveCreator.create(dirPath: tempDir, entries: [videoEntry]),
    ).called(1);
    verify(() => platformInterface.shareFiles([archivePath])).called(1);
  });

  test(
      'share multiple files should not call archive creator and shares archive',
      () async {
    // Mock file path mapping for both files
    when(() => fileToPathMapper.map(appDirPath: tempDir, file: videoFile))
        .thenAnswer((_) async => File(videoPath));
    when(() => fileToPathMapper.map(appDirPath: tempDir, file: screenshotFile))
        .thenAnswer((_) async => File(screenshotPath));

    await usecase.call(
      reportFiles: [videoFile, screenshotFile],
      asArchive: false,
    );

    // Verify all steps
    verify(() => fileToPathMapper.map(appDirPath: tempDir, file: videoFile))
        .called(1);
    verify(
      () => fileToPathMapper.map(appDirPath: tempDir, file: screenshotFile),
    ).called(1);
    verifyNever(() => archiveEntryMapper.map(videoFile));
    verifyNever(() => archiveEntryMapper.map(screenshotFile));
    verifyNever(
      () => archiveCreator.create(
        dirPath: any(named: 'dirPath'),
        entries: any(named: 'entries'),
      ),
    );
    verify(() => platformInterface.shareFiles([videoPath, screenshotPath]))
        .called(1);
  });
}
