import 'package:flutter/material.dart';
import 'package:snaply/src/ui/state/reporting_stage.dart';

class ReportLoadingWidget extends StatelessWidget {
  const ReportLoadingWidget({
    required this.loading,
    super.key,
  });

  final Loading loading;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                loading.loadingMessage,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
