import 'package:flutter/material.dart';

class SnackbarErrorMessage extends StatelessWidget {
  const SnackbarErrorMessage({
    required this.errorMsg,
    super.key,
  });

  final String errorMsg;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.redAccent.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Oops, something went wrong',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  errorMsg,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
