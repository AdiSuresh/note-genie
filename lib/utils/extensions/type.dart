extension RouteExtension on Type {
  String asRouteName() {
    final regex = RegExp(
      '[A-Z]+[a-z_0-9]*',
    );
    final string = toString().replaceAllMapped(
      regex,
      (match) {
        return '-${match.group(0)!.toLowerCase()}';
      },
    );
    return string.startsWith('-') ? string.substring(1) : string;
  }

  String asRoutePath() {
    return '/${asRouteName()}';
  }
}
