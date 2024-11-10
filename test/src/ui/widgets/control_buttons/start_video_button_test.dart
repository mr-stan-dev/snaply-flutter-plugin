import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snaply/src/ui/state/snaply_state.dart';
import 'package:snaply/src/ui/widgets/control_buttons/start_video_button.dart';

void main() {
  Future<void> pumpStartVideoButton(
    WidgetTester tester,
    int videosTaken,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StartVideoButton(videosTaken: videosTaken),
        ),
      ),
    );
  }

  group('StartVideoButton', () {
    testWidgets('renders without badge when no videos taken', (tester) async {
      await pumpStartVideoButton(tester, 0);

      expect(find.byIcon(Icons.video_camera_back_rounded), findsOneWidget);
      expect(find.byType(Badge), findsNothing);
    });

    testWidgets('shows badge with count when videos taken', (tester) async {
      await pumpStartVideoButton(tester, 2);

      expect(find.byType(Badge), findsOneWidget);
      expect(find.text('2/${SnaplyState.maxVideosNumber}'), findsOneWidget);
    });
  });
}
