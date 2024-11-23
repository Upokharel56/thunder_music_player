import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:on_audio_query/on_audio_query.dart';
import 'package:thunder_audio_player/builders/song_list_builders.dart';
import 'package:thunder_audio_player/controllers/storage/favouraite_songs_controller.dart';

class FavouraitesSongsPage extends StatefulWidget {
  const FavouraitesSongsPage({super.key});

  @override
  State<FavouraitesSongsPage> createState() => _FavouraitesSongsPageState();
}

class _FavouraitesSongsPageState extends State<FavouraitesSongsPage>
    with SongListBuilders {
  final FavouriteSongsController favController =
      Get.find<FavouriteSongsController>();

  @override
  void initState() {
    super.initState();
    // _loadSongs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favourite Songs'),
      ),
      body: Obx(() {
        final favouriteSongs = favController.favouriteSongs;
        if (favouriteSongs.isEmpty) {
          return const Center(
            child: Text('No favourite songs'),
          );
        } else {
          return buildSongList(songList: favouriteSongs);
        }
      }),
    );
  }
}
