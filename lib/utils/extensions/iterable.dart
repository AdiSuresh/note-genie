extension BooleanIterableExtension on Iterable<bool> {
  bool or() {
    return any(
      (element) => element,
    );
  }

  bool and() {
    return every(
      (e) => e,
    );
  }

  bool xor() {
    return fold(
      false,
      (previousValue, element) => previousValue ^ element,
    );
  }
}
