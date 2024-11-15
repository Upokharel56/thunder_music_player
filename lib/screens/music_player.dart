import 'package:auto_size_text/auto_size_text.dart' show AutoSizeText;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:thunder_audio_player/builders/song_list_builders.dart';
import 'package:thunder_audio_player/controllers/music_controller.dart';
import 'package:thunder_audio_player/consts/colors.dart';
import 'package:thunder_audio_player/screens/music_player_bottom_nav.dart';
import 'package:thunder_audio_player/utils/mini_player.dart';
// import '../utils/loggers.dart';

class MusicPlayer extends StatelessWidget
    with MusicPlayerBottomNav, MiniPlayer, SongListBuilders {
  final List<SongModel> data;
  final ScrollController? scrollController;
  @override
  // final MusicController controller = Get.find<MusicController>();

  MusicPlayer({super.key, required this.data, this.scrollController});

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: _buildPlayerAppBar(),
      body: _build_body(),
      bottomNavigationBar: buildBottomNavigationBar(),
    );
  }

  Widget _build_body() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          SizedBox(
            height: 450,
            child: _buildArtworkDetails(),
          ),
          const Spacer(),
          _buildAudioController(),
        ],
      ),
    );
  }

  Widget _buildArtworkDetails() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(5),
      decoration: const BoxDecoration(color: bgColor),
      child: Column(
        children: [
          Obx(() => _buildArtworkContainer()),
          _buildAudioDetails(),
        ],
      ),
    );
  }

  Widget _buildArtworkContainer() {
    return GestureDetector(
        onHorizontalDragEnd: (DragEndDetails details) {
          if (details.primaryVelocity! < 0) {
            // Swiped Left - Next Song
            controller.next();
          } else if (details.primaryVelocity! > 0) {
            // Swiped Right - Previous Song
            controller.previous();
          }
        },
        child: Container(
          height: controller.isPlaying.value ? 300 : 230,
          width: controller.isPlaying.value ? 300 : 230,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(35)),
            color: blackColor,
          ),
          child: QueryArtworkWidget(
            id: data[controller.currentIndex.value].id,
            artworkQuality: FilterQuality.high,
            // artworkHeight: 330,
            // artworkWidth: 330,
            type: ArtworkType.AUDIO,
            artworkFit: BoxFit.contain,
            // artworkColor: blackColor,
            nullArtworkWidget: const Icon(
              Icons.music_note,
              size: 100,
              color: whiteColor,
            ),
          ),
        ));
  }

  Widget _buildAudioDetails() {
    return Column(
      children: [
        Obx(
          () => AutoSizeText(
            data[controller.currentIndex.value].displayNameWOExt,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            minFontSize: 15,
            style: const TextStyle(fontSize: 20),
            maxFontSize: 50,
          ),
        ),
        Obx(
          () => AutoSizeText(
            data[controller.currentIndex.value].artist ?? "Unknown Artist",
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 15),
            minFontSize: 10,
            maxFontSize: 30,
          ),
        ),
      ],
    );
  }

  Widget _buildAudioController() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildPlaylistOptions(),
        const SizedBox(height: 2),
        Obx(() => _buildTimeSlider()),
        const SizedBox(height: 10),
        Obx(() => _buildControllerButtons()),
      ],
    );
  }

  Widget _buildPlaylistOptions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Tooltip(
          message: 'Add to Playlist',
          textAlign: TextAlign.center,
          triggerMode: TooltipTriggerMode.longPress,
          child: IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.playlist_add,
              color: whiteColor,
              size: 24,
            ),
          ),
        ),
        Tooltip(
          message: 'Add to Favorites',
          textAlign: TextAlign.center,
          triggerMode: TooltipTriggerMode.longPress,
          child: IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.favorite_border,
              color: whiteColor,
              size: 24,
            ),
          ),
        ),
        Tooltip(
          message: 'Adjust Volume',
          textAlign: TextAlign.center,
          triggerMode: TooltipTriggerMode.longPress,
          child: IconButton(
            onPressed: () {
              controller.showVolumeSlider();
            },
            icon: const Icon(
              Icons.volume_up_rounded,
              color: whiteColor,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSlider() {
    return Row(
      children: [
        Text(
          controller.position.value,
          style: const TextStyle(fontSize: 12, color: whiteColor),
        ),
        Expanded(
          child: Slider(
            thumbColor: sliderColor,
            inactiveColor: whiteColor.withOpacity(0.3),
            activeColor: sliderColor,
            min: 0.0,
            max: controller.max.value,
            value: controller.value.value,
            onChanged: (newValue) {
              controller.seekDuration(newValue.toInt());
            },
          ),
        ),
        Text(
          controller.duration.value,
          style: const TextStyle(fontSize: 12, color: whiteColor),
        ),
      ],
    );
  }

  Widget _buildControllerButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Tooltip(
          message: controller.isShuffleActive.value
              ? 'Shuffle is on'
              : 'Shuffle is off',
          textAlign: TextAlign.center,
          triggerMode: TooltipTriggerMode.longPress,
          child: IconButton(
            onPressed: () {
              controller.toggleShuffle();
            },
            icon: Icon(
              controller.isShuffleActive.value ? Icons.shuffle : Icons.shuffle,
              color: controller.isShuffleActive.value ? whiteColor : fadedWhite,
            ),
          ),
        ),
        Tooltip(
          message: 'Previous Song',
          textAlign: TextAlign.center,
          triggerMode: TooltipTriggerMode.longPress,
          child: IconButton(
            onPressed: () {
              controller.previous();
            },
            icon: const Icon(
              Icons.skip_previous,
              size: 40,
              color: whiteColor,
            ),
          ),
        ),
        Tooltip(
          message: controller.isPlaying.value ? 'Pause' : 'Play',
          textAlign: TextAlign.center,
          triggerMode: TooltipTriggerMode.longPress,
          child: IconButton(
              onPressed: () {
                controller.togglePlay();
              },
              icon: Icon(
                controller.isPlaying.value ? Icons.pause : Icons.play_arrow,
                size: 55,
                color: whiteColor,
              )),
        ),
        Tooltip(
          message: 'Next Song',
          textAlign: TextAlign.center,
          triggerMode: TooltipTriggerMode.longPress,
          child: IconButton(
            onPressed: () {
              controller.next();
            },
            icon: const Icon(
              Icons.skip_next,
              size: 40,
              color: whiteColor,
            ),
          ),
        ),
        Tooltip(
          message: controller.isRepeatActive.value
              ? 'Repeat is on'
              : 'Repeat is off',
          textAlign: TextAlign.center,
          triggerMode: TooltipTriggerMode.longPress,
          child: IconButton(
            onPressed: () {
              controller.toggleRepeat();
            },
            icon: Icon(
              controller.isRepeatActive.value
                  ? Icons.repeat
                  : Icons.repeat_one_sharp,
              color: whiteColor,
            ),
          ),
        ),
      ],
    );
  }

  AppBar _buildPlayerAppBar() {
    return AppBar(
      foregroundColor: whiteColor,
      title: const Text('Thunder Storm'),
      leading: Tooltip(
        message: 'Minimize Player',
        textAlign: TextAlign.center,
        triggerMode: TooltipTriggerMode.longPress,
        child: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(Icons.keyboard_arrow_down,
              size: 35, color: whiteColor),
        ),
      ),
      actions: [_buildAppBarActionBtns()],
    );
  }

  Widget _buildAppBarActionBtns() {
    return Row(
      children: [
        Tooltip(
          message: controller.isMuted.value ? 'Unmute' : 'Mute',
          textAlign: TextAlign.center,
          triggerMode: TooltipTriggerMode.longPress,
          child: Obx(() => IconButton(
                onPressed: () {
                  // Single toggle function instead of separate mute/unmute
                  controller.toggleMute();
                },
                icon: Icon(
                  controller.isMuted.value ? Icons.volume_off : Icons.volume_up,
                  color: whiteColor,
                ),
              )),
        ),
        Tooltip(
          message: 'Info',
          textAlign: TextAlign.center,
          triggerMode: TooltipTriggerMode.longPress,
          child: IconButton(
            onPressed: () async {
              await showInfoDialog();
            },
            icon: const Icon(Icons.info_outline, color: whiteColor),
          ),
        ),
        Tooltip(
          message: 'More options',
          textAlign: TextAlign.center,
          triggerMode: TooltipTriggerMode.longPress,
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert, color: whiteColor),
          ),
        ),
      ],
    );
  }

// Helper function to capitalize the first letter
  String capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  Future<void> showInfoDialog() async {
    Map infoMap = controller.currentAudioInfo;

    await Get.dialog(
      Dialog(
        backgroundColor: whiteColor,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(10),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: infoMap.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${capitalize(entry.key)}:',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: blackColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${entry.value}',
                      style: const TextStyle(
                        color: blackColor,
                      ),
                    ),
                    const Divider(color: Colors.white54),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }
}
