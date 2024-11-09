import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:thunder_audio_player/controllers/music_controller.dart';
import 'package:thunder_audio_player/consts/colors.dart';
import 'package:thunder_audio_player/screens/music_player_bottom_nav.dart';

class MusicPlayer extends StatelessWidget with MusicPlayerBottomNav {
  final List<SongModel> data;
  final MusicController controller = Get.find<MusicController>();

  MusicPlayer({super.key, required this.data});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        foregroundColor: whiteColor,
      ),
      body: _build_body(),
      bottomNavigationBar: buildBottomNavigationBar(),
    );
  }

  Widget _build_body() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Container(
            height: 450,
            child: _buildArtworkDetails(),
          ),
          const Expanded(child: SizedBox()),
          _buildAudioController(),
        ],
      ),
    );
  }

  Widget _buildArtworkDetails() {
    return Expanded(
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(5),
        decoration: const BoxDecoration(color: bgColor),
        child: Column(
          children: [
            Obx(() => _buildArtworkContainer()),
            _buildAudioDetails(),
          ],
        ),
      ),
    );
  }

  Widget _buildArtworkContainer() {
    return Container(
      height: controller.isPlaying.value ? 300 : 230,
      width: controller.isPlaying.value ? 300 : 230,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(35)),
      ),
      child: QueryArtworkWidget(
        id: data[controller.currentIndex.value].id,
        artworkQuality: FilterQuality.high,
        // artworkHeight: 330,
        // artworkWidth: 330,
        type: ArtworkType.AUDIO,
        artworkFit: BoxFit.contain,
        nullArtworkWidget: const Icon(
          Icons.music_note,
          size: 100,
          color: whiteColor,
        ),
      ),
    );
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
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.playlist_add,
            color: whiteColor,
            size: 24,
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.favorite_border,
            color: whiteColor,
            size: 24,
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.volume_up_rounded,
            color: whiteColor,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSlider() {
    return Row(
      children: [
        Text(controller.position.value,
            style: TextStyle(fontSize: 12, color: whiteColor)),
        Expanded(
          child: Slider(
            thumbColor: sliderColor,
            inactiveColor: whiteColor,
            activeColor: sliderColor,
            min: const Duration(seconds: 0).inSeconds.toDouble(),
            max: controller.max.value,
            value: controller.value.value,
            onChanged: (newValue) {
              controller.seekDuration(newValue.toInt());
            },
          ),
        ),
        Text(controller.duration.value,
            style: TextStyle(fontSize: 12, color: whiteColor)),
      ],
    );
  }

  Widget _buildControllerButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.shuffle,
            color: whiteColor,
          ),
        ),
        IconButton(
          onPressed: () {
            if (controller.currentIndex.value > 0) {
              controller.playSongAt(controller.currentIndex.value - 1);
            }
          },
          icon: const Icon(
            Icons.skip_previous,
            size: 40,
            color: whiteColor,
          ),
        ),
        IconButton(
          onPressed: () {
            if (controller.isPlaying.value) {
              controller.pause();
            } else {
              controller.play();
            }
          },
          icon: controller.isPlaying.value
              ? const Icon(
                  Icons.pause,
                  size: 55,
                  color: whiteColor,
                )
              : const Icon(
                  Icons.play_arrow,
                  size: 55,
                  color: whiteColor,
                ),
        ),
        IconButton(
          onPressed: () {
            if (controller.currentIndex.value < data.length - 1) {
              controller.playSongAt(controller.currentIndex.value + 1);
            }
          },
          icon: const Icon(
            Icons.skip_next,
            size: 40,
            color: whiteColor,
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.repeat,
            color: whiteColor,
          ),
        ),
      ],
    );
  }
}
