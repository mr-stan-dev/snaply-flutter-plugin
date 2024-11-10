import 'package:flutter/material.dart';
import 'package:snaply/snaply.dart';

class SnaplyControls extends StatelessWidget {
  const SnaplyControls({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(),
        const Text(
          'Snaply Controls',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => SnaplyReporter.instance.setVisibility(true),
                icon: const Icon(Icons.visibility),
                label: const Text('Show'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => SnaplyReporter.instance.setVisibility(false),
                icon: const Icon(Icons.visibility_off),
                label: const Text('Hide'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () {
            try {
              throw Exception('Test error');
            } catch (e) {
              const msg = 'Test error occurred';
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text(msg)),
              );
              SnaplyReporter.instance.log(message: msg);
            }
          },
          icon: const Icon(Icons.bug_report),
          label: const Text('Trigger Test Error'),
        ),
      ],
    );
  }
}
