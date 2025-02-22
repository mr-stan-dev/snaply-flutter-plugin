import 'package:flutter/material.dart';
import 'package:snaply/snaply.dart';
import 'package:snaply_example/app/example_app.dart';

void main() {
  const exampleApp = ExampleApp();
  SnaplyReporter.instance.isEnabled = true;
  if (SnaplyReporter.instance.isEnabled) {
    runApp(const SnaplyApp(child: exampleApp));
  } else {
    runApp(exampleApp);
  }
}
