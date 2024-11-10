import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snaply/src/entities/report_file.dart';
import 'package:snaply/src/ui/state/snaply_state.dart';
import 'package:snaply/src/ui/widgets/control_buttons/control_buttons.dart';
import 'package:snaply/src/ui/widgets/control_buttons/start_video_button.dart';
import 'package:snaply/src/ui/widgets/control_buttons/take_screenshot_button.dart';
import 'package:snaply/src/ui/widgets/control_buttons/video_in_progress_button.dart';

void main() {
  Future<void> pumpControlButtons(
    WidgetTester tester,
    SnaplyState state,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ControlButtons(state: state),
        ),
      ),
    );
  }

  group('ControlButtons', () {
    testWidgets('renders idle state correctly', (tester) async {
      final state =
          SnaplyState.initial.copyWith(controlsState: ControlsState.idle);

      await pumpControlButtons(tester, state);

      expect(find.byIcon(Icons.bug_report_rounded), findsOneWidget);
      expect(find.byType(StartVideoButton), findsNothing);
      expect(find.byType(TakeScreenshotButton), findsNothing);
    });

    testWidgets('renders active state with control buttons', (tester) async {
      final state = SnaplyState.initial.copyWith(
        controlsState: ControlsState.active,
      );

      await pumpControlButtons(tester, state);

      expect(find.byType(StartVideoButton), findsOneWidget);
      expect(find.byType(TakeScreenshotButton), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('renders recording state with progress', (tester) async {
      final state = SnaplyState.initial.copyWith(
        controlsState: ControlsState.recordingInProgress,
        screenVideoProgressSec: 10,
      );

      await pumpControlButtons(tester, state);

      expect(find.byType(VideoInProgressButton), findsOneWidget);
      expect(find.byType(StartVideoButton), findsNothing);
      expect(find.byType(TakeScreenshotButton), findsNothing);
    });

    testWidgets('shows check icon when has mediaFiles', (tester) async {
      final state = SnaplyState.initial.copyWith(
        controlsState: ControlsState.active,
        mediaFiles: [
          ScreenVideoFile(
            filePath: 'test.mp4',
            startedAt: DateTime.now(),
            endedAt: DateTime.now(),
          ),
        ],
      );

      await pumpControlButtons(tester, state);

      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('is invisible when state is invisible', (tester) async {
      final state = SnaplyState.initial.copyWith(
        controlsState: ControlsState.invisible,
      );

      await pumpControlButtons(tester, state);

      expect(find.byType(ControlButtons), findsOneWidget);
      expect(find.byType(StartVideoButton), findsNothing);
      expect(find.byType(TakeScreenshotButton), findsNothing);
      expect(find.byIcon(Icons.bug_report), findsNothing);
    });
  });
}
