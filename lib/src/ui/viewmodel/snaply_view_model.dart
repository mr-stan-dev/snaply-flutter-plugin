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
        super(SnaplyState.initial);

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
      _handleAction(action);
    } catch (e, s) {
      // High level error handling. Each action has also its own handling
      value = SnaplyState.initial;
      _showError(e, s, errorMsg: '$action error');
    }
  }

  Future<void> _handleAction(SnaplyStateAction action) async {
    switch (action) {
      case Activate():
        value = SnaplyState.initial.copyWith(
          controlsState: ControlsState.active,
        );
      case Deactivate():
        value = SnaplyState.initial;
      case SetControlsVisibility():
        _handleVisibility(action.visibility);
      case TakeScreenshot():
        await _takeScreenshot();
      case ViewFileFullScreen():
        if (!action.isMediaFiles) {
          // Build here so users can see a fresh version of attrs in text file
          await _addExtraFiles();
        }
        value = value.copyWith(
          reportingStage: ViewingFiles(
            isMediaFiles: action.isMediaFiles,
            index: action.index,
          ),
        );
      case AddMediaFiles():
        value = value.copyWith(
          controlsState: ControlsState.active,
          reportingStage: Gathering(),
        );
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
        await _addExtraFiles();
        value = value.copyWith(reportingStage: ViewingReport());
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
      _uiEventsController.add(PlainInfo(msg));
      return;
    }
    try {
      value = value.copyWith(controlsState: ControlsState.invisible);
      // Delay needed to hide controls before we take a screenshot
      // 30 ms works fine on both android & ios
      await Future.delayed(screenshotDelay);
      final bytes = await _mediaManager.takeScreenshot();
      if (bytes != null) {
        SnaplyReporter.instance.log(message: DefaultLogs.screenshotTaken);
        _uiEventsController.add(PlainInfo.short('Screenshot taken'));
        final index = value.mediaFiles.whereType<ScreenshotFile>().length;
        value = value.copyWith(
          mediaFiles: [
            ...value.mediaFiles,
            ScreenshotFile(
              bytes: bytes,
              index: index,
              createdAt: DateTime.timestamp(),
            )
          ],
          controlsState: ControlsState.active,
          reportingStage: Gathering(),
        );
      } else {
        throw Exception('Image bytes == null');
      }
    } catch (e, s) {
      _showError(e, s, errorMsg: 'Take screenshot error');
    }
  }

  Future<void> _startVideoRecording() async {
    if (value.videosLimitReached) {
      const msg = 'Video files limit reached (${SnaplyState.maxVideosNumber})';
      _uiEventsController.add(PlainInfo(msg));
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
      final path = await _mediaManager.stopVideoRecording();
      if (path == null) throw Exception('Video output path is null');

      // As we'll trigger ViewingReport stage we need to add extra files
      await _addExtraFiles();
      SnaplyReporter.instance.log(message: DefaultLogs.screenVideoFinished);
      _uiEventsController.add(PlainInfo.short('Screen video taken'));
      value = value.copyWith(
        controlsState: ControlsState.invisible,
        mediaFiles: [
          ...value.mediaFiles,
          ScreenVideoFile(
            filePath: path,
            startedAt: _videoStartedAt ?? DateTime.timestamp(),
            endedAt: DateTime.timestamp(),
          ),
        ],
        reportingStage: ViewingReport(),
      );
    } catch (e, s) {
      value = value.copyWith(controlsState: ControlsState.idle);
      _showError(e, s, errorMsg: 'Stop recording error');
    } finally {
      _resetVideoState();
    }
  }

  void _resetVideoState() {
    _videoStartedAt = null;
    _videoProgressTimer?.cancel();
    _videoProgressTimer = null;
    _videoProgressSec = 0;
  }

  Future<void> _addExtraFiles() async {
    try {
      final files = await _extraFilesRepository.getExtraFiles(
        reportAttrs: value.reportAttrs,
      );
      value = value.copyWith(extraFiles: files);
    } catch (e, s) {
      _showError(e, s, errorMsg: 'Build attributes error');
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
      await _addExtraFiles();
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
