import 'package:flutter/foundation.dart';
import 'package:snaply/src/data_holders/configuration_holder.dart';
import 'package:snaply/src/data_holders/custom_attributes_holder.dart';
import 'package:snaply/src/logger/snaply_logger.dart';
import 'package:snaply/src/snaply_reporter.dart';

/// Internal implementation of [SnaplyReporter].
///
/// This class handles the core functionality of the Snaply reporting system:
/// - Visibility management
/// - Custom attributes collection
/// - Event logging
///
/// All operations are guarded by an enabled check to prevent unnecessary work
/// when the reporter is disabled.
class SnaplyReporterImpl implements SnaplyReporter {
  /// Creates a new instance of [SnaplyReporterImpl].
  ///
  /// All parameters are required and provide the core dependencies:
  /// - [isEnabled]: Controls whether operations are executed
  /// - [configHolder]: Manages reporter configuration state
  /// - [attributesHolder]: Stores custom attributes
  /// - [logger]: Handles logging operations
  SnaplyReporterImpl({
    required bool isEnabled,
    required ConfigurationHolder configHolder,
    required CustomAttributesHolder attributesHolder,
    required SnaplyLogger logger,
  })  : _isEnabled = isEnabled,
        _configHolder = configHolder,
        _attributesHolder = attributesHolder,
        _logger = logger;

  final bool _isEnabled;
  final ConfigurationHolder _configHolder;
  final CustomAttributesHolder _attributesHolder;
  final SnaplyLogger _logger;

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

  /// Executes the given [function] only if the reporter is enabled.
  ///
  /// This prevents unnecessary work and potential errors when the
  /// reporter is disabled.
  void _runIfEnabled(VoidCallback function) {
    if (!_isEnabled) return;
    function();
  }
}
