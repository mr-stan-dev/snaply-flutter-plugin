import 'package:flutter/material.dart';
import 'package:snaply/src/entities/report_file.dart';
import 'package:snaply/src/ui/state/snaply_state_action.dart';
import 'package:snaply/src/ui/state/snaply_state_provider.dart';

class FullViewLogs extends StatelessWidget {
  const FullViewLogs({
    required this.logsFile,
    super.key,
  });

  final LogsFile logsFile;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text(
                  'Logs',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () => context.act(ShareReportFile(file: logsFile)),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.surfaceContainer,
              child: ListView.builder(
                itemCount: logsFile.logs.length,
                itemBuilder: (context, index) {
                  final log = logsFile.logs[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            log.formattedTime,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 3,
                          child: Text(
                            log.message,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
