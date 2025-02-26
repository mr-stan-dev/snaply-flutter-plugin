import 'package:flutter/material.dart';
import 'package:snaply/snaply.dart';
import 'package:snaply_example/app/example_app.dart';

void main() {
  const exampleApp = ExampleApp();
  // Enable Snaply based on your build configuration
  const isSnaplyEnabled = true;
  if (isSnaplyEnabled) {
    SnaplyReporter.instance.init();
    runApp(const SnaplyApp(child: exampleApp));
  } else {
    runApp(exampleApp);
  }
}
