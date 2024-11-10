import 'package:flutter/material.dart';
import 'package:snaply/src/ui/state/snaply_state_action.dart';
import 'package:snaply/src/ui/state/snaply_state_provider.dart';

class ReportCreatorActionButtons extends StatelessWidget {
  const ReportCreatorActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.secondaryContainer,
                  foregroundColor: colorScheme.onSecondaryContainer,
                ),
                onPressed: () => context.act(ShareReport(asArchive: true)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Share as 1 archive',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSecondaryContainer,
                        ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.secondaryContainer,
                  foregroundColor: colorScheme.onSecondaryContainer,
                ),
                onPressed: () => context.act(ShareReport(asArchive: false)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Share all files',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSecondaryContainer,
                        ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
