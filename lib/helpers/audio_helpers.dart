import 'dart:io';
import 'package:audiotagger/audiotagger.dart';
import 'package:audiotagger/models/tag.dart';
import 'package:lrc/lrc.dart';
import '../platform_channels/android/file_path_helper.dart';
import '../utils/loggers.dart';

class LrcHelper with FilePathResolverMixin {
  final Audiotagger _tagger = Audiotagger();

  Future<Map<String, dynamic>> initLrc(String contentUri) async {
    msg("Initializing LRC for content URI: $contentUri", tag: 'LrcHelper');

    try {
      final lyricsResult = await grabLyrics(contentUri);

      // Check validity of both internal and external lyrics
      lyricsResult['internal']['isSynced'] =
          _isValidLrc(lyricsResult['internal']['lyrics']);
      lyricsResult['external']['isSynced'] =
          _isValidLrc(lyricsResult['external']['fileContent']);

      // Try parsing external lyrics first if available and synced
      if (lyricsResult['external']['hasExternal'] &&
          lyricsResult['external']['isSynced']) {
        try {
          final content = lyricsResult['external']['fileContent'];
          if (content != null && content.isNotEmpty) {
            lyricsResult['external']['synced'] = Lrc.parse(content);
            sucs("External LRC parsed successfully", tag: 'LrcHelper');
          }
        } catch (e, stackTrace) {
          err("Failed to parse external LRC: $e",
              tag: 'LrcHelper', stackTrace: stackTrace);
          lyricsResult['external']['isSynced'] = false;
        }
      }

      // Try parsing internal lyrics if external failed or unavailable
      if ((!lyricsResult['external']['isSynced'] ||
              lyricsResult['external']['synced'] == null) &&
          lyricsResult['internal']['hasInternal'] &&
          lyricsResult['internal']['isSynced']) {
        try {
          final lyrics = lyricsResult['internal']['lyrics'];
          if (lyrics != null && lyrics.isNotEmpty) {
            lyricsResult['internal']['synced'] = Lrc.parse(lyrics);
            sucs("Internal LRC parsed successfully", tag: 'LrcHelper');
          }
        } catch (e, stackTrace) {
          err("Failed to parse internal LRC: $e",
              tag: 'LrcHelper', stackTrace: stackTrace);
          lyricsResult['internal']['isSynced'] = false;
        }
      }

      return lyricsResult;
    } catch (e, stackTrace) {
      err("Error initializing LRC for URI: $contentUri : error is \n $e \n on line ${getErrorLocation(stackTrace)}",
          tag: 'LrcHelper', stackTrace: stackTrace);
      return {
        'external': {
          'hasExternal': false,
          'isSynced': false,
          'synced': null,
          'fileContent': null,
        },
        'internal': {
          'hasInternal': false,
          'isSynced': false,
          'synced': null,
          'lyrics': null,
        },
      };
    }
  }

  Future<Map<String, dynamic>> grabLyrics(String songUri) async {
    msg("Grabbing lyrics for song URI: $songUri", tag: 'LrcHelper');

    String? realPath = await resolveContentUri(songUri);
    if (realPath == null) {
      err("Real path could not be resolved for URI: $songUri",
          tag: 'LrcHelper');
      return _getEmptyLyricsResult();
    }

    final internalLyrics = await _getInternalLyrics(realPath);
    final externalLyrics = await _getExternalLyrics(realPath);

    return {
      'external': externalLyrics,
      'internal': internalLyrics,
    };
  }

  Future<Map<String, dynamic>> _getInternalLyrics(String filePath) async {
    Map<String, dynamic> result = {
      'hasInternal': false,
      'isSynced': false,
      'synced': null,
      'lyrics': null,
    };

    try {
      Tag? tag = await _tagger.readTags(path: filePath);
      if (tag?.lyrics != null && tag!.lyrics!.isNotEmpty) {
        result['hasInternal'] = true;
        result['lyrics'] = tag.lyrics;
        sucs("Embedded lyrics found in metadata", tag: 'LrcHelper');
      }
    } catch (e, stackTrace) {
      err(
        "Error retrieving embedded lyrics from metadata: $e",
        tag: 'LrcHelper',
        stackTrace: stackTrace,
      );
    }

    return result;
  }

  Future<Map<String, dynamic>> _getExternalLyrics(String filePath) async {
    Map<String, dynamic> result = {
      'hasExternal': false,
      'isSynced': false,
      'synced': null,
      'fileContent': null,
    };

    try {
      final songFile = File(filePath);
      final songDirectory = songFile.parent;
      final possibleExtensions = ['lrc', 'srt'];

      for (var ext in possibleExtensions) {
        final lyricsFile = File(
            '${songDirectory.path}/${songFile.uri.pathSegments.last.split('.').first}.$ext');

        if (await lyricsFile.exists()) {
          final content = await lyricsFile.readAsString();
          if (content.isNotEmpty) {
            result['hasExternal'] = true;
            result['fileContent'] = content;
            sucs("External lyrics file found: ${lyricsFile.path}",
                tag: 'LrcHelper');
            break;
          }
        }
      }
    } catch (e, stackTrace) {
      err("Error accessing external lyrics file: $e",
          tag: 'LrcHelper', stackTrace: stackTrace);
    }

    return result;
  }

  Map<String, dynamic> _getEmptyLyricsResult() {
    return {
      'external': {
        'hasExternal': false,
        'isSynced': false,
        'synced': null,
        'fileContent': null,
      },
      'internal': {
        'hasInternal': false,
        'isSynced': false,
        'synced': null,
        'lyrics': null,
      },
    };
  }

  bool _isValidLrc(String? lyricsContent) {
    try {
      if (lyricsContent == null || lyricsContent.isEmpty) {
        msg("Lyrics content is empty or null", tag: 'LrcHelper');
        return false;
      }
      bool isValid = Lrc.isValid(lyricsContent);
      msg("Lyrics content validation result: $isValid", tag: 'LrcHelper');
      return isValid;
    } catch (e, stackTrace) {
      err("Error validating LRC content: $e",
          tag: 'LrcHelper', stackTrace: stackTrace);
      return false;
    }
  }
}
