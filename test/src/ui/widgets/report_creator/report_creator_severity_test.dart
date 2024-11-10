import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:snaply/src/entities/severity.dart';
import 'package:snaply/src/ui/state/snaply_state.dart';
import 'package:snaply/src/ui/state/snaply_state_action.dart';
import 'package:snaply/src/ui/state/snaply_state_provider.dart';
import 'package:snaply/src/ui/widgets/report_creator/report_creator_severity.dart';

class MockSnaplyStateProvider extends Mock implements SnaplyStateProvider {
  @override
  String toString({DiagnosticLevel? minLevel}) => super.toString();
}

void main() {
  late MockSnaplyStateProvider stateProvider;

  setUp(() {
    stateProvider = MockSnaplyStateProvider();
  });

  Future<void> pumpSeverityWidget(
    WidgetTester tester,
    SnaplyState state,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SnaplyStateProvider(
            onAction: (action) => stateProvider.act(action),
            child: ReportCreatorSeverity(state: state),
          ),
        ),
      ),
    );
  }

  group('ReportCreatorSeverity', () {
    testWidgets('shows all severity options with correct colors',
        (tester) async {
      await pumpSeverityWidget(tester, SnaplyState.initial);

      for (final severity in Severity.values) {
        final button = find.text(severity.name);
        expect(button, findsOneWidget);

        final text = tester.widget<Text>(button);
        final expectedColor = switch (severity) {
          Severity.low => Colors.green,
          Severity.medium => Colors.orange,
          Severity.high => Colors.red,
        };
        expect(text.style?.color, expectedColor);
      }
    });

    testWidgets('calls act with correct severity when segment selected',
        (tester) async {
      await pumpSeverityWidget(tester, SnaplyState.initial);

      await tester.tap(find.text('high'));
      verify(() => stateProvider.act(SetSeverity(severity: Severity.high)))
          .called(1);

      await tester.tap(find.text('low'));
      verify(() => stateProvider.act(SetSeverity(severity: Severity.low)))
          .called(1);
    });

    testWidgets('shows current severity as selected', (tester) async {
      final state = SnaplyState.initial.copyWith(severity: Severity.high);
      await pumpSeverityWidget(tester, state);

      final segmentedButton = tester.widget<SegmentedButton<Severity>>(
          find.byType(SegmentedButton<Severity>));
      expect(segmentedButton.selected, {Severity.high});
    });
  });
}
