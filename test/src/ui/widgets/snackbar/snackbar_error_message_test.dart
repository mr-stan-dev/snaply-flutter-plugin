import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snaply/src/ui/widgets/snackbar/snackbar_error_message.dart';

void main() {
  Future<void> pumpErrorMessage(
    WidgetTester tester,
    String errorMsg,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SnackbarErrorMessage(errorMsg: errorMsg),
        ),
      ),
    );
  }

  group('SnackbarErrorMessage', () {
    testWidgets('shows error title and message', (tester) async {
      const errorMsg = 'Test error occurred';
      await pumpErrorMessage(tester, errorMsg);

      expect(find.text('Oops, something went wrong'), findsOneWidget);
      expect(find.text(errorMsg), findsOneWidget);
    });

    testWidgets('uses correct styling', (tester) async {
      await pumpErrorMessage(tester, 'error');

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration! as BoxDecoration;

      expect(decoration.color, Colors.redAccent.shade100);
      expect(decoration.borderRadius, BorderRadius.circular(16));
    });

    testWidgets('handles long error messages', (tester) async {
      const longError =
          'This is a very long error message that should be truncated when '
          'it exceeds the maximum number of lines allowed in the error '
          'message display area';
      await pumpErrorMessage(tester, longError);

      final text = tester.widget<Text>(find.text(longError));
      expect(text.maxLines, 2);
      expect(text.overflow, TextOverflow.ellipsis);
    });
  });
}
