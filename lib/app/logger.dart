import 'package:logger/logger.dart';

class AppLogger extends Logger {
  AppLogger([
    Type? type,
  ]) : super(
          printer: AppLogPrinter(
            '[${type == null ? 'Unknown' : type.toString()}]',
          ),
        );
}

class AppLogPrinter extends LogPrinter {
  final String className;

  AppLogPrinter(
    this.className,
  );

  @override
  List<String> log(LogEvent event) {
    final color = PrettyPrinter.defaultLevelColors[event.level];
    final message = event.message;
    return [color!('$className: $message')];
  }
}
