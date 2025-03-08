extension ListX<T> on List<T> {
  /// Maps each element along with its index to a new value.
  ///
  /// Similar to [map], but also provides the index of each element.
  ///
  /// Example:
  /// ```dart
  /// final list = ['a', 'b', 'c'];
  /// final result = list.mapIndexed((index, item) => '$index: $item');
  /// print(result); // ['0: a', '1: b', '2: c']
  /// ```
  List<R> mapIndexed<R>(R Function(int index, T item) convert) {
    return List.generate(
      length,
      (index) => convert(index, this[index]),
    );
  }

  /// Filters out null values from the list.
  ///
  /// Example:
  /// ```dart
  /// final list = ['a', null, 'b', null, 'c'];
  /// final result = list.whereNotNull();
  /// print(result); // ['a', 'b', 'c']
  /// ```
  List<T2> whereNotNull<T2>() => where((e) => e != null).cast<T2>().toList();
}
