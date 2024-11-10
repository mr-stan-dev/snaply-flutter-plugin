# Snaply

A Flutter plugin for instant bug reports sharing with screenshots, screen recordings, attributes and logs.

Intended to be used by developers and QA engineers in builds for testing.

[![License: Apache-2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

## Features

* 📸 Screenshot capture (with native views)
* 🎥 Screen recording (with native views)
* 📱 Device & System information collection
* 📝 Custom attributes support
* 📊 Event logging
* 🌐 Cross-platform support (iOS & Android)

## Quick Start

1. Add to your `pubspec.yaml`:

```yaml
dependencies:
  snaply: ^0.0.1-alpha.1
```

2. Enable Snaply by adding the dart define flag locally or/and in CI:
```bash
--dart-define=SNAPLY_ENABLED=true
```
⚠️ **IMPORTANT:**
Do not enable Snaply in builds you want to publish to Google Play!
Google Play may reject your app due to screen recording permissions Snaply adds to your app.

3. Simply wrap your App with SnaplyApp:
```dart
void main() {
  const myApp = MyApp();
  if (SnaplyReporter.isEnabled) {
    SnaplyReporter.instance.setVisibility(true);
    runApp(const SnaplyApp(child: myApp));
  } else {
    runApp(myApp);
  }
}
```

## How to use (examples)

1. Set visibility for Snaply controls

```dart
void showSnaplyReporter() {
  SnaplyReporter.instance.setVisibility(true);
}
```

2. Set custom attributes

```dart
void setSnaplyAttributes() {
  SnaplyReporter.instance.setAttributes(
    {
      'app_version' : '0.0.1',
      'locale': 'en_US',
    },
  );
}
```

2. Add logs

```dart
void addSnaplyLog() {
  SnaplyReporter.instance.log(message: 'Onboarding finished');
}
```

## Platform Support

| Platform | Support  |
|----------|----------|
| Android  | ✅       |
| iOS      | ✅       |

## Requirements

- **Flutter:** >=3.0.0
- **iOS:** 11.0 or newer
- **Android:** API Level 23 or newer

## Additional information

* [Documentation](https://snaply.dev/docs)
* [Examples](https://github.com/mr-stan-dev/snaply-flutter-plugin/tree/main/example)
* [Bug/Issue Tracker](https://github.com/mr-stan-dev/snaply-flutter-plugin/issues)

## License

Apache License 2.0 - see [LICENSE](LICENSE) for details

