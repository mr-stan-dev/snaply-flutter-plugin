import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:snaply/src/data_holders/configuration_holder.dart';
import 'package:snaply/src/entities/report_file.dart';
import 'package:snaply/src/entities/severity.dart';
import 'package:snaply/src/logger/log_record.dart';
import 'package:snaply/src/media_manager/media_files_manager.dart';
import 'package:snaply/src/repository/extra_files_repository.dart';
import 'package:snaply/src/ui/state/info_event.dart';
import 'package:snaply/src/ui/state/reporting_stage.dart';
import 'package:snaply/src/ui/state/snaply_state.dart';
import 'package:snaply/src/ui/state/snaply_state_action.dart';
import 'package:snaply/src/ui/viewmodel/snaply_view_model.dart';
import 'package:snaply/src/usecase/share_files_usecase.dart';

class MockMediaManager extends Mock implements MediaFilesManager {}

class MockShareReportUsecase extends Mock implements ShareFilesUsecase {}

class MockExtraFilesRepository extends Mock implements ExtraFilesRepository {}

class MockConfigurationHolder extends Mock implements ConfigurationHolder {}

void main() {
  late SnaplyViewModel viewModel;
  late MockMediaManager mediaManager;
  late MockShareReportUsecase shareReportUsecase;
  late MockExtraFilesRepository extraFilesRepository;
  late MockConfigurationHolder configurationHolder;
  late List<InfoEvent> uiEvents;

  setUp(() {
    mediaManager = MockMediaManager();
    shareReportUsecase = MockShareReportUsecase();
    extraFilesRepository = MockExtraFilesRepository();
    configurationHolder = MockConfigurationHolder();

    when(
      () => extraFilesRepository.getExtraFiles(
        reportAttrs: any(named: 'reportAttrs'),
      ),
    ).thenAnswer((_) async => <ReportFile>[]);

    viewModel = SnaplyViewModel(
      mediaManager: mediaManager,
      shareReportUsecase: shareReportUsecase,
      extraFilesRepository: extraFilesRepository,
      configurationHolder: configurationHolder,
    );
    uiEvents = [];
    viewModel.uiEventsStream.listen(uiEvents.add);
  });

  // Helper method to wait for events
  Future<void> pumpEvents() async {
    await Future.delayed(Duration.zero, () {});
  }

  group('screenshots', () {
    test('take screenshot success adds file and updates state', () async {
      viewModel.screenshotDelay = Duration.zero;
      const index = 0;
      final screenshotFile = ScreenshotFile(
        filePath: 'filePath',
        createdAt: DateTime.timestamp(),
      );
      when(() => mediaManager.takeScreenshot(index))
          .thenAnswer((_) async => screenshotFile);

      await viewModel.act(TakeScreenshot());
      await pumpEvents();

      expect(viewModel.value.mediaFiles.length, 1);
      expect(viewModel.value.mediaFiles.first, isA<ScreenshotFile>());
      expect(viewModel.value.reportingStage, isA<Gathering>());
      expect(uiEvents.last, isA<PlainInfo>());

      verify(() => mediaManager.takeScreenshot(index)).called(1);
    });

    test('take screenshot error shows error message', () async {
      viewModel.screenshotDelay = Duration.zero;
      when(() => mediaManager.takeScreenshot(viewModel.value.mediaFiles.length))
          .thenThrow(Exception('Screenshot failed'));

      await viewModel.act(TakeScreenshot());
      await pumpEvents();

      expect(viewModel.value.mediaFiles, isEmpty);
      expect(uiEvents.last, isA<ErrorEvent>());
      verify(
        () => mediaManager.takeScreenshot(viewModel.value.mediaFiles.length),
      ).called(1);
    });

    test('screenshots limit prevents taking more', () async {
      // Add max screenshots
      for (var i = 0; i < SnaplyState.maxScreenshotsNumber; i++) {
        viewModel.value = viewModel.value.copyWith(
          mediaFiles: [
            ...viewModel.value.mediaFiles,
            ScreenshotFile(
              filePath: ScreenshotFile.getPath(dirPath: 'dirPath', index: i),
              createdAt: DateTime.now(),
            ),
          ],
        );
      }

      await viewModel.act(TakeScreenshot());
      await pumpEvents();

      verifyNever(
        () => mediaManager.takeScreenshot(viewModel.value.mediaFiles.length),
      );
      expect((uiEvents.last as PlainInfo).infoMsg, contains('limit reached'));
    });
  });

  group('video recording', () {
    test(
        'When media projection enabled '
        'Then start recording calls media manager with media projection true',
        () async {
      const isMediaProjection = true;
      when(
        () => mediaManager.startVideoRecording(
          isMediaProjection: isMediaProjection,
        ),
      ).thenAnswer((_) async => {});
      when(() => configurationHolder.useMediaProjection)
          .thenReturn(isMediaProjection);

      await viewModel.act(StartVideoRecording());

      expect(viewModel.value.controlsState, ControlsState.recordingInProgress);
      verify(
        () => mediaManager.startVideoRecording(
          isMediaProjection: isMediaProjection,
        ),
      ).called(1);
    });

    test(
        'When media projection disabled '
        'Then start recording calls media manager with media projection false',
        () async {
      const isMediaProjection = false;
      when(
        () => mediaManager.startVideoRecording(),
      ).thenAnswer((_) async => {});
      when(() => configurationHolder.useMediaProjection)
          .thenReturn(isMediaProjection);

      await viewModel.act(StartVideoRecording());

      expect(viewModel.value.controlsState, ControlsState.recordingInProgress);
      verify(
        () => mediaManager.startVideoRecording(),
      ).called(1);
    });

    test('stop recording adds video file', () async {
      const path = 'test/video.mp4';
      when(() => mediaManager.stopVideoRecording()).thenAnswer(
        (_) async => ScreenVideoFile(
          filePath: path,
          startedAt: DateTime.timestamp(),
          endedAt: DateTime.timestamp(),
        ),
      );

      await viewModel.act(StopVideoRecording());
      await pumpEvents();

      expect(viewModel.value.mediaFiles.length, 1);
      expect(viewModel.value.mediaFiles.first, isA<ScreenVideoFile>());
      expect(viewModel.value.reportingStage, isA<ViewingReport>());
      expect(uiEvents.last, isA<PlainInfo>());
    });

    test('recording fails shows error message', () async {
      const isMediaProjection = false;
      when(() => configurationHolder.useMediaProjection)
          .thenReturn(isMediaProjection);
      when(
        () => mediaManager.startVideoRecording(
          isMediaProjection: any(named: 'isMediaProjection'),
        ),
      ).thenThrow(Exception('Recording failed'));

      await viewModel.act(StartVideoRecording());
      await pumpEvents();

      expect(
        viewModel.value.controlsState,
        isNot(ControlsState.recordingInProgress),
      );
      expect(uiEvents.last, isA<ErrorEvent>());
      verify(
        () => mediaManager.startVideoRecording(),
      ).called(1);
    });
  });

  group('report sharing', () {
    test('share report calls usecase with all files', () async {
      final file = ScreenshotFile(
        filePath: 'path',
        createdAt: DateTime.timestamp(),
      );

      final extraFiles = [
        LogsFile(
          logs: [LogRecord(message: 'test log', timestamp: DateTime.now())],
        ),
        const AttributesFile(
          attrs: {
            'test': {'key': 'value'},
          },
        ),
      ];

      // Set initial state with title and severity
      viewModel.value = viewModel.value.copyWith(
        reportingStage: ViewingReport(),
        mediaFiles: [file],
        title: 'Test Report',
        severity: Severity.high,
      );

      when(
        () => shareReportUsecase.call(
          reportFiles: any(named: 'reportFiles'),
          asArchive: any(named: 'asArchive'),
        ),
      ).thenAnswer((_) => Future.value());

      when(
        () => extraFilesRepository.getExtraFiles(
          reportAttrs: any(named: 'reportAttrs'),
        ),
      ).thenAnswer((_) async => extraFiles);

      await viewModel.act(ShareReport(asArchive: true));
      await pumpEvents();

      verify(
        () => shareReportUsecase.call(
          reportFiles: [...viewModel.value.mediaFiles, ...extraFiles],
          asArchive: true,
        ),
      ).called(1);
    });

    test('share report file calls usecase with single file', () async {
      final file = ScreenshotFile(
        filePath: 'path',
        createdAt: DateTime.timestamp(),
      );
      when(
        () => shareReportUsecase.call(
          reportFiles: any(named: 'reportFiles'),
          asArchive: any(named: 'asArchive'),
        ),
      ).thenAnswer((_) => Future.value());

      await viewModel.act(ShareReportFile(file: file));

      verify(
        () => shareReportUsecase.call(
          reportFiles: [file],
          asArchive: false,
        ),
      ).called(1);
    });
  });
}
