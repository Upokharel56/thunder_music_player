import 'dart:io';
import 'package:audiotagger/audiotagger.dart';
import 'package:audiotagger/models/tag.dart';
import '../utils/loggers.dart';

class LrcHelper {
  final Audiotagger _tagger = Audiotagger();
  // final MusicController controller = Get.find<MusicController>();

  /// Initializes LRC by retrieving external and internal lyrics.
  Future<Map<String, String?>> initLrc({required String realPath}) async {
    if (realPath.isEmpty) {
      return _getEmptyLyricsResult();
    }

    try {
      final lyricsResult = await grabLyrics(realPath: realPath);

      return lyricsResult;
    } catch (e, stackTrace) {
      err(
        "Error initializing LRC for URI: $realPath : $e",
        tag: 'LrcHelper',
        stackTrace: stackTrace,
      );
      return {
        'external': null,
        'internal': null,
      };
    }
  }

  /// Retrieves external and internal lyrics.
  Future<Map<String, String?>> grabLyrics({required String realPath}) async {
    final internalLyrics = await _getInternalLyrics(realPath);

    final externalLyrics = await _getExternalLyrics(realPath);

    return {
      'external': externalLyrics,
      'internal': internalLyrics,
    };
  }

  /// Retrieves internal lyrics from metadata.
  Future<String?> _getInternalLyrics(String filePath) async {
    try {
      Tag? tag = await _tagger.readTags(path: filePath);

      if (tag?.lyrics?.isNotEmpty == true) {
        return tag!.lyrics;
      } else {
        return null;
      }
    } catch (e, stackTrace) {
      err(
        "Error retrieving embedded lyrics from metadata: $e",
        tag: 'LrcHelper',
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Retrieves external lyrics from files.
  Future<String?> _getExternalLyrics(String filePath) async {
    try {
      final songFile = File(filePath);
      final songDirectory = songFile.parent;
      final baseName = songFile.uri.pathSegments.last.split('.').first;
      final possibleExtensions = ['lrc', 'srt'];

      for (var ext in possibleExtensions) {
        final lyricsFile = File('${songDirectory.path}/$baseName.$ext');

        if (await lyricsFile.exists()) {
          final content = await lyricsFile.readAsString();
          if (content.isNotEmpty) {
            return content;
          }
        }
      }
      return null;
    } catch (e, stackTrace) {
      err("Error accessing external lyrics file: $e",
          tag: 'LrcHelper', stackTrace: stackTrace);
      return null;
    }
  }

  /// Returns an empty lyrics result.
  Map<String, String?> _getEmptyLyricsResult() {
    return {
      'external': null,
      'internal': null,
    };
  }

  /// Validates LRC content.
  // bool isValidLrc(String? lyricsContent) {
  //   try {
  //     if (lyricsContent == null || lyricsContent.isEmpty) {
  //       msg("Lyrics content is empty or null", tag: 'LrcHelper');
  //       return false;
  //     }
  //     bool isValid = Lrc.isValid(lyricsContent);
  //     msg("Lyrics content validation result: $isValid", tag: 'LrcHelper');
  //     return isValid;
  //   } catch (e, stackTrace) {
  //     err("Error validating LRC content: $e",
  //         tag: 'LrcHelper', stackTrace: stackTrace);
  //     return false;
  //   }
  // }
  String cleanLrc(String rawLrc, {bool cleanBlankLines = false}) {
    // Regular expression to match LRC lines with timestamps and lyrics
    final RegExp lrcLineRegExp =
        RegExp(r'^\[\d{2}:\d{2}\.\d{2}\].*$', multiLine: true);

    // Find all matches in the raw LRC content
    final Iterable<Match> matches = lrcLineRegExp.allMatches(rawLrc);

    // Extract the matched lines
    final List<String> matchedLines =
        matches.map((match) => match.group(0)!).toList();

    // If cleanBlankLines is true, remove lines that only contain timestamps
    if (cleanBlankLines) {
      matchedLines.removeWhere(
          (line) => RegExp(r'^\[\d{2}:\d{2}\.\d{2}\]\s*$').hasMatch(line));
    }

    // Join the matched lines with newline characters
    final String cleanedLrc = matchedLines.join('\n');

    return cleanedLrc;
  }

  bool isValidLrc(String input) => RegExp(
          r'^([\r\n]*\[((ti)|(a[rlu])|(by)|([rv]e)|(length)|(offset)|(la)):.+\][\r\n]*)*([\r\n]*\[\d\d:\d\d\.\d\d\].*){2,}[\r\n]*$')
      .hasMatch(input.trim());
}
