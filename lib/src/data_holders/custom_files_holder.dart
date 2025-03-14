class CustomFilesHolder {
  CustomFilesHolder._();

  static final CustomFilesHolder _instance = CustomFilesHolder._();

  static CustomFilesHolder get instance => _instance;

  static const maxFilesSize = 5 * 1024 * 1024; // Max 5MB for file

  static const maxFiles = 5; // Max 5 custom files in report

  final Map<String, String> _customFiles = {};

  Map<String, String> get customFiles => _customFiles;

  void addCustomFile({
    required String key,
    required String path,
  }) {
    // Add if we have space or if updating existing key
    if (_customFiles.length < maxFiles || _customFiles.containsKey(key)) {
      _customFiles[key] = path;
    }
  }
}
