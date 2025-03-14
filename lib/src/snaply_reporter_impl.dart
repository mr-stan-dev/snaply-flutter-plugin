import 'package:flutter/foundation.dart';
import 'package:snaply/src/data_holders/configuration_holder.dart';
import 'package:snaply/src/data_holders/custom_attributes_holder.dart';
import 'package:snaply/src/data_holders/custom_files_holder.dart';
import 'package:snaply/src/logger/snaply_logger.dart';
import 'package:snaply/src/snaply_initializer.dart';
import 'package:snaply/src/snaply_reporter.dart';

class SnaplyReporterImpl implements SnaplyReporter {
  SnaplyReporterImpl({
    required SnaplyInitializer initializer,
    required ConfigurationHolder configHolder,
    required CustomAttributesHolder attributesHolder,
    required CustomFilesHolder customFilesHolder,
    required SnaplyLogger logger,
  })  : _initializer = initializer,
        _configHolder = configHolder,
        _attributesHolder = attributesHolder,
        _customFilesHolder = customFilesHolder,
        _logger = logger;

  final SnaplyInitializer _initializer;
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
  void setAttributes(Map<String, String> attributes) {
    _runIfInitialized(
      () => _attributesHolder.addAttributes(attributes),
    );
  }

  @override
  void log({
    required String message,
  }) {
    _runIfInitialized(() => _logger.addLog(message: message));
  }

  @override
  void setCustomFiles({
    required Map<String, String>? filesPaths,
  }) {
    _runIfInitialized(
      () => filesPaths == null
          ? _customFilesHolder.clear()
          : _customFilesHolder.setCustomFiles(filesPaths),
    );
  }

  void _runIfInitialized(VoidCallback function) {
    if (_initializer.isInitialized) {
      function();
    }
  }
}
