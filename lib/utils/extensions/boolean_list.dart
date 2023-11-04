extension BooleanListExtension on Iterable<bool> {
  bool computeOR() {
    return any(
      (element) => element,
    );
  }

  bool computeAND() {
    return fold(
      true,
      (previousValue, element) => previousValue && element,
    );
  }

  bool computeXOR() {
    return fold(
      false,
      (previousValue, element) => previousValue ^ element,
    );
  }
}
