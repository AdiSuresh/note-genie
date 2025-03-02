extension BooleanIterableExtension on Iterable<bool> {
  bool or() {
    return any(
      (element) => element,
    );
  }

  bool and() {
    return fold(
      true,
      (previousValue, element) => previousValue && element,
    );
  }

  bool xor() {
    return fold(
      false,
      (previousValue, element) => previousValue ^ element,
    );
  }
}
