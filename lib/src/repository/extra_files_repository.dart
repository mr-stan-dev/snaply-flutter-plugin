import 'package:snaply/src/data_holders/custom_attributes_holder.dart';
import 'package:snaply/src/entities/report_file.dart';
import 'package:snaply/src/logger/snaply_logger.dart';
import 'package:snaply/src/platform_interface/snaply_platform_interface.dart';

class ExtraFilesRepository {
  final SnaplyPlatformInterface _platform;
  final SnaplyLogger _logger;
  final CustomAttributesHolder _customAttributesHolder;

  const ExtraFilesRepository({
    required SnaplyPlatformInterface platform,
    required SnaplyLogger logger,
    required CustomAttributesHolder customAttributesHolder,
  })  : _platform = platform,
        _logger = logger,
        _customAttributesHolder = customAttributesHolder;

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

    return [
      logsFile,
      attrsFile,
    ];
  }
}
