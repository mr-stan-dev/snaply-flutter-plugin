import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snaply/src/ui/state/snaply_state.dart';
import 'package:snaply/src/ui/widgets/control_buttons/take_screenshot_button.dart';

void main() {
  Future<void> pumpTakeScreenshotButton(
    WidgetTester tester,
    int screenshotsTaken,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TakeScreenshotButton(screenshotsTaken: screenshotsTaken),
        ),
      ),
    );
  }

  group('TakeScreenshotButton', () {
    testWidgets('renders without badge when no screenshots taken',
        (tester) async {
      await pumpTakeScreenshotButton(tester, 0);

      expect(find.byIcon(Icons.photo_camera_rounded), findsOneWidget);
      expect(find.byType(Badge), findsNothing);
    });

    testWidgets('shows badge with count when screenshots taken',
        (tester) async {
      await pumpTakeScreenshotButton(tester, 2);

      expect(find.byType(Badge), findsOneWidget);
      expect(
          find.text('2/${SnaplyState.maxScreenshotsNumber}'), findsOneWidget);
    });
  });
}
