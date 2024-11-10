import 'dart:io';

import 'package:snaply/src/archive/archive_creator.dart';
import 'package:snaply/src/entities/report_file.dart';
import 'package:snaply/src/mappers/file_to_archive_entry_mapper.dart';
import 'package:snaply/src/mappers/file_to_path_mapper.dart';
import 'package:snaply/src/platform_interface/snaply_platform_interface.dart';

class ShareFilesUsecase {
  const ShareFilesUsecase({
    required ArchiveCreator archiveCreator,
    required SnaplyPlatformInterface platformInterface,
    required FileToArchiveEntryMapper archiveEntryMapper,
    required FileToPathMapper fileToPathMapper,
  })  : _archiveCreator = archiveCreator,
        _platformInterface = platformInterface,
        _archiveEntryMapper = archiveEntryMapper,
        _fileToPathMapper = fileToPathMapper;
  final ArchiveCreator _archiveCreator;
  final SnaplyPlatformInterface _platformInterface;
  final FileToArchiveEntryMapper _archiveEntryMapper;
  final FileToPathMapper _fileToPathMapper;

  Future<void> call({
    required List<ReportFile> reportFiles,
    required bool asArchive,
  }) async {
    final snaplyDirPath = await _platformInterface.getSnaplyDirectory();

    final List<String> filesPaths = [];

    if (asArchive) {
      final archiveEntries =
          reportFiles.map((f) => _archiveEntryMapper.map(f)).toList();
      final archivePath = await _archiveCreator.create(
        dirPath: snaplyDirPath,
        entries: archiveEntries,
      );
      filesPaths.add(archivePath);
    } else {
      final List<File> reportFilesPaths = await Future.wait(
        reportFiles.map(
          (f) => _fileToPathMapper.map(appDirPath: snaplyDirPath, file: f),
        ),
      );
      filesPaths.addAll(reportFilesPaths.map((f) => f.path));
    }
    await _platformInterface.shareFiles(filesPaths);
  }
}
