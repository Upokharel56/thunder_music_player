import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:thunder_audio_player/controllers/music_controller.dart';
import 'package:thunder_audio_player/consts/colors.dart';

class ScreenUtils {
  final MusicController controller = Get.put(MusicController());

  Widget buildSongItem(List<SongModel> upcomingSongsList, int index) {
    final song = upcomingSongsList[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 5, right: 8, left: 3),
      child: Obx(
        () => ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          onTap: () {
            controller.playSongAt(index);
          },
          tileColor: bgColor,
          title: Text(
            song.title,
          ),
          subtitle: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                song.artist ?? "Unknown",
                style: TextStyle(fontSize: 12, color: whiteColor),
              ),
              Text(
                getFormattedDuration(song.duration),
                style: TextStyle(fontSize: 12, color: whiteColor),
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
                  ? IconButton(
                      icon: const Icon(Icons.stop_circle,
                          color: whiteColor, size: 30),
                      color: whiteColor,
                      onPressed: () {
                        controller.pause();
                      },
                    )
                  : null,
        ),
      ),
    );
  }

  String getFormattedDuration(int? duration) {
    if (duration == null) return '0:00';

    final durationInSeconds = duration ~/ 1000;
    final hours = (durationInSeconds ~/ 3600).toString().padLeft(2, '0');
    final minutes =
        ((durationInSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final seconds = (durationInSeconds % 60).toString().padLeft(2, '0');

    if (hours == "00") {
      return '$minutes:$seconds';
    }
    return '$hours:$minutes:$seconds';
  }
}
