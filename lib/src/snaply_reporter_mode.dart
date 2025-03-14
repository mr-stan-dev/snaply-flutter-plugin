/// Defines how the reporter captures and shares bug reports.
sealed class SnaplyReporterMode {
  const SnaplyReporterMode();
}

/// Default mode that enables sharing bug reports as individual files.
final class SharingFilesMode extends SnaplyReporterMode {
  const SharingFilesMode();
}
