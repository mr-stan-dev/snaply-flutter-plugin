import 'dart:io';

import 'package:snaply/src/data_holders/custom_attributes_holder.dart';
import 'package:snaply/src/data_holders/custom_files_holder.dart';
import 'package:snaply/src/entities/report_file.dart';
import 'package:snaply/src/logger/snaply_logger.dart';
import 'package:snaply/src/platform_interface/snaply_platform_interface.dart';

class ExtraFilesRepository {
  const ExtraFilesRepository({
    required SnaplyPlatformInterface platform,
    required SnaplyLogger logger,
    required CustomAttributesHolder customAttributesHolder,
    required CustomFilesHolder customFilesHolder,
  })  : _platform = platform,
        _logger = logger,
        _customAttributesHolder = customAttributesHolder,
        _customFilesHolder = customFilesHolder;
  final SnaplyPlatformInterface _platform;
  final SnaplyLogger _logger;
  final CustomAttributesHolder _customAttributesHolder;
  final CustomFilesHolder _customFilesHolder;

  Future<List<ReportFile>> getExtraFiles({
    required Map<String, Map<String, String>> reportAttrs,
  }) async {
    final deviceInfoAttrs = await _platform.getDeviceInfo();
    final customAttrs = _customAttributesHolder.attributes;
    // Show in order: report, custom, deviceInfo
    final attrsFile = AttributesFile(
      attrs: {
        ...reportAttrs,
        ...customAttrs,
        ...deviceInfoAttrs,
      },
    );
    final logsFile = LogsFile(logs: _logger.logs);

    final customFiles = _customFilesHolder.customFiles.entries
        .map((entry) => File(entry.value))
        .map(
          (file) => CustomFile(
            filePath: file.path,
            exists: file.existsSync(),
            length: file.lengthSync(),
          ),
        )
        .toList();

    return [
      logsFile,
      attrsFile,
      ...customFiles,
    ];
  }
}
