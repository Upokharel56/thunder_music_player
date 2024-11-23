import 'dart:async';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:thunder_audio_player/helpers/lrc_helpers.dart';
import 'package:thunder_audio_player/utils/loggers.dart';
import 'package:thunder_audio_player/platform_channels/android/volume_controls.dart';

class MusicController extends GetxController with VolumeControls {
  final AudioPlayer audioPlayer = AudioPlayer();
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

  final playbackspeed = 1.0.obs;

//Lyrics variables for lrc contents
  final LrcHelper lrcHelper = LrcHelper();
  final lyricsData = {}.obs; // Observable map for the lyrics structure
  final lyricsLines = [].obs; // List of parsed timestamps and lyrics
  final RxInt currentLineIndex =
      (-1).obs; // Observable index for the current line

  //Stream listeners for listening players stream and updating UI
  late StreamSubscription<Duration?> _durationSubscription;
  late StreamSubscription<Duration> _positionSubscription;
  late StreamSubscription<PlayerState> _playerStateSubscription;
  late StreamSubscription<int?> _currentIndexSubscription;

  //Current playing audio information map
  final currentAudioInfo = {}.obs;

  var currentDuration = Duration.zero.obs;
  final RxBool isSyncedLyrics = false.obs;
  final RxString lyrics = ''.obs;

  @override
  void onInit() {
    super.onInit();
    listenToPlayerStreams();
  }

  Future<void> startNewStream(
      List<SongModel> songsList, int? startIndex) async {
    startIndex ??= 0;

    await audioPlayer.stop();

    songs.clear();
    songs.addAll(songsList);
    currentIndex.value = startIndex;

    List<AudioSource> audioSources = songsList.map((song) {
      return AudioSource.uri(
        Uri.parse(song.uri!),
        tag: MediaItem(
          id: song.id.toString(),
          album: song.album ?? "Unknown Album",
          title: song.title,
          artist: song.artist ?? "Unknown Artist",
        ),
      );
    }).toList();

    final playlist = ConcatenatingAudioSource(children: audioSources);
    listenToPlayerStreams();
    await audioPlayer.setAudioSource(playlist, initialIndex: startIndex);
    await play();
  }

// Play a specific song and load its lyrics
  Future<void> playSongAt(int index) async {
    try {
      // Seek to the desired index within the playlist
      await audioPlayer.seek(Duration.zero, index: index);
      await audioPlayer.play();
      isPlaying.value = true;
      currentIndex.value = index;
    } catch (e) {
      err("Error playing song: $e");
    }
  }

// Position and duration listeners to update the UI slider
  Future<void> listenToPlayerStreams() async {
    //
    // Listen to duration changes
    _durationSubscription = audioPlayer.durationStream.listen((d) {
      if (d != null) {
        duration.value = d.toString().split('.')[0];
        max.value = d.inSeconds.toDouble();
        currentDuration.value = d;
      }
    });

    // Listen to position changes
    _positionSubscription = audioPlayer.positionStream.listen((p) {
      position.value = p.toString().split('.')[0];
      value.value = p.inSeconds.toDouble();
    });

    // Listen to player state changes
    _playerStateSubscription = audioPlayer.playerStateStream.listen((event) {
      isPlaying.value = event.playing;

      // Handle processing state changes
      switch (event.processingState) {
        case ProcessingState.idle:
          isPlaying.value = false;
          break;

        default:
          isPlaying.value = event.playing;
          break;
      }
    });

    // Listen to currentIndex changes
    _currentIndexSubscription = audioPlayer.currentIndexStream.listen((index) {
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

    currentAudioInfo.value = {
      'title': currentSong.title,
      'artist': currentSong.artist,
      'album': currentSong.album,
      'duration': Duration(milliseconds: currentSong.duration ?? 0) // Duration
          .toString()
          .split('.')[0],
      'genre': currentSong.genre,
      'path': currentSong.data,
      'size': "${(currentSong.size / 1024 / 1024).toStringAsFixed(2)} MB",
    };
  }

  Future<void> seekDuration(int seconds) async {
    final duration = audioPlayer.duration;

    if (duration == null) return;

    final currentPosition = audioPlayer.position;
    final newPosition = currentPosition + Duration(seconds: seconds);

    if (newPosition < Duration.zero) {
      await audioPlayer.seek(Duration.zero);
    } else if (newPosition > duration) {
      await audioPlayer.seek(duration);
    } else {
      await audioPlayer.seek(newPosition);
    }
  }

  Future<void> togglePlay() async {
    isPlaying.value ? await pause() : await play();
  }

  // Pause the current song
  Future<void> pause() async {
    isPlaying.value = false;
    await audioPlayer.pause();
  }

  Future<void> play() async {
    isPlaying.value = true;
    await audioPlayer.play();
  }

  Future<void> stop() async {
    await audioPlayer.stop();
    isPlaying.value = false;
  }

  Future<void> next() async {
    await audioPlayer.seekToNext();
  }

  Future<void> previous() async {
    await audioPlayer.seekToPrevious();
  }

  void changePlaybackSpeed(double speed) {
    audioPlayer.setSpeed(speed);
    playbackspeed.value = speed;
  }

  void toggleShuffle() async {
    isShuffleActive.value = !isShuffleActive.value;

    // Disable repeat if shuffle is activated
    if (isShuffleActive.value) {
      isRepeatActive.value = false;
      await audioPlayer.setLoopMode(LoopMode.off);
    }
    await audioPlayer.setShuffleModeEnabled(isShuffleActive.value);
  }

  void toggleRepeat() async {
    isRepeatActive.value = !isRepeatActive.value;

    // Disable shuffle if repeat is activated
    if (isRepeatActive.value) {
      isShuffleActive.value = false;
      await audioPlayer.setShuffleModeEnabled(false);
    }

    // Set loop mode on the player
    await audioPlayer.setLoopMode(
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

  // Load and parse lyrics for the song
  Future<void> loadLyricsAt(int index) async {
    final String songUri = songs[currentIndex.value].data ?? '';

    if (songUri.isEmpty) {
      err("Song URI is empty", tag: 'Lyrics Error');
      return;
    }

    try {
      // Initialize lyrics data with external and internal lyrics content
      lyricsData.value = await lrcHelper.initLrc(realPath: songUri);
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
        msg("Syncing external lyrics:}", tag: 'External Lyrics Sync');
        _syncLyrics(lyricsData['external']);
        return;
      } else if (lyricsData['internal'] != null) {
        msg("Syncing internal lyrics: ", tag: ' Internal Lyrics Sync');
        _syncLyrics(lyricsData['internal']);
        return;
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
      rawLrc = lrcHelper.cleanLrc(rawLrc ?? '', cleanBlankLines: true);

      if (rawLrc.isEmpty) {
        return null;
      }

      isValidLrc = lrcHelper.isValidLrc(rawLrc);
      msg("LRC validation result: $isValidLrc \n\n", tag: '_syncLyrics');
      isSyncedLyrics.value = isValidLrc;
      lyrics.value = rawLrc;
      msg("Is synced value after sync: ${isSyncedLyrics.value}",
          tag: '_syncLyrics changes');
      return;
    } catch (e) {
      err(
        "Error validating LRC content inside _syncLyrics function: $e",
        tag: 'LrcHelper',
      );
      return null;
    }
  }

  @override
  void onClose() {
    _stopListeningPlayerStreams();
    audioPlayer.dispose();
    super.onClose();
  }
}
