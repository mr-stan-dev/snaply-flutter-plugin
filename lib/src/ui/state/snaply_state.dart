import 'package:equatable/equatable.dart';
import 'package:snaply/src/data_holders/configuration_holder.dart';
import 'package:snaply/src/entities/report_file.dart';
import 'package:snaply/src/entities/severity.dart';
import 'package:snaply/src/ui/state/reporting_stage.dart';

class SnaplyState extends Equatable {
  const SnaplyState({
    required this.controlsState,
    required this.title,
    required this.screenVideoProgressSec,
    required this.mediaFiles,
    required this.extraFiles,
    required this.reportingStage,
    required this.severity,
  });

  factory SnaplyState.initial() => SnaplyState(
        controlsState: ConfigurationHolder.instance.isVisible
            ? ControlsState.idle
            : ControlsState.invisible,
        title: '',
        screenVideoProgressSec: 0,
        mediaFiles: const [],
        extraFiles: const [],
        reportingStage: Gathering(),
        severity: Severity.medium,
      );

  static const maxVideoSec = 60;
  static const maxVideosNumber = 1;
  static const maxScreenshotsNumber = 10;

  final ControlsState controlsState;
  final String title;
  final int screenVideoProgressSec;
  final ReportingStage reportingStage;
  final List<ReportFile> mediaFiles;
  final List<ReportFile> extraFiles;
  final Severity severity;

  bool get isMaxVideoLength => screenVideoProgressSec == maxVideoSec;

  double get videoProgress => screenVideoProgressSec / maxVideoSec;

  int get videosTaken => mediaFiles.whereType<ScreenVideoFile>().length;

  bool get videosLimitReached => videosTaken >= maxVideosNumber;

  int get screenshotsTaken => mediaFiles.whereType<ScreenshotFile>().length;

  bool get screenshotsLimitReached => screenshotsTaken >= maxScreenshotsNumber;

  bool get isGathering => reportingStage is Gathering;

  bool get hasData =>
      screenshotsTaken > 0 || videosTaken > 0 || title.isNotEmpty;

  Map<String, Map<String, String>> get reportAttrs => {
        'report': {
          'title': title,
          'severity': severity.name,
        },
      };

  SnaplyState copyWith({
    ControlsState? controlsState,
    String? title,
    int? screenVideoProgressSec,
    ReportingStage? reportingStage,
    List<ReportFile>? mediaFiles,
    List<ReportFile>? extraFiles,
    Severity? severity,
    Map<String, Map<String, String>>? attributes,
  }) =>
      SnaplyState(
        controlsState: controlsState ?? this.controlsState,
        title: title ?? this.title,
        screenVideoProgressSec:
            screenVideoProgressSec ?? this.screenVideoProgressSec,
        mediaFiles: mediaFiles ?? this.mediaFiles,
        extraFiles: extraFiles ?? this.extraFiles,
        reportingStage: reportingStage ?? this.reportingStage,
        severity: severity ?? this.severity,
      );

  @override
  List<Object?> get props => [
        'controlsState: $controlsState',
        'title: $title',
        'screenVideoProgressSec: $screenVideoProgressSec',
        'mediaFiles.length: ${mediaFiles.length}',
        'mediaFiles.hashCode: ${mediaFiles.hashCode}',
        'extraFiles.length: ${extraFiles.length}',
        'extraFiles.hashCode: ${extraFiles.hashCode}',
        'reportingStage: $reportingStage',
        'severity: $severity',
      ];
}

enum ControlsState {
  idle,
  active,
  recordingInProgress,
  invisible;

  static ControlsState fromVisibility({required bool isVisible}) =>
      isVisible ? ControlsState.idle : ControlsState.invisible;
}
