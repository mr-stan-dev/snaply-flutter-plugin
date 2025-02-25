
# Snaply

⚠️ This plugin is still in alpha so API might change. ⚠️

A Flutter plugin for instant bug reports sharing with screenshots, screen recordings, attributes and logs.

Intended to be used by developers and QA engineers in builds for debugging & testing.

[![License: Apache-2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

## Features

* 📸 Screenshots capturing
* 🎥 Screen recording
* 📱 Device & System information collection
* 📝 Custom attributes support
* 📊 Event logging
* 📁 Sharing all these files as archive or separately

## Demo

<div align="center">
  <video src="https://github.com/user-attachments/assets/fa8eb690-fbb6-4e30-866f-2b1fd641c49a" />
</div>



## Quick Start

1. Add to your `pubspec.yaml`:

```yaml  
dependencies:
  snaply: ^0.0.1-alpha.2  
```  

2. Simply wrap your App with SnaplyApp:
```dart  
void main() {
  const myApp = MyApp();
  SnaplyReporter.instance.isEnabled = true;
  if (SnaplyReporter.instance.isEnabled) {
    runApp(const SnaplyApp(child: myApp));
  } else {
    runApp(myApp);
  }
}
```

## How to

### Set visibility

By default report button is visible. If you need it to show/hide - use this method:

```dart  
SnaplyReporter.instance.setVisibility(false);
```  

### Set custom attributes

By default Snaply gathers device & system attributes. But you can also add your custom attributes:

```dart  
 SnaplyReporter.instance.setAttributes(
    {
      'app_version': '0.0.1',
      'locale': 'en_US',
    },
  );
```  

### Add logs

By default Snaply adds only few internal logs. If you want to have all logs - call this in your App's logger:

```dart  
SnaplyReporter.instance.log(message: 'Onboarding finished'); 
```

## Platform specifics

### Android screen recording

**- Frame sequence mode:**

By default Snaply plugin is using this mode to build mp4 video file from a bunch of taken frames. This approach has doesn't require any extra permissions but has some drawbacks:
1. Records only your Flutter App's UI (all system UI elements & native views will be invisible)
2. You might see some minor UI glitches
3. Quality is not very high, but acceptable

**- Media projection mode:**

If you set the next flag:
  ```bash  
--dart-define=SNAPLY_CONFIG=useAndroidMediaProjection
```  
Snaply will add required permissions to `AndroidManifest.xml` and will use MediaProjection API for screen recording. This will have the next benefits:
1. All the elements on the screen(System UI, native views) will be visible. It can even record other apps
2. Good video quality
3. Generally, size of the file is smaller

Permissions to be added by Snaply if you set `useAndroidMediaProjection` flag:

```xml  
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />  
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PROJECTION" />   
```

As a general rule of thumb - always use media projection mode for builds you **do not ship** to GooglePlay. Or if you already have these permissions in your `AndroidManifest.xml`. Otherwise - use frame sequence mode

⚠️ **WARNING!** ⚠️ If you send a build with `useAndroidMediaProjection` flag to GooglePlay - it might not pass App review and Google will ask to explain why you need screen recording permissions.

### iOS screen recording

iOS uses ReplayKit to record your App's screen. It takes only your Flutter App's UI. The same as on Android it means that system UI & native views will be invisible.

Note: `useAndroidMediaProjection` is being ignored on iOS platform

### Android screenshots

Similar to frame sequence recording at the moment there are some limitations. It takes only your Flutter App's UI (system UI elements & native views will be invisible)

### iOS screenshots

iOS uses UIKit to take screenshots. The same as on Android system UI elements & native views will be invisible

## Requirements

- **Flutter:** >=3.0.0
- **iOS:** 11.0 or newer
- **Android:** API Level 23 or newer

## Additional information

* [Example](https://github.com/mr-stan-dev/snaply-flutter-plugin/tree/main/example)
* [Bug/Issue Tracker](https://github.com/mr-stan-dev/snaply-flutter-plugin/issues)

## License

Apache License 2.0 - see [LICENSE](LICENSE) for details
