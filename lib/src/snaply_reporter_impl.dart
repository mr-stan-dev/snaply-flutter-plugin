import 'package:flutter/foundation.dart';
import 'package:snaply/src/data_holders/configuration_holder.dart';
import 'package:snaply/src/data_holders/custom_attributes_holder.dart';
import 'package:snaply/src/logger/snaply_logger.dart';
import 'package:snaply/src/snaply_reporter.dart';
import 'package:snaply/src/snaply_reporter_mode.dart';

class SnaplyReporterImpl implements SnaplyReporter {
  SnaplyReporterImpl({
    required ConfigurationHolder configHolder,
    required CustomAttributesHolder attributesHolder,
    required SnaplyLogger logger,
  })  : _configHolder = configHolder,
        _attributesHolder = attributesHolder,
        _logger = logger;

  final ConfigurationHolder _configHolder;
  final CustomAttributesHolder _attributesHolder;
  final SnaplyLogger _logger;

  @override
  Future<void> init({SnaplyReporterMode? mode}) async {
    _configHolder.setMode(mode);
  }

  @override
  bool get isEnabled => _configHolder.isEnabled;

  @override
  void setVisibility(bool visibility) {
    _runIfEnabled(() => _configHolder.visibility.value = visibility);
  }

  @override
  void setAttributes(Map<String, String> attributes) {
    _runIfEnabled(
      () => _attributesHolder.addAttributes(attributes),
    );
  }

  @override
  void log({
    required String message,
  }) {
    _runIfEnabled(() => _logger.addLog(message: message));
  }

  void _runIfEnabled(VoidCallback function) {
    if (isEnabled) {
      function();
    }
  }
}
