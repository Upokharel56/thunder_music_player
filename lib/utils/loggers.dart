import 'package:logger/logger.dart';

final _logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 5,
    lineLength: 80,
    colors: true,
    printEmojis: true,
    printTime: true,
  ),
);

// Message/Info logs (blue)
void msg(dynamic message, {String? tag}) {
  _logger.i('${tag != null ? '[$tag] ' : ''}$message');
}

// Success logs (green)
void sucs(dynamic message, {String? tag}) {
  _logger.i('✓ ${tag != null ? '[$tag] ' : ''}$message');
}

// Error logs (red)
void err(dynamic message, {String? tag, StackTrace? stackTrace}) {
  _logger.e('${tag != null ? '[$tag] ' : ''}$message',
      error: null, stackTrace: stackTrace);
}

// Debug logs (for development)
void debug(dynamic message, {String? tag}) {
  _logger.d('${tag != null ? '[$tag] ' : ''}$message');
}

// Add this helper method
String getErrorLocation(StackTrace stackTrace) {
  try {
    final frames = stackTrace.toString().split('\n');
    if (frames.length > 1) {
      // Extract file and line number from stack trace
      final frame = frames[0]; // First frame is usually the error location
      final lineInfo = RegExp(r'\((.+?):(\d+)(?::\d+)\)').firstMatch(frame);
      if (lineInfo != null) {
        return 'at line ${lineInfo.group(2)}';
      }
    }
    return '';
  } catch (e) {
    return '';
  }
}
