import 'package:flutter/foundation.dart';
import 'package:snaply/src/data_holders/callbacks_holder.dart';
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
    required CallbacksHolder callbacksHolder,
  })  : _initializer = initializer,
        _configHolder = configHolder,
        _attributesHolder = attributesHolder,
        _customFilesHolder = customFilesHolder,
        _logger = logger,
        _callbacksHolder = callbacksHolder;

  final SnaplyInitializer _initializer;
  final ConfigurationHolder _configHolder;
  final CustomAttributesHolder _attributesHolder;
  final CustomFilesHolder _customFilesHolder;
  final SnaplyLogger _logger;
  final CallbacksHolder _callbacksHolder;

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
  void setCustomFiles({
    required Map<String, String>? filesPaths,
  }) {
    _runIfInitialized(
      () => filesPaths == null
          ? _customFilesHolder.clear()
          : _customFilesHolder.setCustomFiles(filesPaths),
    );
  }

  @override
  void setCallbacks({
    Future<void> Function()? onReportReview,
  }) {
    _runIfInitialized(
      () {
        if (onReportReview != null) {
          _callbacksHolder.onReportReview = onReportReview;
        }
      },
    );
  }

  void _runIfInitialized(VoidCallback function) {
    if (_initializer.isInitialized) {
      function();
    }
  }
}
