import 'package:get/get.dart';
// Import your controllers
import 'package:thunder_audio_player/controllers/music_controller.dart';
import 'package:thunder_audio_player/controllers/routes_controller.dart';
import 'package:thunder_audio_player/controllers/storage/favouraite_songs_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    // Initialize your controllers here
    Get.put(MusicController(), permanent: true);
    // Add more controllers if needed
    Get.put(RoutesController(), permanent: true);
    Get.put(FavouriteSongsController(), permanent: true);
  }
}
