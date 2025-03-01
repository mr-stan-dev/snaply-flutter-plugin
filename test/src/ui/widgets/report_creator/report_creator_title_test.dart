import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snaply/src/ui/state/snaply_state.dart';
import 'package:snaply/src/ui/widgets/report_creator/report_creator_title.dart';

void main() {
  Future<void> pumpTitleWidget(
    WidgetTester tester,
    SnaplyState state,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReportCreatorTitle(state: state),
        ),
      ),
    );
  }

  group('ReportCreatorTitle', () {
    testWidgets('shows title label and input field', (tester) async {
      await pumpTitleWidget(tester, SnaplyState.initial);

      expect(find.text('Title'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('displays existing title in input field', (tester) async {
      const title = 'Test Report';
      final state = SnaplyState.initial.copyWith(fileName: title);

      await pumpTitleWidget(tester, state);

      expect(find.text(title), findsOneWidget);
    });

    testWidgets('shows hint text when empty', (tester) async {
      await pumpTitleWidget(tester, SnaplyState.initial);

      expect(find.text('Enter report title'), findsOneWidget);
    });
  });
}
