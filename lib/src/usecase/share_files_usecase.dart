import 'package:snaply/src/archive/archive_creator.dart';
import 'package:snaply/src/entities/report_file.dart';
import 'package:snaply/src/mappers/file_to_archive_entry_mapper.dart';
import 'package:snaply/src/mappers/file_to_path_mapper.dart';
import 'package:snaply/src/platform_interface/snaply_platform_interface.dart';
import 'package:snaply/src/utils/list_utils.dart';

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

    final filesPaths = asArchive
        ? await _getArchivePath(
            reportFiles: reportFiles,
            snaplyDirPath: snaplyDirPath,
          )
        : await _getIndividualFilesPaths(
            reportFiles: reportFiles,
            snaplyDirPath: snaplyDirPath,
          );
    await _platformInterface.shareFiles(filesPaths);
  }

  Future<List<String>> _getArchivePath({
    required List<ReportFile> reportFiles,
    required String snaplyDirPath,
  }) async {
    final archiveEntries = reportFiles.map(_archiveEntryMapper.map).toList();
    final archivePath = await _archiveCreator.create(
      dirPath: snaplyDirPath,
      entries: archiveEntries.whereNotNull(),
    );
    return [archivePath];
  }

  Future<List<String>> _getIndividualFilesPaths({
    required List<ReportFile> reportFiles,
    required String snaplyDirPath,
  }) async {
    final paths = await Future.wait(
      reportFiles.map(
        (f) => _fileToPathMapper.map(appDirPath: snaplyDirPath, file: f),
      ),
    );
    return paths.whereNotNull();
  }
}
