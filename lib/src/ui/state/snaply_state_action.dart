import 'package:equatable/equatable.dart';
import 'package:snaply/src/entities/report_file.dart';
import 'package:snaply/src/entities/severity.dart';

sealed class SnaplyStateAction extends Equatable {
  @override
  List<Object?> get props => [];
}

class SetControlsVisibility extends SnaplyStateAction {
  SetControlsVisibility(this.visibility);

  final bool visibility;

  @override
  List<Object?> get props => [visibility];
}

class Activate extends SnaplyStateAction {}

class Deactivate extends SnaplyStateAction {}

class ReviewReport extends SnaplyStateAction {}

class TakeScreenshot extends SnaplyStateAction {}

class ViewFileFullScreen extends SnaplyStateAction {
  ViewFileFullScreen(this.isMediaFiles, this.index);

  final bool isMediaFiles;
  final int index;

  @override
  List<Object?> get props => [
        isMediaFiles,
        index,
      ];
}

class CaptureMediaFiles extends SnaplyStateAction {}

class DeleteMediaFile extends SnaplyStateAction {
  DeleteMediaFile(this.fileName);

  final String fileName;

  @override
  List<Object?> get props => [fileName];
}

class UpdateReportTitle extends SnaplyStateAction {
  UpdateReportTitle(this.title);

  final String title;

  @override
  List<Object?> get props => [title];
}

class StartVideoRecording extends SnaplyStateAction {}

class StopVideoRecording extends SnaplyStateAction {}

class ClearInfoWidgets extends SnaplyStateAction {}

final class SetSeverity extends SnaplyStateAction {
  SetSeverity({
    required this.severity,
  });

  final Severity severity;

  @override
  List<Object?> get props => [severity];
}

final class ShareReport extends SnaplyStateAction {
  ShareReport({
    required this.asArchive,
  });

  final bool asArchive;

  @override
  List<Object?> get props => [asArchive];
}

final class ShareReportFile extends SnaplyStateAction {
  ShareReportFile({
    required this.file,
  });

  final ReportFile file;

  @override
  List<Object?> get props => [file];
}
