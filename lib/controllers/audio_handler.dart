import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:get/get.dart';
import 'package:thunder_audio_player/controllers/music_controller.dart';

class AudioPlayerHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _player = AudioPlayer();
  final MusicController controller = Get.find<MusicController>();

  AudioPlayerHandler() {
    // Connect player state with AudioHandler state
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
    _initializeListeners();
  }

  @override
  Future<void> customAction(String name, [Map<String, dynamic>? extras]) async {
    if (name == 'setAudioSource' && extras != null) {
      final uri = Uri.parse(extras['uri']);
      await _player.setAudioSource(AudioSource.uri(uri));
    }
  }

  // Update playback state for notifications
  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        _player.playing ? MediaControl.pause : MediaControl.play,
        MediaControl.stop,
        MediaControl.skipToNext,
      ],
      androidCompactActionIndices: const [0, 1, 2],
      processingState: _getProcessingState(),
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
    );
  }

  // Map player processing state to audio handler state
  AudioProcessingState _getProcessingState() {
    switch (_player.processingState) {
      case ProcessingState.idle:
        return AudioProcessingState.idle;
      case ProcessingState.loading:
        return AudioProcessingState.loading;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
      default:
        return AudioProcessingState.idle;
    }
  }

  // Control methods for notification buttons
  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() => controller.next();

  @override
  Future<void> skipToPrevious() => controller.previous();

  // Set up player to react to controller updates
  void _initializeListeners() {
    controller.isPlaying.listen((isPlaying) {
      if (isPlaying) {
        play();
      } else {
        pause();
      }
    });
    controller.currentIndex.listen((index) {
      if (index >= 0 && index < controller.songs.length) {
        final song = controller.songs[index];
        _player.setAudioSource(AudioSource.uri(Uri.parse(song.uri!)));
      }
    });
  }
}
