import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';

import 'package:thunder_audio_player/consts/colors.dart';
import 'package:thunder_audio_player/controllers/music_controller.dart';
import 'package:thunder_audio_player/screens/music_player.dart';
import 'package:thunder_audio_player/utils/mini_player.dart';

class Homepage extends StatefulWidget {
  Homepage({super.key});
  final OnAudioQuery audioQuery = OnAudioQuery();

  // @override
  final MusicController controller = Get.put(MusicController());

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> with MiniPlayer {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: _buildHomeAppBar(),
      body: Stack(children: [
        _buildLayout(),
        Obx(() {
          // Show mini player only if a song is playing
          return widget.controller.isMiniPlayerActive.value
              ? Align(
                  alignment: Alignment.bottomCenter,
                  child: GestureDetector(
                    onVerticalDragUpdate: (details) {
                      if (details.primaryDelta! < -10) {
                        _showMusicPlayerModal(context,
                            songs: widget.controller.songs);
                      }
                    },
                    child: buildMiniPlayer(
                      context,
                      showDismiss: true,
                      tapAction: () {
                        _showMusicPlayerModal(context,
                            songs: widget.controller.songs);
                      },
                    ),
                  ),
                )
              : const SizedBox.shrink();
        })
      ]),
    );
  }

  Widget _buildLayout() {
    return FutureBuilder<List<SongModel>>(
        future: widget.audioQuery.querySongs(
          ignoreCase: true,
          orderType: OrderType.ASC_OR_SMALLER,
          sortType: null,
          uriType: UriType.EXTERNAL,
        ),
        builder: (BuildContext context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No songs found"),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildSongList(snapshot),
            );
          }
        });
  }

  AppBar _buildHomeAppBar() {
    return AppBar(
      title: const Text('Thunder Storm'),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(20),
        child: _buildNavLinks(),
      ),
    );
  }

  Widget _buildSongList(AsyncSnapshot<List<SongModel>> snapshot) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: snapshot.data!.length,
      itemBuilder: (BuildContext context, int index) {
        return _buildSongItem(snapshot, index);
      },
    );
  }

  Widget _buildSongItem(AsyncSnapshot<List<SongModel>> snapshot, int index) {
    final song = snapshot.data![index];
    return Container(
      margin: const EdgeInsets.only(bottom: 5, right: 8, left: 3),
      child: Obx(
        () => ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          onTap: () {
            // Start playback and open the player as a modal overlay
            widget.controller.startNewStream(snapshot.data!, index);
            widget.controller.isMiniPlayerActive.value = true;
            // _showMusicPlayerModal(context, songs: snapshot.data!);
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
          trailing: widget.controller.currentIndex == index &&
                  widget.controller.isPlaying.value
              ? const Icon(
                  Icons.pause_circle,
                  color: whiteColor,
                  size: 38,
                )
              : null,
        ),
      ),
    );
  }

  void _showMusicPlayerModal(BuildContext context,
      {List<SongModel> songs = const []}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: bgColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.98, // Full screen
          builder: (_, scrollController) => MusicPlayer(
            data: songs,
            scrollController: scrollController,
          ),
        );
      },
    );
  }

  Widget _buildNavLinks() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          TextButton(
            onPressed: () {},
            child: const Text('Songs', style: TextStyle(fontSize: 18)),
          ),
          TextButton(
            onPressed: () {},
            child: const Text('Albums', style: TextStyle(fontSize: 18)),
          ),
          TextButton(
            onPressed: () {},
            child: const Text('Artists', style: TextStyle(fontSize: 18)),
          ),
          TextButton(
            onPressed: () {},
            child: const Text('Playlists', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
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
