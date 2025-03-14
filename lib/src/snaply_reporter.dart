import 'package:snaply/src/data_holders/callbacks_holder.dart';
import 'package:snaply/src/data_holders/configuration_holder.dart';
import 'package:snaply/src/data_holders/custom_attributes_holder.dart';
import 'package:snaply/src/data_holders/custom_files_holder.dart';
import 'package:snaply/src/logger/snaply_logger.dart';
import 'package:snaply/src/snaply_initializer.dart';
import 'package:snaply/src/snaply_reporter_impl.dart';

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
    callbacksHolder: CallbacksHolder.instance,
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
  void setCustomFiles({
    required Map<String, String>? filesPaths,
  });

  /// Sets callback functions to be invoked during the bug reporting process.
  ///
  /// Use this method to configure custom behavior that should be executed at
  /// specific points during the bug reporting flow.
  ///
  /// Parameters:
  /// * [onReportReview]: An optional callback function that is invoked when the
  /// user starts reviewing their bug report. This is useful for setting custom
  /// attributes and files just before report review screen is visible.
  /// The callback is async function so you can perform any long-run
  /// operations to get and set all the required data.
  /// If null is provided, any previously set callback will be removed.
  ///
  /// Example:
  /// ```dart
  /// reporter.setCallbacks(
  ///   onReportReview: () async {
  ///     SnaplyReporter.setAttributes(...)
  ///     SnaplyReporter.setCustomFiles(...)
  ///   },
  /// );
  ///
  /// // Remove the callback
  /// reporter.setCallbacks(
  ///   onReportReview: null,
  /// );
  /// ```
  ///
  /// Note: The callback will only be executed if the reporter is initialized.
  /// Multiple calls to this method will override previously set callbacks.
  void setCallbacks({
    Future<void> Function()? onReportReview,
  });
}
