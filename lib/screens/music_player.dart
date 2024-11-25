import 'package:auto_size_text/auto_size_text.dart' show AutoSizeText;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:thunder_audio_player/builders/song_list_builders.dart';
import 'package:thunder_audio_player/consts/colors.dart';
import 'package:thunder_audio_player/controllers/storage/favouraite_songs_controller.dart';
import 'package:thunder_audio_player/pages/inside_screen.dart';
import 'package:thunder_audio_player/screens/music_player_bottom_nav.dart';

class MusicPlayer extends StatelessWidget with SongListBuilders {
  // List<SongModel> controller.songs
  final ScrollController? scrollController;

  final FavouriteSongsController favController =
      Get.find<FavouriteSongsController>();

  MusicPlayer({super.key, this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: _buildPlayerAppBar(),
      body: _build_body(),
      bottomNavigationBar: MusicPlayerBottomNav(),
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
        onDoubleTapDown: (TapDownDetails details) {
          final RenderBox box = Get.context!.findRenderObject() as RenderBox;
          final Offset localOffset = box.globalToLocal(details.globalPosition);
          final double halfWidth = box.size.width / 2;
          final double centerRange =
              box.size.width * 0.1; // 10% range around the center

          if (localOffset.dx > halfWidth - centerRange &&
              localOffset.dx < halfWidth + centerRange) {
            controller.togglePlay();
          } else if (localOffset.dx > halfWidth) {
            // Double-tapped on the right side
            controller.seekDuration(10);
          } else {
            // Double-tapped on the left side
            controller.seekDuration(-10);
          }
        },
        child: Container(
          height: controller.isPlaying.value ? 350 : 280,
          width: controller.isPlaying.value ? 350 : 280,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(35)),
            color: blackColor,
          ),
          child: QueryArtworkWidget(
            id: controller.songs[controller.currentIndex.value].id,
            artworkQuality: FilterQuality.high,
            format: ArtworkFormat.PNG,
            type: ArtworkType.AUDIO,
            artworkFit: BoxFit.contain,
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
            controller.songs[controller.currentIndex.value].displayNameWOExt,
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
            controller.songs[controller.currentIndex.value].artist ??
                "Unknown Artist",
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
        Obx(() {
          bool isFav = favController
              .contains(controller.songs[controller.currentIndex.value].id);

          return Tooltip(
            message: isFav ? 'Add to Favorites' : 'Remove from Favorites',
            textAlign: TextAlign.center,
            triggerMode: TooltipTriggerMode.longPress,
            child: IconButton(
              onPressed: () {
                if (!isFav) {
                  favController
                      .addSong(controller.songs[controller.currentIndex.value]);
                } else {
                  favController.removeSong(
                      controller.songs[controller.currentIndex.value].id);
                }
              },
              icon: Icon(
                Icons.favorite_border,
                color: isFav ? redColor : whiteColor,
                size: 24,
              ),
            ),
          );
        }),
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
      title: Obx(() {
        try {
          return Text(
            controller.currentAudioInfo['title'],
            style: const TextStyle(
              color: whiteColor,
              fontSize: 16,
            ),
          );
        } catch (e) {
          return const Text('Thunder Storm ');
        }
      }),
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
          child: PopupMenuButton<String>(
              itemBuilder: (context) => _build_more_options_layout(context),
              onSelected: (value) => handleMoreOptions(value)),
        ),
      ],
    );
  }

  handleMoreOptions(value) {
    switch (value) {
      case 'Go to Artist':
        MaterialPageRoute(
            builder: (context) => InsideScreen(
                  model: {
                    'id': controller
                        .songs[controller.currentIndex.value].artistId,
                  },
                  type: AudioModelType.artist,
                ));
        break;
      case 'Go to Album':
        MaterialPageRoute(
            builder: (context) => InsideScreen(
                  model: {
                    'id':
                        controller.songs[controller.currentIndex.value].albumId,
                  },
                  type: AudioModelType.album,
                ));
        break;
      case 'Song Info':
        showInfoDialog();
        break;
      case 'Speed':
        showPlaybackSpeedDialog();
        break;
      default:
        break;
    }
  }

  List<PopupMenuEntry<String>> _build_more_options_layout(context) {
    return [
      const PopupMenuItem<String>(
        value: 'Go to Artist',
        child: Text('Go to Artist'),
      ),
      const PopupMenuItem<String>(
        value: 'Go to Album',
        child: Text('Go to Album'),
      ),
      const PopupMenuItem<String>(
        value: 'Song Info',
        child: Text('Song Info'),
      ),
      const PopupMenuItem<String>(
        value: 'Speed',
        child: Text('Speed'),
      ),
    ];
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

  Future<void> showPlaybackSpeedDialog() async {
    await Get.dialog(
      Dialog(
        insetAnimationDuration: Durations.short4,
        backgroundColor: blackColor,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Playback Speed',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: blackColor,
                ),
              ),
              const SizedBox(height: 4),
              Slider(
                value: controller.playbackspeed.value,
                onChanged: (value) {
                  controller.changePlaybackSpeed(value);
                },
                min: 0.5,
                max: 2.0,
                divisions: 15,
                label: controller.playbackspeed.value.toStringAsFixed(1),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }
}
