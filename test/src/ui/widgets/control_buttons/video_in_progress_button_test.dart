import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snaply/src/ui/widgets/control_buttons/video_in_progress_button.dart';

void main() {
  Future<void> pumpVideoInProgressButton(
    WidgetTester tester,
    double videoProgress,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: VideoInProgressButton(videoProgress: videoProgress),
        ),
      ),
    );
  }

  group('VideoInProgressButton', () {
    testWidgets('renders progress indicator and stop icon', (tester) async {
      await pumpVideoInProgressButton(tester, 0.5);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.stop_rounded), findsOneWidget);
    });

    testWidgets('shows correct progress value', (tester) async {
      const progress = 0.7;
      await pumpVideoInProgressButton(tester, progress);

      final indicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(indicator.value, progress);
    });
  });
}
