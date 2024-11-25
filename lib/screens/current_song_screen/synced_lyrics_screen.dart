import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:thunder_audio_player/consts/colors.dart';
import 'package:thunder_audio_player/controllers/music_controller.dart';
import 'package:thunder_audio_player/modals/lyric_modal.dart';

class LyricsScreen extends StatelessWidget {
  final MusicController controller = Get.find<MusicController>();

  LyricsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: blackColor,
      body: Obx(() {
        // Check if the lyrics are synced
        if (controller.isSyncedLyrics.value) {
          // Display synced lyrics with scrolling
          return _buildSyncedLyricsScreen();
        } else {
          // Display normal lyrics
          return _buildNormalLyricsScreen();
        }
      }),
    );
  }

  Widget _buildSyncedLyricsScreen() {
    // Parse lyrics from the controller's lyrics value
    final lyrics = controller.lyrics.value
        .split('\n')
        .map((e) => Lyric(e.split(' ').sublist(1).join(' '),
            DateFormat("[mm:ss.SS]").parse(e.split(' ')[0])))
        .toList();

    final ItemScrollController itemScrollController = ItemScrollController();

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0).copyWith(top: 20),
        child: StreamBuilder<Duration>(
          stream: controller.audioPlayer.positionStream,
          builder: (context, snapshot) {
            return ScrollablePositionedList.builder(
              itemCount: lyrics.length,
              itemBuilder: (context, index) {
                Duration duration = snapshot.data ?? const Duration(seconds: 0);
                DateTime dt = DateTime(1970, 1, 1).copyWith(
                    hour: duration.inHours,
                    minute: duration.inMinutes.remainder(60),
                    second: duration.inSeconds.remainder(60));

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    lyrics[index].words,
                    style: TextStyle(
                      color: lyrics[index].timeStamp.isAfter(dt)
                          ? Colors.white38
                          : Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
              itemScrollController: itemScrollController,
            );
          },
        ),
      ),
    );
  }

  Widget _buildNormalLyricsScreen() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            controller.lyrics.value,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
