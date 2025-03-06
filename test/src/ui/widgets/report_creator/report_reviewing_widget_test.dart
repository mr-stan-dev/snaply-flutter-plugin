import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snaply/src/ui/state/snaply_state.dart';
import 'package:snaply/src/ui/widgets/report_creator/report_creator_action_buttons.dart';
import 'package:snaply/src/ui/widgets/report_creator/report_creator_severity.dart';
import 'package:snaply/src/ui/widgets/report_creator/report_creator_title.dart';
import 'package:snaply/src/ui/widgets/report_creator/report_reviewing_widget.dart';

void main() {
  Future<void> pumpReportReviewingWidget(
    WidgetTester tester,
    SnaplyState state,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReportReviewingWidget(state: state),
        ),
      ),
    );
  }

  group('ReportReviewingWidget', () {
    testWidgets('renders all required components', (tester) async {
      final state = SnaplyState.initial();

      await pumpReportReviewingWidget(tester, state);

      expect(find.byType(ReportCreatorTitle), findsOneWidget);
      expect(find.byType(ReportCreatorSeverity), findsOneWidget);
      expect(find.byType(ReportCreatorActionButtons), findsOneWidget);
    });

    testWidgets('shows dividers between sections', (tester) async {
      await pumpReportReviewingWidget(tester, SnaplyState.initial());

      expect(find.byType(Divider), findsNWidgets(3));
    });
  });
}
