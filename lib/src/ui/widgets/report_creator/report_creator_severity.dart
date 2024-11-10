import 'package:flutter/material.dart';
import 'package:snaply/src/entities/severity.dart';
import 'package:snaply/src/ui/state/snaply_state.dart';
import 'package:snaply/src/ui/state/snaply_state_action.dart';
import 'package:snaply/src/ui/state/snaply_state_provider.dart';

class ReportCreatorSeverity extends StatelessWidget {
  const ReportCreatorSeverity({
    required this.state,
    super.key,
  });

  final SnaplyState state;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Severity',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: SegmentedButton<Severity>(
                  segments: Severity.values.map((severity) {
                    return ButtonSegment<Severity>(
                      value: severity,
                      label: Text(
                        severity.name,
                        style: TextStyle(
                          color: _severityColor(severity),
                        ),
                      ),
                    );
                  }).toList(),
                  selected: {state.severity},
                  onSelectionChanged: (Set<Severity> selected) {
                    context.act(SetSeverity(severity: selected.first));
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _severityColor(Severity severity) {
    switch (severity) {
      case Severity.low:
        return Colors.green;
      case Severity.medium:
        return Colors.orange;
      case Severity.high:
        return Colors.red;
    }
  }
}
