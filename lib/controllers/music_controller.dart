import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lrc/lrc.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:thunder_audio_player/helpers/lrc_helpers.dart';

import 'package:thunder_audio_player/utils/loggers.dart';

import 'package:thunder_audio_player/platform_channels/android/volume_controls.dart';

class MusicController extends GetxController with VolumeControls {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final List<SongModel> songs = <SongModel>[].obs; // Observable list of songs
  final RxInt currentIndex = 0.obs; // Current index of the song
  final RxBool isPlaying = false.obs; // Track if audio is playing

//Loop and shuffle controllers variables
  final RxBool isLoopActive = false.obs;
  final RxBool isShuffleActive = false.obs;
  final RxBool isRepeatActive = false.obs;
  final RxInt previousIndex = 0.obs;
  final RxInt nextIndex = 0.obs;

//lrc of the song
  final RxString currentLyrics = ''.obs;
  final RxBool hasExternalLrc = false.obs;
  // final RxString externalLrc = ''.obs;

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

  @override
  void onInit() {
    super.onInit();
    _initializePlayer();

    // Sync `isPlaying` state with audio player state
    _audioPlayer.playerStateStream.listen((state) {
      isPlaying.value = state.playing;
    });

    // Update current line based on playback position
    _audioPlayer.positionStream.listen((position) {
      _updateCurrentLine(position);
    });
  }

  // Load and parse lyrics for the song
  Future<void> loadLyrics(String songUri) async {
    lyricsData.value = await lrcHelper.initLrc(songUri);

    // Check if external or internal lyrics are synchronized
    if (lyricsData['external']['isSynced']) {
      _syncLyrics(lyricsData['external']['synced']);
    } else if (lyricsData['internal']['isSynced']) {
      _syncLyrics(lyricsData['internal']['synced']);
    }
  }

  // Synchronize lyrics by initializing LRC
  void _syncLyrics(Lrc? parsedLrc) {
    if (parsedLrc == null) return;

    lyricsLines.assignAll(parsedLrc.lyrics);
    currentLineIndex.value = -1;
  }

  // Update current line based on the position of the audio
  void _updateCurrentLine(Duration position) {
    if (lyricsLines.isEmpty) return; // Add this check

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

  // Play a specific song and load its lyrics
  Future<void> playSongAt(int index) async {
    try {
      final song = songs[index];
      currentIndex.value = index;

      await _audioPlayer.setAudioSource(AudioSource.uri(
        Uri.parse(song.uri!),
        tag: MediaItem(
          id: song.id.toString(),
          album: song.album ?? "Unknown Album",
          title: song.title ?? "Unknown Title",
          artist: song.artist ?? "Unknown Artist",
        ),
      ));
      await _audioPlayer.play();
      isPlaying.value = true;

      try {
        // Load lyrics for the current song
        await loadLyrics(songs[index].uri ?? "");
      } catch (e) {
        err("Error loading lyrics: $e", tag: 'Lyrics Loading Error');
      }

      updatePosition();

      msg("Playing song: ${song.title}");
    } catch (e) {
      err("Error playing song: $e");
    }
  }

  setSongs(List<SongModel> songs) {
    msg("\n\n");
    msg("$songs");
    msg("\n\n");
    songs.addAll(songs);
  }

  clearSongQueue() {
    songs.clear();
  }

  addSong(SongModel song) {
    songs.add(song);
  }

//Position and duration of the player listeners
  void updatePosition() {
    _audioPlayer.durationStream.listen((d) {
      if (d != null) {
        duration.value = d.toString().split('.')[0];
        max.value = d.inSeconds.toDouble();
      }
    });

    _audioPlayer.positionStream.listen((p) {
      position.value = p.toString().split('.')[0];
      value.value = p.inSeconds.toDouble();
    });

    // When the song ends, play the next song
    _audioPlayer.playerStateStream.listen((event) {
      if (event.processingState == ProcessingState.completed) {
        isRepeatActive.value ? playSongAt(currentIndex.value) : next();
      }

      if (event.processingState == ProcessingState.idle) {
        isPlaying.value = false;
      }
    });
  }

  seekDuration(seconds) {
    var duration = Duration(seconds: seconds);
    _audioPlayer.seek(duration);
  }

  // Fetch songs from device
  Future<void> fetchSongs() async {
    bool permissionStatus = await _audioQuery.permissionsStatus();
    if (!permissionStatus) {
      permissionStatus = await _audioQuery.permissionsRequest();
    }
    if (permissionStatus) {
      songs.addAll(await _audioQuery.querySongs());
    }
  }

  // Initialize audio player
  Future<void> _initializePlayer() async {
    _audioPlayer.playerStateStream.listen((state) {
      isPlaying.value = state.playing;
      if (state.processingState == ProcessingState.ready) {
        updatePosition();
      }
    });
  }

  void startNewStream(List<SongModel> songsList, int? startIndex) async {
    startIndex ??= 0;

    _audioPlayer.stop();
    songs.clear();
    songs.addAll(songsList);
    currentIndex.value = startIndex;
    await playSongAt(startIndex);
  }

  // Pause the current song
  Future<void> pause() async {
    isPlaying.value = false;
    await _audioPlayer.pause();
  }

  Future<void> togglePlay() async {
    isPlaying.value ? await pause() : await play();
  }

  // Resume playing
  Future<void> play() async {
    isPlaying.value = true;
    await _audioPlayer.play();
  }

  // Stop playback
  Future<void> stop() async {
    await _audioPlayer.stop();
    isPlaying.value = false;
  }

  // Play next song in queue
  Future<void> next() async {
    if (isRepeatActive.value) {
      await playSongAt(currentIndex.value);
      return;
    }

    if (isShuffleActive.value) {
      previousIndex.value = currentIndex.value;
      currentIndex.value = Random().nextInt(songs.length);
      nextIndex.value = Random().nextInt(songs.length);
      await playSongAt(currentIndex.value);
      return;
    }

    if (currentIndex.value + 1 < songs.length) {
      currentIndex.value++;
      await playSongAt(currentIndex.value);
    } else if (currentIndex.value == songs.length - 1) {
      currentIndex.value = 0;
      await playSongAt(currentIndex.value);
    }
  }

  // Play previous song in queue
  Future<void> previous() async {
    if (isRepeatActive.value) {
      await playSongAt(currentIndex.value);
      return;
    }

    if (isShuffleActive.value) {
      previousIndex.value = Random().nextInt(songs.length);
      currentIndex.value = previousIndex.value;

      await playSongAt(currentIndex.value);
      return;
    }

    if (currentIndex.value > 0) {
      currentIndex.value--;
      await playSongAt(currentIndex.value);
    } else if (currentIndex.value == 0) {
      currentIndex.value = songs.length - 1;
      await playSongAt(currentIndex.value);
    }
  }

  // Add a song to the queue
  Future<void> queueSong(int index) async {
    final song = songs[index];
    await _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(song.uri!)));
    currentIndex.value = index;
  }

  @override
  void onClose() {
    _audioPlayer.dispose();
    super.onClose();
  }

  void toggleShuffle() {
    isShuffleActive.value = !isShuffleActive.value;
    if (isShuffleActive.value) {
      isRepeatActive.value = false;
    }
  }

  void toggleRepeat() {
    isRepeatActive.value = !isRepeatActive.value;
    if (isRepeatActive.value) {
      isShuffleActive.value = false;
    }
  }
}
