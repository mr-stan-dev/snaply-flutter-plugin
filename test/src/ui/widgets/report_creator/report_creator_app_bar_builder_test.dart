import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snaply/src/ui/state/reporting_stage.dart';
import 'package:snaply/src/ui/state/snaply_state.dart';
import 'package:snaply/src/ui/widgets/report_creator/report_creator_app_bar_builder.dart';

void main() {
  Future<void> pumpAppBar(
    WidgetTester tester,
    SnaplyState state,
  ) async {
    final widget = MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          appBar: ReportCreatorAppBarBuilder.build(context, state),
        ),
      ),
    );

    await tester.pumpWidget(widget);
  }

  group('ReportCreatorAppBarBuilder', () {
    testWidgets('shows correct title for viewing report state', (tester) async {
      final state = SnaplyState.initial().copyWith(
        reportingStage: ViewingReport(),
      );

      await pumpAppBar(tester, state);

      expect(find.text('New report'), findsOneWidget);
      expect(find.text('Discard'), findsOneWidget);
    });

    testWidgets('shows correct title for viewing files state', (tester) async {
      final state = SnaplyState.initial().copyWith(
        reportingStage: const ViewingFiles(isMediaFiles: true, index: 0),
      );

      await pumpAppBar(tester, state);

      expect(find.text('Report media files'), findsOneWidget);
      expect(find.text('Back'), findsOneWidget);
    });

    testWidgets('shows no app bar in gathering state', (tester) async {
      final state = SnaplyState.initial().copyWith(
        reportingStage: Gathering(),
      );

      await pumpAppBar(tester, state);

      expect(find.byType(AppBar), findsNothing);
    });
  });
}
