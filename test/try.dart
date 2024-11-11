import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lrc/lrc.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:thunder_audio_player/controllers/audio_handler.dart';
import 'package:thunder_audio_player/helpers/audio_helpers.dart';

import 'package:thunder_audio_player/utils/loggers.dart';

import 'package:thunder_audio_player/platform_channels/android/volume_controls.dart';

class MusicController extends GetxController with VolumeControls {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  // final AudioPlayer _audioPlayer = AudioPlayer();

  final AudioPlayerHandler audioHandler = AudioPlayerHandler();

  final List<SongModel> songs = <SongModel>[].obs; // Observable list of songs
  final RxInt currentIndex = 0.obs; // Current index of the song
  final RxBool isPlaying = false.obs; // Track if audio is playing

//Loop and shuffle controllers variables
  final RxBool isLoopActive = false.obs;
  final RxBool isShuffleActive = false.obs;
  final RxBool isRepeatActive = false.obs;
  final RxInt previousIndex = 0.obs;
  final RxInt nextIndex = 0.obs;

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
  @override
  void onInit() {
    super.onInit();
    _initializeAudioHandler();

    // Listen for changes in the playback state to sync `isPlaying`
    audioHandler.playbackState.listen((state) {
      isPlaying.value = state.playing;
      if (state.processingState == AudioProcessingState.completed) {
        // Auto-play next song when the current one completes
        isRepeatActive.value ? playSongAt(currentIndex.value) : next();
      }
    });

    // Listen to position updates
    audioHandler.positionStream.listen((position) {
      this.position.value = position.toString().split('.')[0];
      value.value = position.inSeconds.toDouble();
    });

    // Listen to duration updates
    audioHandler.mediaItem.listen((mediaItem) {
      if (mediaItem != null && mediaItem.duration != null) {
        duration.value = mediaItem.duration!.toString().split('.')[0];
        max.value = mediaItem.duration!.inSeconds.toDouble();
      }
    });
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

      // Load lyrics for the current song
      loadLyrics(song.uri!);
      updatePosition();

      msg("Playing song: ${song.title}");
    } catch (e) {
      err("Error playing song: $e");
    }
  }

//Position and duration of the player listeners
  // the duration and max value needs to be updated in controller for ui dont matter if from this class or Audio hndler class

  void updatePosition() {
    // the duration and max value needs to be updated in controller for ui dont matter if from this class or Audio hndler class

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
    //only to update ui dont put any logic here
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

  @override
  void onClose() {
    _audioPlayer.dispose();
    super.onClose();
  }
}
