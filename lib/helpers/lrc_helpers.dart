import 'dart:io';
import 'package:audiotagger/audiotagger.dart';
import 'package:audiotagger/models/tag.dart';
import 'package:get/get.dart';
import 'package:lrc/lrc.dart';
import 'package:thunder_audio_player/controllers/music_controller.dart';
import '../platform_channels/android/file_path_helper.dart';
import '../utils/loggers.dart';

class LrcHelper with FilePathResolverMixin {
  final Audiotagger _tagger = Audiotagger();
  // final MusicController controller = Get.find<MusicController>();

  /// Initializes LRC by retrieving external and internal lyrics.
  Future<Map<String, String?>> initLrc(
      {String contentUri = '', String? realPath}) async {
    msg("Initializing LRC for content URI: $contentUri", tag: 'LrcHelper');

    if (contentUri.isEmpty && realPath == null) {
      err("Content URI is empty", tag: 'LrcHelper');
      return _getEmptyLyricsResult();
    }

    if (realPath == null && contentUri.isNotEmpty) {
      realPath = await resolveContentUri(contentUri);
    }

    try {
      final lyricsResult = await grabLyrics(realPath: realPath);

      // Validate external lyrics
      if (lyricsResult['external'] != null &&
          isValidLrc(lyricsResult['external'])) {
        sucs("External LRC is valid", tag: 'LrcHelper');
      }

      // Validate internal lyrics
      if (lyricsResult['internal'] != null &&
          isValidLrc(lyricsResult['internal'])) {
        sucs("Internal LRC is valid", tag: 'LrcHelper');
      }

      return lyricsResult;
    } catch (e, stackTrace) {
      err(
        "Error initializing LRC for URI: $contentUri : $e",
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
  Future<Map<String, String?>> grabLyrics(
      {String songUri = '', String? realPath}) async {
    msg("Grabbing lyrics for song URI: $songUri", tag: 'LrcHelper');

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

  /// Retrieves internal lyrics from metadata.
  Future<String?> _getInternalLyrics(String filePath) async {
    try {
      Tag? tag = await _tagger.readTags(path: filePath);

      if (tag?.lyrics?.isNotEmpty == true) {
        msg("Embedded lyrics found in metadata", tag: 'LrcHelper');
        return tag!.lyrics;
      } else {
        msg("No embedded lyrics found in metadata", tag: 'LrcHelper');
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
            sucs("External lyrics file found: ${lyricsFile.path}",
                tag: 'LrcHelper');
            return content;
          }
        }
      }
      msg("No external lyrics file found", tag: 'LrcHelper');
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
  bool isValidLrc(String? lyricsContent) {
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

  // Future<void> loadLyrics(String songUri) async {
  //   controller.lyricsData.value = await LrcHelper().initLrc(songUri);

  //   final lyricsData = controller.lyricsData.value;

  //   // Check if external or internal lyrics are synchronized
  //   if (lyricsData['external']) {
  //     _syncLyrics(lyricsData['external']);
  //   } else if (lyricsData['internal']) {
  //     _syncLyrics(lyricsData['internal']);
  //   }
  // }

  // // Synchronize lyrics by initializing LRC
  // void _syncLyrics(String? rawLrc) async {
  //   final isValidLrc = LrcHelper().isValidLrc(rawLrc);
  //   late Lrc parsedLrc;
  //   if (isValidLrc) {
  //     parsedLrc = Lrc.parse(rawLrc!);
  //     controller.isSyncedLrc.value = true;
  //     msg("Syncing lyrics with LRC: $parsedLrc", tag: 'Synced lyrics');
  //     controller.lyricsLines.assignAll(parsedLrc.lyrics);
  //     controller.currentLineIndex.value = -1;
  //   }
  // }
}
