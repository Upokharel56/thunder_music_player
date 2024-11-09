import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:thunder_audio_player/consts/colors.dart';
import 'package:thunder_audio_player/controllers/music_controller.dart';
import 'package:thunder_audio_player/screens/music_player.dart';

mixin MusicPlayerBottomNav {
  final RxInt selectedIndex = 0.obs; // Track selected index

  final MusicController controller = Get.find<MusicController>();

  Widget buildBottomNavigationBar() {
    return Obx(
      () => Container(
        color: bgColor,
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
              MediaQuery.of(context).size.height * 0.95, // Nearly full screen
          child: Column(
            children: [
              // Top close icon
              Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: IconButton(
                  icon: const Icon(Icons.keyboard_arrow_down,
                      color: whiteColor, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              // Internal navigation bar
              Obx(
                () => Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  color: bgColor,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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

  Widget _build_upNext_state() {
    final snapshot = controller.songs;
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: snapshot.length,
      itemBuilder: (BuildContext context, int index) {
        return _buildSongItem(snapshot, index);
      },
    );
  }

  Widget _buildSongItem(List<SongModel> upcomingSongsList, int index) {
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
                style: const TextStyle(fontSize: 12, color: whiteColor),
              ),
              Text(
                _getFormattedDuration(song.duration),
                style: const TextStyle(fontSize: 12, color: whiteColor),
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

  Widget _build_lyrics_state() {
    return const Center(
      child: Text("Inside Lyrics",
          style: TextStyle(color: whiteColor, fontSize: 18)),
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
