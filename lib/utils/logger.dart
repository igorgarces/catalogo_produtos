import 'package:logging/logging.dart';

class AppLogger {
  static final Logger _logger = Logger('CatalogoApp');

  static void initialize() {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      print('${record.level.name}: ${record.time}: ${record.message}');
    });
  }

  static void debug(String message) {
    _logger.fine(message);
  }

  static void info(String message) {
    _logger.info(message);
  }

  static void warning(String message) {
    _logger.warning(message);
  }

  static void error(String message, [Object? error]) {
    _logger.severe('$message ${error ?? ''}');
  }
}