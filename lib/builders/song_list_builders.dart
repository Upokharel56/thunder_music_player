import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:thunder_audio_player/consts/colors.dart';
import 'package:thunder_audio_player/controllers/music_controller.dart';

mixin SongListBuilders {
  final MusicController controller = Get.find<MusicController>();

  Widget buildSongList({
    AsyncSnapshot<List<SongModel>>? snapshot,
    List<SongModel>? songList,
  }) {
    final List<SongModel> songs = songList ?? snapshot?.data ?? [];

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: songs.length,
      itemBuilder: (BuildContext context, int index) {
        return buildSongItem(songs: songs, index: index);
      },
    );
  }

  Widget buildSongItem({
    required List<SongModel> songs,
    required int index,
    bool isUpcomingList = false,
  }) {
    final song = songs[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 5, right: 8, left: 3),
      child: Obx(
        () => ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          onTap: () {
            // Start playback and open the player as a modal overlay
            if (!isUpcomingList) {
              controller.startNewStream(songs, index);
              controller.isMiniPlayerActive.value = true;
              return;
            }
            controller.playSongAt(index);
          },
          tileColor: bgColor,
          title: Text(
            song.title,
            style: const TextStyle(fontSize: 16, color: whiteColor),
          ),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  "< ${song.artist ?? "Unknown"} >",
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 12,
                    color: whiteColor,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 3),
              Expanded(
                flex: 1,
                child: FittedBox(
                  clipBehavior: Clip.antiAlias,
                  fit: BoxFit.scaleDown,
                  child: Text(
                    _getFormattedDuration(song.duration),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: whiteColor),
                  ),
                ),
              ),
            ],
          ),
          leading: QueryArtworkWidget(
            id: song.id,
            type: ArtworkType.AUDIO,
            nullArtworkWidget: const Icon(
              Icons.music_note_rounded,
              color: whiteColor,
              size: 35,
            ),
            artworkHeight: 55,
            artworkWidth: 50,
            artworkBorder: const BorderRadius.all(Radius.circular(8)),
          ),
          trailing:
              controller.currentIndex == index && controller.isPlaying.value
                  ? const Icon(
                      Icons.pause_circle,
                      color: whiteColor,
                      size: 38,
                    )
                  : null,
        ),
      ),
    );
  }

// Helper function for formatting duration
  String _getFormattedDuration(int? duration) {
    if (duration == null) return '0:00';

    final durationInSeconds = duration ~/ 1000;
    final minutes =
        ((durationInSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final seconds = (durationInSeconds % 60).toString().padLeft(2, '0');

    return '$minutes:$seconds';
  }
}
