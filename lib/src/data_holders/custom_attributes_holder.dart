class CustomAttributesHolder {
  CustomAttributesHolder._();

  static final CustomAttributesHolder _instance = CustomAttributesHolder._();

  static CustomAttributesHolder get instance => _instance;

  final Map<String, Map<String, String>> _attributes = {};

  Map<String, Map<String, String>> get attributes => _attributes;

  void addAttributes({
    required String attrKey,
    required Map<String, String> attrMap,
  }) {
    _attributes[attrKey] = attrMap;
  }
}
