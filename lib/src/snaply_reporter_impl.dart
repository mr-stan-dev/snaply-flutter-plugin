import 'package:flutter/foundation.dart';
import 'package:snaply/src/data_holders/configuration_holder.dart';
import 'package:snaply/src/data_holders/custom_attributes_holder.dart';
import 'package:snaply/src/data_holders/custom_files_holder.dart';
import 'package:snaply/src/logger/snaply_logger.dart';
import 'package:snaply/src/snaply_reporter.dart';

class SnaplyReporterImpl implements SnaplyReporter {
  SnaplyReporterImpl({
    required ConfigurationHolder configHolder,
    required CustomAttributesHolder attributesHolder,
    required CustomFilesHolder customFilesHolder,
    required SnaplyLogger logger,
  })  : _configHolder = configHolder,
        _attributesHolder = attributesHolder,
        _customFilesHolder = customFilesHolder,
        _logger = logger;

  final ConfigurationHolder _configHolder;
  final CustomAttributesHolder _attributesHolder;
  final CustomFilesHolder _customFilesHolder;
  final SnaplyLogger _logger;

  @override
  void setVisibility({
    required bool isVisible,
  }) {
    _runIfInitialized(() => _configHolder.visibility.value = isVisible);
  }

  @override
  void setAttributes({
    required String attrKey,
    required Map<String, String> attrMap,
  }) {
    _runIfInitialized(
      () => _attributesHolder.addAttributes(
        attrKey: attrKey,
        attrMap: attrMap,
      ),
    );
  }

  @override
  void log({
    required String message,
  }) {
    _runIfInitialized(() => _logger.addLog(message: message));
  }

  @override
  void addCustomFile({
    required String key,
    required String path,
  }) {
    _runIfInitialized(
      () => _customFilesHolder.addCustomFile(key: key, path: path),
    );
  }

  @override
  void registerCallbacks({
    Future<void> Function()? onReportReview,
  }) {
    if (onReportReview != null) {
      _configHolder.onReportReview = onReportReview;
    }
  }

  void _runIfInitialized(VoidCallback function) {
    if (_configHolder.isInitialized) {
      function();
    }
  }
}
