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
              buildMiniPlayer(context),
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

  Widget buildMiniPlayer(context) {
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
                  Navigator.pop(context);
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
              child: _buildMiniControls(),
            ),
          ])); // Main container
    });
  }

  Widget _buildMiniControls() {
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
        )
      ],
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
                  ))
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
