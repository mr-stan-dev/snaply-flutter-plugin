import 'package:flutter/foundation.dart';

mixin NotifierLoggingMixin<T> on ValueNotifier<T> {
  @override
  set value(T newValue) {
    debugPrint('[$runtimeType] newValue: $newValue');
    super.value = newValue;
  }
}
