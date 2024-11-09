import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';

import 'package:thunder_audio_player/consts/colors.dart';
import 'package:thunder_audio_player/controllers/music_controller.dart';
import 'package:thunder_audio_player/screens/music_player.dart';

class Homepage extends StatefulWidget {
  Homepage({super.key});
  final OnAudioQuery audioQuery = OnAudioQuery();

  final MusicController controller = Get.put(MusicController());

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: _buildHomeAppBar(),
      body: _buildLayout(),
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
            widget.controller.startNewStream(snapshot.data!, index);
            Get.to(
              () => MusicPlayer(data: snapshot.data!),
              transition: Transition.downToUp,
            );
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
                style: TextStyle(fontSize: 12, color: whiteColor),
              ),
              Text(
                _getFormattedDuration(song.duration),
                style: TextStyle(fontSize: 12, color: whiteColor),
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
