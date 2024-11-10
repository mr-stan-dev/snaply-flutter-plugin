class CustomAttributesHolder {
  CustomAttributesHolder._();

  static final CustomAttributesHolder _instance = CustomAttributesHolder._();

  static CustomAttributesHolder get instance => _instance;

  final Map<String, String> _attributes = {};

  Map<String, Map<String, String>> get attributes => _attributes.isEmpty
      ? {}
      : {
          'custom_attrs': _attributes,
        };

  void addAttributes(Map<String, String> customAttributes) {
    _attributes.addAll(customAttributes);
  }
}
