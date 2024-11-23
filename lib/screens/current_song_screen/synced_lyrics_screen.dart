import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';

import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:thunder_audio_player/consts/colors.dart';
import 'package:thunder_audio_player/controllers/music_controller.dart';
import 'package:thunder_audio_player/modals/lyric_modal.dart';
import 'package:thunder_audio_player/screens/current_song_screen/normal_lyrics_screen.dart';
import 'package:thunder_audio_player/utils/loggers.dart';

class SyncedLyricsScreen extends StatefulWidget {
  String rawLyrics;

  SyncedLyricsScreen({super.key, required this.rawLyrics});

  @override
  State<SyncedLyricsScreen> createState() => _SyncedLyricsScreenState();
}

class _SyncedLyricsScreenState extends State<SyncedLyricsScreen> {
  List<Lyric>? lyrics;
  final ItemScrollController itemScrollController = ItemScrollController();
  final ScrollOffsetController scrollOffsetController =
      ScrollOffsetController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  final ScrollOffsetListener scrollOffsetListener =
      ScrollOffsetListener.create();
  StreamSubscription? streamSubscription;

  final MusicController controller = Get.find<MusicController>();
  late StreamSubscription<PlayerState> stateStream;

  @override
  void dispose() {
    streamSubscription?.cancel();
    stateStream.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    msg("Inside synced lyrics screen: \n ${widget.rawLyrics}",
        tag: 'Raw Lyrics to parse');

    // Parse the provided raw lyrics
    lyrics = widget.rawLyrics
        .split('\n')
        .map((e) => Lyric(e.split(' ').sublist(1).join(' '),
            DateFormat("[mm:ss.SS]").parse(e.split(' ')[0])))
        .toList();

    // Listen to the player's position changes to sync lyrics
    streamSubscription =
        controller.audioPlayer.positionStream.listen((duration) {
      DateTime dt = DateTime(1970, 1, 1).copyWith(
          hour: duration.inHours,
          minute: duration.inMinutes.remainder(60),
          second: duration.inSeconds.remainder(60));
      if (lyrics != null) {
        for (int index = 0; index < lyrics!.length; index++) {
          if (index > 7 &&
              lyrics![index].timeStamp.isAfter(dt) &&
              lyrics![index - 7].timeStamp.isBefore(dt)) {
            itemScrollController.scrollTo(
                index: index - 7, duration: const Duration(milliseconds: 600));
            break;
          }
        }
      }
    });

    // Listen to the player's new song to reset the lyrics
    stateStream =
        controller.audioPlayer.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        itemScrollController.jumpTo(index: 0);
        if (controller.isSyncedLyrics.value) {
          lyrics!.clear();
          widget.rawLyrics = controller.lyrics.value;
          setState(() {
            lyrics = widget.rawLyrics
                .split('\n')
                .map((e) => Lyric(e.split(' ').sublist(1).join(' '),
                    DateFormat("[mm:ss.SS]").parse(e.split(' ')[0])))
                .toList();
          });
        } else {
          Get.back();
          Get.to(() => NormalLyricsScreen(lyrics: controller.lyrics.value));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: blackColor,
      body: lyrics != null
          ? SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0)
                    .copyWith(top: 20),
                child: StreamBuilder<Duration>(
                    stream: controller.audioPlayer.positionStream,
                    builder: (context, snapshot) {
                      return ScrollablePositionedList.builder(
                        itemCount: lyrics!.length,
                        itemBuilder: (context, index) {
                          Duration duration =
                              snapshot.data ?? const Duration(seconds: 0);
                          DateTime dt = DateTime(1970, 1, 1).copyWith(
                              hour: duration.inHours,
                              minute: duration.inMinutes.remainder(60),
                              second: duration.inSeconds.remainder(60));
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Text(
                              lyrics![index].words,
                              style: TextStyle(
                                color: lyrics![index].timeStamp.isAfter(dt)
                                    ? Colors.white38
                                    : Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                        itemScrollController: itemScrollController,
                        scrollOffsetController: scrollOffsetController,
                        itemPositionsListener: itemPositionsListener,
                        scrollOffsetListener: scrollOffsetListener,
                      );
                    }),
              ),
            )
          : const SizedBox(),
    );
  }
}
