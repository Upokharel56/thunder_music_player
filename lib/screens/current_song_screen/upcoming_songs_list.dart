import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:thunder_audio_player/controllers/music_controller.dart';
import 'package:thunder_audio_player/builders/song_list_builders.dart'
    show SongListBuilders;

class UpcomingSongDetails extends StatelessWidget with SongListBuilders {
  UpcomingSongDetails({super.key});

  @override
  final MusicController controller = Get.find<MusicController>();

  @override
  Widget build(BuildContext context) {
    final songList = controller.songs;
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: songList.length,
      itemBuilder: (BuildContext context, int index) {
        return buildSongItem(
            songs: songList, index: index, isUpcomingList: true);
      },
    );
  }
}
