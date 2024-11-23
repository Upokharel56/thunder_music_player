import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:thunder_audio_player/builders/song_list_builders.dart'
    show SongListBuilders;
import 'package:thunder_audio_player/consts/colors.dart';
import 'package:thunder_audio_player/screens/current_song_screen/details_screen.dart';
import 'package:thunder_audio_player/screens/current_song_screen/normal_lyrics_screen.dart';
import 'package:thunder_audio_player/screens/current_song_screen/synced_lyrics_screen.dart';
import 'package:thunder_audio_player/screens/current_song_screen/upcoming_songs_list.dart';
import 'package:thunder_audio_player/screens/mini_music_player.dart';
import 'package:thunder_audio_player/utils/loggers.dart';

class MusicPlayerBottomNav extends StatefulWidget {
  const MusicPlayerBottomNav({super.key});

  @override
  _MusicPlayerBottomNavState createState() => _MusicPlayerBottomNavState();
}

class _MusicPlayerBottomNavState extends State<MusicPlayerBottomNav>
    with SongListBuilders {
  final RxInt selectedIndex = 0.obs;
  // final MusicController controller = Get.find<MusicController>();

  @override
  Widget build(BuildContext context) {
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
        showFullScreenPopup();
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        if (details.primaryVelocity! < 0) {
          selectedIndex.value = index == 2 ? index : index + 1;
        } else if (details.primaryVelocity! > 0) {
          selectedIndex.value = index == 0 ? index : index - 1;
        }
      },
      child: Column(
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
          height: MediaQuery.of(context).size.height * 0.99,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MiniMusicPlayer(
                tapAction: () {
                  Navigator.pop(context);
                },
              ),
              Obx(
                () => Container(
                  padding: const EdgeInsets.only(
                      top: 3, left: 20, right: 20, bottom: 10),
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
              Flexible(
                fit: FlexFit.loose,
                child: Obx(() {
                  switch (selectedIndex.value) {
                    case 0:
                      return GestureDetector(
                          onHorizontalDragEnd: (DragEndDetails details) {
                            if (details.primaryVelocity! < 0) {
                              // Swiped right
                              selectedIndex.value = 1;
                            }
                          },
                          child: UpcomingSongDetails());
                    case 1:
                      return GestureDetector(
                        onHorizontalDragEnd: (DragEndDetails details) {
                          if (details.primaryVelocity! < 0) {
                            // Swiped Right
                            selectedIndex.value = 2;
                          } else if (details.primaryVelocity! > 0) {
                            //Swiped left
                            selectedIndex.value = 0;
                          }
                        },
                        child: Obx(() {
                          msg("Lyrics screen selected \n Synced: ${controller.isSyncedLyrics.value}",
                              tag: 'Lyrics Screen builder');
                          if (controller.isSyncedLyrics.value) {
                            return SyncedLyricsScreen(
                                rawLyrics: controller.lyrics.value);
                          } else {
                            return NormalLyricsScreen(
                                lyrics: controller.lyrics.value);
                          }
                        }),
                      );
                    case 2:
                      return GestureDetector(
                          onHorizontalDragEnd: (DragEndDetails details) {
                            if (details.primaryVelocity! > 0) {
                              // Swiped Right
                              selectedIndex.value = 1;
                            }
                          },
                          child: SongDetailsScreen());
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
        selectedIndex.value = index;
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        if (details.primaryVelocity! < 0) {
          selectedIndex.value = index == 2 ? index : index + 1;
        } else if (details.primaryVelocity! > 0) {
          selectedIndex.value = index == 0 ? index : index - 1;
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            child: Text(
              label,
              style: TextStyle(
                color: whiteColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: isSelected ? 24 : 20,
              ),
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
}
