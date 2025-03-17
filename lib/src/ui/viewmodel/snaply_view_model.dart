import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:snaply/snaply.dart';
import 'package:snaply/src/data_holders/configuration_holder.dart';
import 'package:snaply/src/entities/report_file.dart';
import 'package:snaply/src/logger/default_logs.dart';
import 'package:snaply/src/media_manager/media_files_manager.dart';
import 'package:snaply/src/repository/extra_files_repository.dart';
import 'package:snaply/src/ui/state/info_event.dart';
import 'package:snaply/src/ui/state/reporting_stage.dart';
import 'package:snaply/src/ui/state/snaply_state.dart';
import 'package:snaply/src/ui/state/snaply_state_action.dart';
import 'package:snaply/src/usecase/share_files_usecase.dart';
import 'package:snaply/src/utils/notifier_logging_mixin.dart';

class SnaplyViewModel extends ValueNotifier<SnaplyState>
    with NotifierLoggingMixin<SnaplyState> {
  SnaplyViewModel({
    required MediaFilesManager mediaManager,
    required ShareFilesUsecase shareReportUsecase,
    required ExtraFilesRepository extraFilesRepository,
    required ConfigurationHolder configurationHolder,
  })  : _mediaManager = mediaManager,
        _shareReportUsecase = shareReportUsecase,
        _extraFilesRepository = extraFilesRepository,
        _configurationHolder = configurationHolder,
        super(SnaplyState.initial());

  final MediaFilesManager _mediaManager;
  final ShareFilesUsecase _shareReportUsecase;
  final ExtraFilesRepository _extraFilesRepository;
  final ConfigurationHolder _configurationHolder;

  final _uiEventsController = StreamController<InfoEvent>();

  /// Stream of UI events for showing notifications and errors.
  Stream<InfoEvent> get uiEventsStream => _uiEventsController.stream;

  int _videoProgressSec = 0;
  Timer? _videoProgressTimer;
  DateTime? _videoStartedAt;

  @visibleForTesting
  Duration screenshotDelay = const Duration(milliseconds: 30);

  Future<void> act(SnaplyStateAction action) async {
    debugPrint('[SnaplyViewModel] act: $action');
    try {
      await _handleAction(action);
    } catch (e, s) {
      // High level error handling. Each action has also its own handling
      value = SnaplyState.initial();
      _showError(e, s, errorMsg: '$action error');
    }
  }

  Future<void> _handleAction(SnaplyStateAction action) async {
    switch (action) {
      case Activate():
        value = SnaplyState.initial().copyWith(
          controlsState: ControlsState.active,
        );
      case Deactivate():
        value = SnaplyState.initial();
      case SetControlsVisibility():
        _handleVisibility(action.isVisible);
      case TakeScreenshot():
        await _takeScreenshot();
      case ViewFileFullScreen():
        if (!action.isMediaFiles) {
          /// Build here so users can see a fresh version of attrs in text file
          /// as we might update report attrs (title, severity, etc..)
          await _buildExtraFiles();
        }
        value = value.copyWith(
          reportingStage: ViewingFiles(
            isMediaFiles: action.isMediaFiles,
            index: action.index,
          ),
        );
      case CaptureMediaFiles():
        value = value.copyWith(
          controlsState: ControlsState.active,
          reportingStage: Gathering(),
        );
      case DeleteMediaFile():
        _handleDeleteMediaFile(action.fileName);
      case StartVideoRecording():
        await _startVideoRecording();
      case StopVideoRecording():
        await _stopVideoRecording();
      case UpdateReportTitle():
        value = value.copyWith(title: action.title);
      case SetSeverity():
        value = value.copyWith(severity: action.severity);
      case ClearInfoWidgets():
        _uiEventsController.add(ClearAllWidgets());
      case ReviewReport():
        await _reviewReport();
      case ShareReportFile():
        await _shareReportFile(action.file);
      case ShareReport():
        await _shareReport(action.asArchive);
    }
  }

  void _showError(Object? e, StackTrace? s, {required String errorMsg}) {
    debugPrint('[SnaplyViewModel] errorMsg: $errorMsg, error: $e, stack: $s');
    _uiEventsController.add(ErrorEvent(errorMsg));
  }

  void _handleVisibility(bool visibility) {
    if (visibility && value.controlsState == ControlsState.invisible) {
      value = value.copyWith(controlsState: ControlsState.idle);
    } else if (!visibility && value.controlsState == ControlsState.idle) {
      value = value.copyWith(controlsState: ControlsState.invisible);
    }
  }

  Future<void> _takeScreenshot() async {
    if (value.screenshotsLimitReached) {
      const msg =
          'Screenshots limit reached (${SnaplyState.maxScreenshotsNumber})';
      _uiEventsController.add(const PlainInfo(msg));
      return;
    }
    try {
      value = value.copyWith(controlsState: ControlsState.invisible);
      // Delay needed to hide controls before we take a screenshot
      // 30 ms works fine on both android & ios
      await Future.delayed(screenshotDelay, () {});
      final index = value.mediaFiles.whereType<ScreenshotFile>().length;
      final screenshot = await _mediaManager.takeScreenshot(index);
      if (screenshot != null) {
        SnaplyReporter.instance.log(message: DefaultLogs.screenshotTaken);
        _uiEventsController.add(PlainInfo.short('Screenshot taken'));
        value = value.copyWith(
          mediaFiles: [...value.mediaFiles, screenshot],
          controlsState: ControlsState.active,
          reportingStage: Gathering(),
        );
      } else {
        throw Exception('screenshot == null');
      }
    } catch (e, s) {
      _showError(e, s, errorMsg: 'Take screenshot error');
    }
  }

  Future<void> _startVideoRecording() async {
    if (value.videosLimitReached) {
      const msg = 'Video files limit reached (${SnaplyState.maxVideosNumber})';
      _uiEventsController.add(const PlainInfo(msg));
      return;
    }
    try {
      await _mediaManager.startVideoRecording(
        isMediaProjection: _configurationHolder.useMediaProjection,
      );
      SnaplyReporter.instance.log(message: DefaultLogs.screenVideoStarted);
      _videoStartedAt = DateTime.timestamp();
      value = value.copyWith(
        controlsState: ControlsState.recordingInProgress,
      );
      _videoProgressTimer = Timer.periodic(
        const Duration(seconds: 1),
        (tick) {
          _videoProgressSec++;
          value = value.copyWith(screenVideoProgressSec: _videoProgressSec);
          if (value.isMaxVideoLength) {
            _stopVideoRecording();
          }
        },
      );
    } catch (e, s) {
      _showError(e, s, errorMsg: 'Start recording error');
    }
  }

  Future<void> _stopVideoRecording() async {
    try {
      final videoFile = await _mediaManager.stopVideoRecording(
        videoStartedAt: _videoStartedAt,
      );
      SnaplyReporter.instance.log(message: DefaultLogs.screenVideoFinished);
      _uiEventsController.add(PlainInfo.short('Screen video taken'));
      value = value.copyWith(
        mediaFiles: [...value.mediaFiles, videoFile],
      );
      await _reviewReport();
    } catch (e, s) {
      value = value.copyWith(controlsState: ControlsState.idle);
      _showError(e, s, errorMsg: 'Stop recording error');
    } finally {
      _resetVideoState();
    }
  }

  void _handleDeleteMediaFile(String fileName) {
    final newMediaFiles = [...value.mediaFiles];
    final fileToRemove =
        value.mediaFiles.firstWhere((f) => f.fileName == fileName);
    final isVideo = fileToRemove is ScreenVideoFile;
    if (isVideo) {
      _resetVideoState();
    }
    newMediaFiles.remove(fileToRemove);
    value = value.copyWith(mediaFiles: newMediaFiles);
  }

  void _resetVideoState() {
    value = value.copyWith(screenVideoProgressSec: 0);
    _videoStartedAt = null;
    _videoProgressTimer?.cancel();
    _videoProgressTimer = null;
    _videoProgressSec = 0;
  }

  Future<void> _reviewReport() async {
    value = value.copyWith(
      controlsState: ControlsState.invisible,
      reportingStage: Loading.preparing,
    );
    try {
      await ConfigurationHolder.instance.onReportReview?.call();
    } catch (e) {
      _uiEventsController.add(
        const ErrorEvent(
          'Error while calling onReportReview',
          autoHideDelay: Duration(seconds: 3),
        ),
      );
    }
    await _buildExtraFiles();
    value = value.copyWith(reportingStage: ViewingReport());
  }

  Future<void> _buildExtraFiles() async {
    try {
      final files = await _extraFilesRepository.getExtraFiles(
        reportAttrs: value.reportAttrs,
      );
      value = value.copyWith(extraFiles: files);
    } catch (e, s) {
      _showError(e, s, errorMsg: 'Extra files error');
    }
  }

  Future<void> _shareReportFile(ReportFile file) async {
    try {
      await _shareReportUsecase.call(
        reportFiles: [file],
        asArchive: false,
      );
    } catch (e, s) {
      _showError(e, s, errorMsg: 'Share report error');
    }
  }

  Future<void> _shareReport(bool asArchive) async {
    try {
      // Make sure extra files are up to date
      await _buildExtraFiles();
      await _shareReportUsecase.call(
        reportFiles: [
          ...value.mediaFiles,
          ...value.extraFiles,
        ],
        asArchive: asArchive,
      );
    } catch (e, s) {
      _showError(e, s, errorMsg: 'Share report error');
    }
  }
}
