# Snaply

⚠️ This plugin is in alpha stage and its API may change. ⚠️

A Flutter plugin that enables instant bug reports sharing with screenshots, screen recordings, attributes, and logs.

Designed for developers and QA engineers to enhance debugging and testing processes.

[![License: Apache-2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

## Features

* 📸 Screenshots capturing
* 🎥 Screen recording
* 📱 Device & System information collection
* 📝 Custom attributes support
* 📊 Event logging
* 📁 Share all data as an archive or individual files

## Demo

<div align="center">
  <video src="https://github.com/user-attachments/assets/fa8eb690-fbb6-4e30-866f-2b1fd641c49a"></video>
</div>

## Quick Start

1. Add to your `pubspec.yaml`:

```yaml  
dependencies:
  snaply: ^0.0.1-alpha.3  
```  

2. Wrap your App with SnaplyApp:
```dart  
void main() {
  const myApp = MyApp();
  // Enable Snaply based on your build configuration
  const isSnaplyEnabled = true;
  if (isSnaplyEnabled) {
    SnaplyReporter.instance.init();
    runApp(const SnaplyApp(child: myApp));
  } else {
    runApp(myApp);
  }
}
```

## How to

### Control Visibility

The report button is visible by default. To show or hide it, use:

```dart  
SnaplyReporter.instance.setVisibility(false);
```  

### Add Custom Attributes

While Snaply automatically collects device & system attributes, you can add custom attributes:

```dart  
 SnaplyReporter.instance.setAttributes(
    {
      'app_version': '0.0.1',
      'locale': 'en_US',
    },
  );
```  

### Add Logs

Snaply includes basic internal logs by default. To capture additional logs, add this to your app's logger:

```dart  
SnaplyReporter.instance.log(message: 'Onboarding finished'); 
```

## Platform Specifics

### Android Screen Recording

**Frame Sequence Mode (Default):**

This mode creates an MP4 video from captured frames. No additional permissions are required, but there are some limitations:
1. Only captures Flutter App UI (system UI elements & native views are not included)
2. May show minor UI glitches
3. Provides acceptable but not optimal quality

**Media Projection Mode:**

Enable this mode by setting:
  ```bash  
--dart-define=SNAPLY_CONFIG=useAndroidMediaProjection
```  
This mode uses Android MediaProjection API. Snaply will add required permissions to `AndroidManifest.xml` automatically. With this mode you'll have:
1. Complete screen capture including system UI and native views
2. Higher video quality

Permissions to be added by Snaply if you set `useAndroidMediaProjection` flag:

```xml  
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />  
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PROJECTION" />   
```

Best Practice: Use media projection mode only for development/testing builds, not for Google Play releases, unless these permissions are already part of your app.

⚠️ **WARNING!** ⚠️ If you send a build with `useAndroidMediaProjection` flag to GooglePlay - it might not pass App review and Google will ask to explain why you need screen recording permissions.

### iOS Screen Recording

Uses ReplayKit to capture the Flutter App UI only. Like Android, system UI & native views are not included.

Note: The `useAndroidMediaProjection` flag has no effect on iOS

### Android Screenshots

Currently limited to Flutter App UI capture only (system UI elements & native views are not included)

### iOS Screenshots

Uses UIKit for screenshots, capturing only Flutter App UI (system UI elements & native views are not included)

## Requirements

- **Flutter:** >=3.0.0
- **iOS:** 11.0 or newer
- **Android:** API Level 23 or newer

## Additional information

* [Example](https://github.com/mr-stan-dev/snaply-flutter-plugin/tree/main/example)
* [Bug/Issue Tracker](https://github.com/mr-stan-dev/snaply-flutter-plugin/issues)

## License

Apache License 2.0 - see [LICENSE](LICENSE) for details
