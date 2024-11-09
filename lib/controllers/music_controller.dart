import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

class MusicController extends GetxController {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final List<SongModel> songs = <SongModel>[].obs; // Observable list of songs
  final RxInt currentIndex = 0.obs; // Current index of the song
  final RxBool isPlaying = false.obs; // Track if audio is playing

  final RxString currentSongName =
      ''.obs; //NAme of the Current song being played
  final RxString currentArtist =
      ''.obs; //Name of the artist of the current song being played
  final RxString currentAlbum =
      ''.obs; //Name of the album of the current song being played

  // Publicly accessible variables for the UI
  // List<SongModel> get songs => _songs;
  // int get currentIndex => _currentIndex.value;
  // bool get isPlaying => _isPlaying.value;
  var currentSong;

//Duration variables of player being played
  var duration = ''.obs;
  var position = ''.obs;

  var max = 0.0.obs;
  var value = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    _initializePlayer();
  }

  updateCurrentDetails(newSong) {
    currentSong = songs[currentIndex.value];
    currentSongName.value = currentSong.title!;
    currentArtist.value = currentSong.artist!;
    currentAlbum.value = currentSong.album!;
  }

  setSongs(List<SongModel> songs) {
    print("\n\n");
    print(songs);
    print("\n\n");
    songs.addAll(songs);
  }

  clearSongQueue() {
    songs.clear();
  }

  addSong(SongModel song) {
    songs.add(song);
  }

//Position and duration of the player listeners
  updatePosition() {
    _audioPlayer.durationStream.listen((d) {
      duration.value = d.toString().split('.')[0];
      max.value = d!.inSeconds.toDouble();
    });

    _audioPlayer.positionStream.listen((p) {
      position.value = p.toString().split('.')[0];
      value.value = p.inSeconds.toDouble();
    });

//When the song ends, play the next song
    _audioPlayer.playerStateStream.listen((event) {
      if (event.processingState == ProcessingState.completed) {
        next();
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
  void _initializePlayer() {
    _audioPlayer.playerStateStream.listen((state) {
      isPlaying.value = state.playing;
    });
  }

  void startNewStream(List<SongModel> songsList, int? startIndex) {
    startIndex ??= 0;

    _audioPlayer.stop();
    songs.clear();
    songs.addAll(songsList);
    currentIndex.value = startIndex;
    playSongAt(startIndex);
  }

  // Play a specific song
  Future<void> playSongAt(int index) async {
    try {
      final song = songs[index];
      await _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(song.uri!)));
      await _audioPlayer.play();
      currentIndex.value = index;
      isPlaying.value = true;
      updatePosition();
    } catch (e) {
      print("Error playing song: $e");
    }
  }

  // Pause the current song
  Future<void> pause() async {
    await _audioPlayer.pause();
    isPlaying.value = false;
  }

  // Resume playing
  Future<void> play() async {
    await _audioPlayer.play();
    isPlaying.value = true;
  }

  // Stop playback
  Future<void> stop() async {
    await _audioPlayer.stop();
    isPlaying.value = false;
  }

  // Play next song in queue
  Future<void> next() async {
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
}
