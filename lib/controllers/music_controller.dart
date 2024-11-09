import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

import 'package:thunder_audio_player/utils/volume_controls.dart';
import 'package:path_provider/path_provider.dart'; // To access the app's local directory
import 'dart:io'; // For file operations
import '../utils/loggers.dart';

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

//check if the player is played or not
  final RxBool isMiniPlayerActive = false.obs;

//Duration variables of player being played
  var duration = ''.obs;
  var position = ''.obs;

  var max = 0.0.obs;
  var value = 0.0.obs;

  final lyricsLines = [].obs; // List of parsed timestamps and lyrics
  final RxInt currentLineIndex =
      (-1).obs; // Observable index for the current line

  @override
  void onInit() {
    super.onInit();
    _initializePlayer();
    // Listen to the playback state and sync with isPlaying
    _audioPlayer.playerStateStream.listen((state) {
      isPlaying.value = state.playing;
    });

    _audioPlayer.positionStream.listen((position) {
      for (int i = 0; i < lyricsLines.length; i++) {
        final lineTime = lyricsLines[i]['time'] as Duration;
        if (position < lineTime) {
          currentLineIndex.value = i - 1;
          break;
        }
      }
    });
  }

  // Load lyrics from a local .lrc file
  Future<void> loadLyrics({SongModel? song, String? songTitle}) async {
    try {
      if (song?.uri == null && songTitle == null) {
        throw Exception('Either song or songTitle must be provided');
      }

      final List<String> possiblePaths = [];
      final directory = await getApplicationDocumentsDirectory();

      // Get song filename without extension
      final songPath = song?.uri ?? '';
      final songFile = songPath.split('/').last;
      final songName = songFile.replaceAll(RegExp(r'\.[^.]+$'), '');

      final songRoot = songPath.substring(0, songPath.lastIndexOf('/'));

      // Check multiple possible locations
      possiblePaths.addAll([
        // 1. Check in song's directory
        // '${directory.path}/${songPath.substring(0, songPath.lastIndexOf('/'))}/$songName.lrc',
        // // 2. Check in dedicated lyrics folder
        // '${directory.path}/lyrics/$songName.lrc',
        // // 3. Check using provided songTitle
        // if (songTitle != null) '${directory.path}/lyrics/$songTitle.lrc',
        // 4. Check in song's root directory
        'sdcard/$songRoot/$songName.lrc',
      ]);

      for (final path in possiblePaths) {
        final file = File(path);
        if (await file.exists()) {
          final lyrics = await file.readAsString();
          currentLyrics.value = lyrics;
          hasExternalLrc.value = true;
          parseLyrics(lyrics);
          log("Lyrics loaded successfully from: $path");
          return;
        }
      }

      // No lyrics found in any location
      hasExternalLrc.value = false;
      currentLyrics.value = "No lyrics available.";
      log("\n\n No lyrics found for this song. Checked paths: ${possiblePaths.join('\n')} \n\n");
    } catch (e) {
      err("\n\n Error loading lyrics: \n $e \n\n");
      currentLyrics.value = "Lyrics not available.";
    }
  }

  void parseLyrics(String content) {
    final lines = content.split('\n');

    lyricsLines.clear();
    for (var line in lines) {
      final match =
          RegExp(r'\[(\d{2}):(\d{2})\.(\d{2})\](.*)').firstMatch(line);
      if (match != null) {
        final minutes = int.parse(match.group(1)!);
        final seconds = int.parse(match.group(2)!);
        final milliseconds = int.parse(match.group(3)!);
        final time = Duration(
            minutes: minutes, seconds: seconds, milliseconds: milliseconds);
        final lyrics = match.group(4)!.trim();

        lyricsLines.add({
          'time': time,
          'lyrics': lyrics,
        });
      }
    }
    lyricsLines.sort((a, b) => a['time'].compareTo(b['time']));
    log("\n\n Lyrics parsed successfully. \n $lyricsLines \n\n");
  }

  // Modify playSongAt to check initialization
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
      updatePosition();
      loadLyrics(song: song, songTitle: song.title);
    } catch (e) {
      log("Error playing song: $e");
    }
  }

  setSongs(List<SongModel> songs) {
    log("\n\n");
    log("$songs");
    log("\n\n");
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
    if (isPlaying.value) {
      await pause();
    } else {
      await play();
    }
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
