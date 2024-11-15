import 'dart:async';

import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:lrc/lrc.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:thunder_audio_player/helpers/lrc_helpers.dart';
import 'package:thunder_audio_player/platform_channels/android/file_path_helper.dart';

import 'package:thunder_audio_player/utils/loggers.dart';

import 'package:thunder_audio_player/platform_channels/android/volume_controls.dart';

class MusicController extends GetxController
    with VolumeControls, FilePathResolverMixin {
  // final OnAudioQuery _audioQuery = OnAudioQuery();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final RxList<SongModel> songs = <SongModel>[].obs; // Observable list of songs
  final RxInt currentIndex = 0.obs; // Current index of the song
  final RxBool isPlaying = false.obs; // Track if audio is playing

//Loop and shuffle controllers variables
  final RxBool isLoopActive = false.obs;
  final RxBool isShuffleActive = false.obs;
  final RxBool isRepeatActive = false.obs;

//check if the player is played or not
  final RxBool isMiniPlayerActive = false.obs;

//Duration variables of player being played
  var duration = ''.obs;
  var position = ''.obs;

//For time slider and its position
  var max = 0.0.obs;
  var value = 0.0.obs;

//Lyrics variables for lrc contents
  final LrcHelper lrcHelper = LrcHelper();
  final lyricsData = {}.obs; // Observable map for the lyrics structure
  final lyricsLines = [].obs; // List of parsed timestamps and lyrics
  final RxInt currentLineIndex =
      (-1).obs; // Observable index for the current line

  final RxBool isSyncedLrc = false.obs;

  //Stream listeners for listening players stream and updating UI
  late StreamSubscription<Duration?> _durationSubscription;
  late StreamSubscription<Duration> _positionSubscription;
  late StreamSubscription<PlayerState> _playerStateSubscription;
  late StreamSubscription<int?> _currentIndexSubscription;

  //Current playing audio information map
  final currentAudioInfo = {}.obs;

  @override
  void onInit() {
    super.onInit();
    listenToPlayerStreams();
  }

  Future<void> startNewStream(
      List<SongModel> songsList, int? startIndex) async {
    startIndex ??= 0;

    await _audioPlayer.stop();

    songs.clear();
    songs.addAll(songsList);
    currentIndex.value = startIndex;

    List<AudioSource> audioSources = songsList.map((song) {
      return AudioSource.uri(
        Uri.parse(song.uri!),
        tag: MediaItem(
          id: song.id.toString(),
          album: song.album ?? "Unknown Album",
          title: song.title ?? "Unknown Title",
          artist: song.artist ?? "Unknown Artist",
        ),
      );
    }).toList();

    final playlist = ConcatenatingAudioSource(children: audioSources);
    listenToPlayerStreams();
    await _audioPlayer.setAudioSource(playlist, initialIndex: startIndex);
    await play();
  }

// Play a specific song and load its lyrics
  Future<void> playSongAt(int index) async {
    late String uri;
    try {
      // Seek to the desired index within the playlist
      await _audioPlayer.seek(Duration.zero, index: index);
      await _audioPlayer.play();
      isPlaying.value = true;
      currentIndex.value = index;

      listenToPlayerStreams();
    } catch (e) {
      err("Error playing song: $e");
    }
  }

// Position and duration listeners to update the UI slider
  Future<void> listenToPlayerStreams() async {
    // Listen to duration changes
    _durationSubscription = _audioPlayer.durationStream.listen((d) {
      if (d != null) {
        duration.value = d.toString().split('.')[0];
        max.value = d.inSeconds.toDouble();
      }
    });

    // Listen to position changes
    _positionSubscription = _audioPlayer.positionStream.listen((p) {
      position.value = p.toString().split('.')[0];
      value.value = p.inSeconds.toDouble();

      if (isSyncedLrc.value) {
        _updateCurrentLine(p);
      }
    });

    // Listen to player state changes
    _playerStateSubscription = _audioPlayer.playerStateStream.listen((event) {
      // Update playing state
      isPlaying.value = event.playing;

      // Handle processing state changes
      switch (event.processingState) {
        case ProcessingState.completed:
          // The player has completed playing the current track With LoopMode and ShuffleMode properly set, the player will handle what's next itself
          break;

        case ProcessingState.idle:
          isPlaying.value = false;
          break;

        default:
          // Handle other states if necessary
          break;
      }
    });

    // Listen to currentIndex changes
    _currentIndexSubscription = _audioPlayer.currentIndexStream.listen((index) {
      if (index != null) {
        currentIndex.value = index;
        updateCurrentAudioInfo(index);
        loadLyricsAt(index);
      }
    });
  }

  // Update the current audio info
  void updateCurrentAudioInfo(int index) async {
    final currentSong = songs[index];

    msg("Current song: $currentSong", tag: 'Updating Current Song info');

    currentAudioInfo.value = {
      'title': currentSong.title,
      'artist': currentSong.artist,
      'album': currentSong.album,
      'duration': Duration(milliseconds: currentSong.duration ?? 0) // Duration
          .toString()
          .split('.')[0],
      'genre': currentSong.genre,
      'path': await getRealPath(currentSong.uri!),
      'size': "${(currentSong.size / 1024 / 1024).toStringAsFixed(2)} MB",
    };

    sucs("Current audio info updated: $currentAudioInfo",
        tag: 'Current Audio Info');
  }

  Future<void> seekDuration(seconds) async {
    var duration = Duration(seconds: seconds);
    _audioPlayer.seek(duration);
  }

  Future<void> togglePlay() async {
    isPlaying.value ? await pause() : await play();
  }

  // Pause the current song
  Future<void> pause() async {
    isPlaying.value = false;
    await _audioPlayer.pause();
  }

  Future<void> play() async {
    isPlaying.value = true;
    await _audioPlayer.play();
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    isPlaying.value = false;
  }

  Future<void> next() async {
    await _audioPlayer.seekToNext();
  }

  Future<void> previous() async {
    await _audioPlayer.seekToPrevious();
  }

  void toggleShuffle() async {
    isShuffleActive.value = !isShuffleActive.value;

    // Disable repeat if shuffle is activated
    if (isShuffleActive.value) {
      isRepeatActive.value = false;
      await _audioPlayer.setLoopMode(LoopMode.off);
    }
    await _audioPlayer.setShuffleModeEnabled(isShuffleActive.value);
  }

  void toggleRepeat() async {
    isRepeatActive.value = !isRepeatActive.value;

    // Disable shuffle if repeat is activated
    if (isRepeatActive.value) {
      isShuffleActive.value = false;
      await _audioPlayer.setShuffleModeEnabled(false);
    }

    // Set loop mode on the player
    await _audioPlayer.setLoopMode(
      isRepeatActive.value ? LoopMode.one : LoopMode.off,
    );
  }

  void _stopListeningPlayerStreams() {
    _durationSubscription.cancel();
    _positionSubscription.cancel();
    _playerStateSubscription.cancel();
    _currentIndexSubscription.cancel();
  }

//
//
// COde for handling lyrics
//
//

  Future<String> getRealPath(String contentUri) async {
    String? realPath = await resolveContentUri(contentUri);

    return realPath ?? "";
  }

  // Load and parse lyrics for the song
  Future<void> loadLyricsAt(int index) async {
    final String songUri = songs[currentIndex.value].uri ?? '';

    if (songUri.isEmpty) {
      err("Song URI is empty", tag: 'Lyrics Error');
      return;
    }

    try {
      // Initialize lyrics data with external and internal lyrics content
      lyricsData.value =
          await lrcHelper.initLrc(realPath: currentAudioInfo['path']);
    } catch (e) {
      err("Error initializing lyrics URI: $e", tag: 'Uri Init Error');
      return;
    }

    // Check if both external and internal lyrics are null
    if (lyricsData['external'] == null && lyricsData['internal'] == null) {
      err("No lyrics found for song: $songUri", tag: 'Lyrics Error');
      return;
    }

    try {
      // Prioritize external lyrics over internal lyrics
      if (lyricsData['external'] != null) {
        msg("Syncing External lyrics inside loadLyrics function",
            tag: 'Syncing Lyrics');
        _syncLyrics(lyricsData['external']);
      } else if (lyricsData['internal'] != null) {
        msg("Syncing Internal lyrics inside loadLyrics function",
            tag: 'Syncing Lyrics');
        _syncLyrics(lyricsData['internal']);
      }
    } catch (e) {
      err("Error syncing lyrics inside loadLyrics function: $e",
          tag: 'Lyrics Sync Error');
    }
  }

  // Synchronize lyrics by initializing LRC
  void _syncLyrics(String? rawLrc) async {
    late bool isValidLrc;
    try {
      isValidLrc = lrcHelper.isValidLrc(rawLrc);
    } catch (e) {
      err(
        "Error validating LRC content inside _syncLyrics function: $e",
        tag: 'LrcHelper',
      );
      return null;
    }

    late Lrc parsedLrc;
    try {
      if (isValidLrc) {
        parsedLrc = Lrc.parse(rawLrc!);
        msg("Lyrics validated successfully and parsed \n ",
            tag: 'Lyrics parsing ~ _syncLyrics');
        isSyncedLrc.value = true;

        msg("Syncing lyrics with LRC: $parsedLrc", tag: 'Synced lyrics');
        lyricsLines.assignAll(parsedLrc.lyrics);
        currentLineIndex.value = -1;
      } else {
        Map unsyncedData = {
          "lyrics": rawLrc,
        };
        isSyncedLrc.value = false;

        lyricsLines.clear();
        lyricsLines.add(unsyncedData);
      }
    } catch (e) {
      err("Error Syncing  LRC inside _syncLyrics function: $e",
          tag: 'Lyrics Sync Error');
    }
  }

  // Update current line based on the position of the audio
  void _updateCurrentLine(Duration position) {
    if (lyricsLines.isEmpty) {
      err("Lyrics lines are empty", tag: 'Update Lyrics');
      return; // Add this check
    }

    if (!isSyncedLrc.value) {
      err("Lyrics are not synced", tag: 'Update Lyrics');
      return;
    }

    try {
      for (int i = 0; i < lyricsLines.length; i++) {
        final line = lyricsLines[i];
        final nextLineTime = i + 1 < lyricsLines.length
            ? lyricsLines[i + 1].timestamp
            : Duration.zero;

        // Check if the current position falls within this line's timestamp
        if (position >= line.timestamp && position < nextLineTime) {
          currentLineIndex.value = i;
          break;
        }
      }
    } catch (e) {
      err("Error updating current line: $e", tag: 'Lyrics Error');
    }
  }

  @override
  void onClose() {
    _audioPlayer.dispose();
    super.onClose();
  }
}
