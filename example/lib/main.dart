import 'package:flutter/material.dart';
import 'package:snaply/snaply.dart';
import 'package:snaply_example/app/example_app.dart';

void main() {
  const exampleApp = ExampleApp();
  if (SnaplyReporter.isEnabled) {
    SnaplyReporter.instance.setVisibility(true);
    runApp(const SnaplyApp(child: exampleApp));
  } else {
    runApp(exampleApp);
  }
}
