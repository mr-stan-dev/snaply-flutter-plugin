import 'package:flutter/material.dart';

class ReportUploadingWidget extends StatelessWidget {
  const ReportUploadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Uploading report',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            )
          ],
        ),
      ),
    );
  }
}
