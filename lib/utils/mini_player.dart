import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:thunder_audio_player/consts/colors.dart';
import 'package:thunder_audio_player/controllers/music_controller.dart';

mixin MiniPlayer {
  final MusicController controller = Get.find<MusicController>();

  Widget buildMiniPlayer(context,
      {currentSong, tapAction, bool showDismiss = false}) {
    return Obx(() {
      final currentSong = controller.songs[controller.currentIndex.value];

      return Container(
          decoration: const BoxDecoration(
            color: blackColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Row(children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  tapAction();
                },
                child: Container(
                  margin: const EdgeInsets.only(left: 5),

                  // const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                  padding: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
                  decoration: BoxDecoration(
                    color: bgDarkColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        height: 55,
                        width: 55,
                        child: QueryArtworkWidget(
                          id: currentSong.id,
                          type: ArtworkType.AUDIO,
                          nullArtworkWidget: const Icon(
                            Icons.music_note,
                            color: whiteColor,
                            size: 35,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              currentSong.title ?? 'Unknown Title',
                              style: const TextStyle(
                                color: whiteColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              currentSong.artist ?? 'Unknown Artist',
                              style: TextStyle(
                                color: whiteColor.withOpacity(0.7),
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Controls outside GestureDetector
            Container(
              // padding: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.only(right: 8),
              child: _buildMiniControls(showDismiss: showDismiss),
            ),
          ])); // Main container
    });
  }

  Widget _buildMiniControls({bool showDismiss = false}) {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            controller.previous();
          },
          icon: const Icon(
            Icons.skip_previous,
            size: 30,
            color: whiteColor,
          ),
        ),
        IconButton(
            onPressed: () {
              controller.togglePlay();
            },
            icon: Icon(
              controller.isPlaying.value ? Icons.pause : Icons.play_arrow,
              size: 35,
              color: whiteColor,
            )),
        IconButton(
          onPressed: () {
            controller.next();
          },
          icon: const Icon(
            Icons.skip_next,
            size: 30,
            color: whiteColor,
          ),
        ),

        //dismiss button only if showDismiss is true
        showDismiss
            ? IconButton(
                onPressed: () {
                  Get.back();
                  controller.stop();
                  controller.isMiniPlayerActive.value = false;
                },
                icon: const Icon(
                  Icons.close,
                  size: 30,
                  color: whiteColor,
                ),
              )
            : const SizedBox(),
      ],
    );
  }
}
