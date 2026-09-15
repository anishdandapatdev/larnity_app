import 'package:logger/logger.dart';

class Log {
  Log._internal() {
    _logger = Logger(
      printer: PrettyPrinter(),
    );
  }
  late Logger _logger;
  static const lineLength = 120;

  static final Log _singleton = Log._internal();

  static void verbose(String message, {StackTrace? stackTrace}) =>
      _singleton._logger.t(message, stackTrace: stackTrace);

  static void debug(String message) => _singleton._logger.d(message);

  static void info(String message) => _singleton._logger.i(message);

  static void error(String message, {StackTrace? stackTrace}) =>
      _singleton._logger.e(message, stackTrace: stackTrace);

  static void warning(String message) => _singleton._logger.w(message);
}
