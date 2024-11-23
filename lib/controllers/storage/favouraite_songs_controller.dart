import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:on_audio_query/on_audio_query.dart';

class FavouriteSongsController extends GetxController {
  final box = GetStorage('favourite_songs');

  // Make the list of favorite songs observable
  var favouriteSongs = <SongModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Load the initial list of favorite songs from storage
    favouriteSongs.value = box.read<List<SongModel>>('songs') ?? [];
  }

  bool contains(int songId) {
    var result =
        favouriteSongs.where((element) => element.id == songId).toList();

    if (result.isEmpty) {
      return false;
    }
    return true;
  }

  void addSong(SongModel song) {
    favouriteSongs.add(song);
    box.write('songs', favouriteSongs);
  }

  void removeSong(int songId) {
    favouriteSongs.removeWhere((element) => element.id == songId);
    box.write('songs', favouriteSongs);
  }
}
