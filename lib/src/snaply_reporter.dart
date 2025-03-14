import 'package:snaply/src/data_holders/configuration_holder.dart';
import 'package:snaply/src/data_holders/custom_attributes_holder.dart';
import 'package:snaply/src/data_holders/custom_files_holder.dart';
import 'package:snaply/src/logger/snaply_logger.dart';
import 'package:snaply/src/snaply_initializer.dart';
import 'package:snaply/src/snaply_reporter_impl.dart';
import 'package:snaply/src/snaply_reporter_mode.dart';

/// Interface for capturing and managing bug reports with rich context.
///
/// Provides functionality for screenshots, recordings, logs, and device info.
/// Access through [instance]. See package documentation for setup and examples.
abstract interface class SnaplyReporter {
  /// Singleton instance with default configuration.
  static final SnaplyReporter instance = SnaplyReporterImpl(
    initializer: SnaplyInitializer.instance,
    configHolder: ConfigurationHolder.instance,
    attributesHolder: CustomAttributesHolder.instance,
    customFilesHolder: CustomFilesHolder.instance,
    logger: SnaplyLogger.instance,
  );

  /// Controls report activation button visibility.
  ///
  /// No effect during active report gathering/reviewing or when disabled.
  void setVisibility({required bool isVisible});

  /// Sets custom key-value attributes for bug reports.
  ///
  /// Replaces any previously set attributes. Values are included alongside
  /// automatically collected device and system information.
  void setAttributes(Map<String, String> attributes);

  /// Adds a timestamped message to logs file.
  ///
  /// Use for capturing important events, state changes, or debug context.
  /// Messages are automatically timestamped when added.
  void log({required String message});

  /// Sets custom files to be included in the bug report. Max 5 files.
  ///
  /// Each file must be:
  /// * Less than 5MB in size
  /// * Accessible with read permissions
  /// * Currently existing on the device
  ///
  /// [filesPaths] is a map where:
  /// * Key: A descriptive name for the file
  /// * Value: Absolute path to the file on the device
  ///
  /// If [filesPaths] is null it clears all custom files
  void setCustomFiles({required Map<String, String>? filesPaths});
}
