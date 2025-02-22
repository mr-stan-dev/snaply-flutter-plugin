import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:snaply/src/ui/state/snaply_state_action.dart';
import 'package:snaply/src/ui/state/snaply_state_provider.dart';
import 'package:snaply/src/ui/widgets/report_creator/report_creator_action_buttons.dart';

class MockSnaplyStateProvider extends Mock implements SnaplyStateProvider {
  @override
  String toString({DiagnosticLevel? minLevel}) => super.toString();
}

void main() {
  late MockSnaplyStateProvider stateProvider;

  Future<void> pumpActionButtons(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SnaplyStateProvider(
            onAction: (action) => stateProvider.act(action),
            child: const ReportCreatorActionButtons(),
          ),
        ),
      ),
    );
  }

  setUp(() {
    stateProvider = MockSnaplyStateProvider();
    registerFallbackValue(ShareReport(asArchive: true));
    when(() => stateProvider.act(any())).thenAnswer((_) async {});
  });

  group('ReportCreatorActionButtons', () {
    testWidgets('renders buttons with correct text', (tester) async {
      await pumpActionButtons(tester);

      expect(find.byType(ElevatedButton), findsNWidgets(2));
      expect(find.text('Share as 1 archive'), findsOneWidget);
      expect(find.text('Share all files'), findsOneWidget);
    });

    testWidgets('tapping buttons triggers correct actions', (tester) async {
      await pumpActionButtons(tester);

      await tester.tap(find.text('Share as 1 archive'));
      await tester.pump();
      verify(() => stateProvider.act(ShareReport(asArchive: true))).called(1);

      await tester.tap(find.text('Share all files'));
      await tester.pump();
      verify(() => stateProvider.act(ShareReport(asArchive: false))).called(1);
    });
  });
}
