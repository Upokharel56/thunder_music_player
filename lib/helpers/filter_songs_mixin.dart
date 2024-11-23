import 'package:on_audio_query/on_audio_query.dart';

mixin FilterSongsMixin {
  //  folders to include and exclude
  List<String> includeFolders = [
    // '/storage/emulated/0/Music/MyFavorites/',
    // '/storage/emulated/0/Music/TopHits/',
    // Add more folders as needed
  ];

  List<String> excludeFolders = [
    //   '/storage/emulated/0/Music/Old/',
    //   '/storage/emulated/0/Music/Misc/',
    '/storage/emulated/0/Android/',
    '/storage/emulated/0/Call/',
    '/storage/emulated/0/Alarms/',
  ];
  Future<List<SongModel>> getFilteredSongList(
    List<SongModel> allSongs,
  ) async {
    List<SongModel> filteredSongs = allSongs.where((song) {
      String filePath = song.data;

      // Exclude hidden paths
      bool isHidden = _isHiddenPath(filePath);
      if (isHidden) return false;

      // Check inclusion criteria uncomment to add whitelists only
      // bool isIncluded = includeFolders.isEmpty
      //     ? true
      //     : includeFolders.any((folder) => filePath.startsWith(folder));

      // Check exclusion criteria
      bool isExcluded =
          excludeFolders.any((folder) => filePath.startsWith(folder));

      // Include the song only if it's included and not excluded
      return !isExcluded;
    }).toList();

    return filteredSongs;
  }

// Helper method to check if a path is hidden
  bool _isHiddenPath(String path) {
    final uri = Uri.file(path);
    for (var segment in uri.pathSegments) {
      if (segment.startsWith('.')) return true;
    }
    return false;
  }
}
