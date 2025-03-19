import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snaply/src/ui/state/reporting_stage.dart';
import 'package:snaply/src/ui/state/snaply_state.dart';
import 'package:snaply/src/ui/widgets/report_creator/report_creator_layout.dart';
import 'package:snaply/src/ui/widgets/report_creator/report_reviewing_widget.dart';
import 'package:snaply/src/ui/widgets/report_creator/report_uploading_widget.dart';

void main() {
  Future<void> pumpLayout(
    WidgetTester tester,
    SnaplyState state,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ReportCreatorLayout(state: state),
      ),
    );
  }

  group('ReportCreatorLayout', () {
    testWidgets('shows nothing in gathering state', (tester) async {
      final state = SnaplyState.initial().copyWith(
        reportingStage: Gathering(),
      );

      await pumpLayout(tester, state);

      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('shows reviewing widget in viewing report state',
        (tester) async {
      final state = SnaplyState.initial().copyWith(
        reportingStage: ViewingReport(),
      );

      await pumpLayout(tester, state);

      expect(find.byType(ReportReviewingWidget), findsOneWidget);
    });

    testWidgets('shows uploading widget in loading state', (tester) async {
      final state = SnaplyState.initial().copyWith(
        reportingStage: Loading.preparing,
      );

      await pumpLayout(tester, state);

      expect(find.byType(ReportLoadingWidget), findsOneWidget);
    });
  });
}
