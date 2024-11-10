import 'package:flutter/material.dart';

class SnackbarPlainInfo extends StatelessWidget {
  const SnackbarPlainInfo({
    required this.infoMsg,
    super.key,
  });

  final String infoMsg;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.lightBlueAccent.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            infoMsg,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ),
    );
  }
}
