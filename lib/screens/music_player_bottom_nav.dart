import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:thunder_audio_player/consts/colors.dart';
import 'package:thunder_audio_player/controllers/music_controller.dart';
import 'package:thunder_audio_player/screens/current_song_screen/details_screen.dart';
import 'package:thunder_audio_player/screens/current_song_screen/synced_lyrics_screen.dart';
import 'package:thunder_audio_player/screens/current_song_screen/upcoming_songs_list.dart';
import 'package:thunder_audio_player/screens/mini_music_player.dart';
import 'package:thunder_audio_player/utils/loggers.dart';

class BottomNavController extends GetxController {
  final RxInt selectedIndex = 0.obs;

  void updateIndex(int index) {
    selectedIndex.value = index;
  }

  void navigateBySwipe(DragEndDetails details, {required int maxIndex}) {
    if (details.primaryVelocity! < 0 && selectedIndex.value < maxIndex) {
      selectedIndex.value++;
    } else if (details.primaryVelocity! > 0 && selectedIndex.value > 0) {
      selectedIndex.value--;
    }
  }
}

class MusicPlayerBottomNav extends StatelessWidget {
  final BottomNavController controller = Get.put(BottomNavController());

  MusicPlayerBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }

  Widget _buildNavItem(String label, int index) {
    return GestureDetector(
      onTap: () {
        controller.updateIndex(index);
        _showFullScreenPopup();
      },
      onHorizontalDragEnd: (details) {
        controller.navigateBySwipe(details, maxIndex: 2);
      },
      child: Obx(() {
        final isSelected = controller.selectedIndex.value == index;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: whiteColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: isSelected ? 22 : 18,
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
        );
      }),
    );
  }

  void _showFullScreenPopup() {
    Get.bottomSheet(
      SizedBox(
        height: Get.height * 0.99,
        child: Column(
          children: [
            MiniMusicPlayer(
              tapAction: () => Get.back(),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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
            const SizedBox(height: 20),
            Expanded(
              child: Obx(() {
                return GestureDetector(
                  onHorizontalDragEnd: (details) {
                    controller.navigateBySwipe(details, maxIndex: 2);
                  },
                  child: _buildScreenForIndex(controller.selectedIndex.value),
                );
              }),
            ),
          ],
        ),
      ),
      backgroundColor: bgColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  Widget _buildModalNavItem(String label, int index) {
    return GestureDetector(
      onTap: () => controller.updateIndex(index),
      onHorizontalDragEnd: (details) {
        controller.navigateBySwipe(details, maxIndex: 2);
      },
      child: Obx(() {
        final isSelected = controller.selectedIndex.value == index;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: whiteColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: isSelected ? 24 : 20,
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
        );
      }),
    );
  }

  Widget _buildScreenForIndex(int index) {
    switch (index) {
      case 0:
        return UpcomingSongDetails();
      case 1:
        return Obx(() {
          final controller = Get.find<MusicController>();
          msg("Lyrics screen selected \n Synced: ${controller.isSyncedLyrics.value}",
              tag: 'Lyrics Screen builder');
          return LyricsScreen();
        });
      case 2:
        return SongDetailsScreen();
      default:
        return Container();
    }
  }
}
