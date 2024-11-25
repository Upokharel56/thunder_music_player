import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:thunder_audio_player/consts/colors.dart';
import 'package:thunder_audio_player/controllers/storage/favouraite_songs_controller.dart';
import 'package:thunder_audio_player/pages/favouraites_songs_page.dart';
import 'package:thunder_audio_player/screens/song_list_screen.dart';
// import 'package:thunder_audio_player/helpers/filter_songs_mixin.dart';
// import 'package:thunder_audio_player/platform_channels/android/song_fetcher.dart';

class FavouritePage extends StatefulWidget {
  const FavouritePage({super.key});

  @override
  _FavouritePageState createState() => _FavouritePageState();
}

class _FavouritePageState extends State<FavouritePage> {
  final SongSortType _sortType = SongSortType.DATE_ADDED;
  final OnAudioQuery audioQuery = OnAudioQuery();
  List<SongModel> songList = [];
  final bool _isLoading = false;
  final FavouriteSongsController favController =
      Get.find<FavouriteSongsController>();

  final _favourites = {
    "Mixed Playlist": [
      '/storage/emulated/0/Songs(Mp3)/',
      '/storage/emulated/0/Songs (Mp3)/',
      '/sdcard/Songs (Mp3)/EnglishPlaylist',
      '/sdcard/Songs/',
    ],
    'English Playlist': [
      '/storage/emulated/0/Songs(Mp3)/EnglishPlaylist',
      '/storage/emulated/0/Songs (Mp3)/EnglishPlaylist',
      '/sdcard/Songs (Mp3)/EnglishPlaylist',
      '/sdcard/Songs/',
    ],
    'Hindi Playlist': [
      '/storage/emulated/0/Songs(Mp3)/Hindi playlist',
      '/storage/emulated/0/Songs (Mp3)/Hindi playlist',
      '/sdcard/Songs (Mp3)/Hindi playlist',
      '/sdcard/Songs/',
    ],
  };

  @override
  void initState() {
    super.initState();
    // _loadSongs();
  }

  void refresh() {
    setState(() {
      // Trigger a rebuild
    });
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          title: const Text('Favourites'),
          centerTitle: true,
        ),
        body: RefreshIndicator(
            child: _buildContent(),
            onRefresh: () async {
              setState(() {});
            }),
      );
    });
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_favourites.isEmpty) {
      return const Center(child: Text('No songs found'));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildFavouraiteSongs(),
        const SizedBox(height: 8),
        Expanded(child: _buildFavouriteLayout()),
      ],
    );
  }

  Widget _buildFavouraiteSongs() {
    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const FavouraitesSongsPage(),
          ),
        );
      },
      leading: const Icon(
        Icons.favorite,
        color: Colors.red,
      ),
      title: const Text(
        'Favoiraites songs all',
        style: TextStyle(
          color: whiteColor,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildFavouriteLayout() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate columns based on screen width and fixed item width of 225
        int crossAxisCount = (constraints.maxWidth / 250).floor();
        // Ensure at least 2 and at most 5 columns
        crossAxisCount = crossAxisCount.clamp(2, 5);

        return GridView.builder(
          padding: const EdgeInsets.all(8.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            // Force each item to be exactly 225x225
            childAspectRatio: 0.75,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: _favourites.length,
          itemBuilder: (context, index) =>
              _buildFavouraiteGrid(item: _favourites, index: index),
        );
      },
    );
  }

  Widget _buildFavouraiteGrid(
      {required Map<String, List<String>> item, required int index}) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SongListScreen(
                songFetchPaths: item.values.toList()[index],
                title: item.keys.toList()[index],
              ),
            ),
          );
        }, // Handle tap action
        child: Card(
          color: Colors.black12,
          child: Padding(
            padding:
                const EdgeInsets.only(bottom: 8.0, right: 5, left: 5, top: 2),
            child: Column(
              children: [
                // Artwork container with fixed size 185x185
                const SizedBox(
                  height: 185,
                  width: 185,
                  child: Icon(
                    Icons.music_note_rounded,
                    color: whiteColor,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 8),
                // Album title - font size 16
                Text(
                  _favourites.keys.toList()[index],
                  style: const TextStyle(
                    color: whiteColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Artist name - font size 12

                // Remaining space ~12px for future use
              ],
            ),
          ),
        ));
  }
}
