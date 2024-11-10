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
}
