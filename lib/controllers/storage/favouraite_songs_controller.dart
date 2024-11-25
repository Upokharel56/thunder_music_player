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
    List<dynamic> storedSongs = box.read<List<dynamic>>('songs') ?? [];
    favouriteSongs.value =
        storedSongs.map((e) => SongModel(e as Map<String, dynamic>)).toList();
  }

  bool contains(int songId) {
    return favouriteSongs.any((element) => element.id == songId);
  }

  void addSong(SongModel song) {
    if (contains(song.id)) return;
    favouriteSongs.add(song);
    saveToStorage();
  }

  void removeSong(int songId) {
    favouriteSongs.removeWhere((element) => element.id == songId);
    saveToStorage();
  }

  void saveToStorage() {
    // Save the list of favorite songs to storage
    box.write('songs', favouriteSongs.map((e) => e.getMap).toList());
  }
}
