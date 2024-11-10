package dev.snaply.flutter_android.files

import androidx.core.content.FileProvider

// This empty files works as a workaround to avoid conflicts in manifest
// merging process between snaply plugin and consumer main application
class SnaplyFileProvider : FileProvider()