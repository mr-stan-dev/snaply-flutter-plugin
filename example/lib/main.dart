import 'package:flutter/material.dart';
import 'package:snaply/snaply.dart';
import 'package:snaply_example/app/example_app.dart';

void main() {
  const exampleApp = ExampleApp();
  // Enable Snaply based on your build configuration
  const isSnaplyEnabled = true;
  if (isSnaplyEnabled) {
    SnaplyReporter.instance.registerCallbacks(
      onReportReview: () async {
        SnaplyReporter.instance.setAttributes(
          attrKey: 'app_info',
          attrMap: {
            'version': '0.0.1',
          },
        );
      },
    );
    runApp(
      const SnaplyApp(
        child: exampleApp,
      ),
    );
  } else {
    runApp(exampleApp);
  }
}
