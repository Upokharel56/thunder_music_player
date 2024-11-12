import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:thunder_audio_player/builders/song_list_builders.dart';
import 'package:thunder_audio_player/consts/colors.dart';
// import 'package:thunder_audio_player/controllers/music_controller.dart';
import 'package:thunder_audio_player/utils/mini_player.dart';

mixin MusicPlayerBottomNav implements MiniPlayer, SongListBuilders {
  // final MusicController controller = Get.find<MusicController>();
  final RxInt selectedIndex = 0.obs; // Track selected index

  Widget buildBottomNavigationBar() {
    return Obx(
      () => Container(
        color: bgColor,
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem("Up next", 0),
            _buildNavItem("Lyrics", 1),
            _buildNavItem("Details", 2),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(String label, int index) {
    final isSelected = selectedIndex.value == index;
    return GestureDetector(
      onTap: () {
        selectedIndex.value = index;
        showFullScreenPopup(); // Show full-screen popup when tapped
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: whiteColor,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: isSelected ? 16 : 14,
            ),
          ),
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(top: 4),
              height: 2,
              width: 40,
              color: whiteColor,
            ),
        ],
      ),
    );
  }

  void showFullScreenPopup() {
    showModalBottomSheet(
      context: Get.context!,
      backgroundColor: bgColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SizedBox(
          height:
              MediaQuery.of(context).size.height * 0.99, // Nearly full screen
          child: Column(
            children: [
              // Mini music player bar with music info and controls
              buildMiniPlayer(context, tapAction: () {
                Navigator.pop(context);
              }),
              // Internal navigation bar
              Obx(
                () => Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  color: lightBlack,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildModalNavItem("Up next", 0),
                      _buildModalNavItem("Lyrics", 1),
                      _buildModalNavItem("Details", 2),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Main body content based on selected index
              Expanded(
                child: Obx(() {
                  switch (selectedIndex.value) {
                    case 0:
                      return _build_upNext_state();
                    case 1:
                      return _build_lyrics_state();
                    case 2:
                      return _build_details_state();
                    default:
                      return Container();
                  }
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModalNavItem(String label, int index) {
    final isSelected = selectedIndex.value == index;
    return GestureDetector(
      onTap: () {
        selectedIndex.value = index; // Update the selected index
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: whiteColor,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: isSelected ? 18 : 15,
            ),
          ),
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(top: 4),
              height: 3,
              width: 50,
              color: whiteColor,
            ),
        ],
      ),
    );
  }

  Widget _build_upNext_state() {
    final songList = controller.songs;
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: songList.length,
      itemBuilder: (BuildContext context, int index) {
        return buildSongItem(songs: songList, index: index);
      },
    );
  }

  Widget _build_lyrics_state() {
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 12, right: 8, bottom: 8),
      child: Obx(() {
        return ListView.builder(
          itemCount: controller.lyricsLines.length,
          itemBuilder: (context, index) {
            final isActive = index == controller.currentLineIndex.value;
            final line = controller.lyricsLines[index];
            return Text(
              line.lyrics,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isActive ? 18 : 16,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? Colors.blueAccent : Colors.white,
              ),
            );
          },
        );
      }),
    );
  }

  Widget _build_details_state() {
    return const Center(
      child: Text("Inside Details",
          style: TextStyle(color: whiteColor, fontSize: 18)),
    );
  }

  String _getFormattedDuration(int? duration) {
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
