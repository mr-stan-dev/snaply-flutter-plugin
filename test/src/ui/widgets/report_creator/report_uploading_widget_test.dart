import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snaply/src/ui/state/reporting_stage.dart';
import 'package:snaply/src/ui/widgets/report_creator/report_uploading_widget.dart';

void main() {
  Future<void> pumpUploadingWidget(WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ReportLoadingWidget(
            loading: Loading.preparing,
          ),
        ),
      ),
    );
  }

  group('ReportUploadingWidget', () {
    testWidgets('shows loading indicator and message', (tester) async {
      await pumpUploadingWidget(tester);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Preparing report data'), findsOneWidget);
    });

    testWidgets('centers content vertically', (tester) async {
      await pumpUploadingWidget(tester);

      expect(find.byType(Center), findsOneWidget);
      expect(
        tester.widget<Column>(find.byType(Column)).mainAxisAlignment,
        MainAxisAlignment.center,
      );
    });
  });
}
