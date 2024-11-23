import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:thunder_audio_player/builders/song_list_builders.dart';

import 'package:thunder_audio_player/consts/colors.dart';
import 'package:thunder_audio_player/controllers/music_controller.dart';
import 'package:thunder_audio_player/pages/all_songs_page.dart';
import 'package:thunder_audio_player/pages/favourite_page.dart';
import 'package:thunder_audio_player/pages/genere_page.dart';
import 'package:thunder_audio_player/controllers/routes_controller.dart';
import 'package:thunder_audio_player/screens/mini_music_player.dart';
import 'package:thunder_audio_player/screens/music_player.dart';
import 'package:thunder_audio_player/utils/loggers.dart';
import 'package:thunder_audio_player/pages/albums_page.dart';
import 'package:thunder_audio_player/pages/artists_page.dart';

class Homepage extends StatefulWidget {
  Homepage({super.key});
  final OnAudioQuery audioQuery = OnAudioQuery();

  final MusicController controller = Get.put(MusicController());
  final RoutesController routesController = Get.put(RoutesController());

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> with SongListBuilders {
  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: true, // or false depending on your needs
        onPopInvokedWithResult: (didPop, result) async {
          // This is where you handle the pop result
          widget.routesController.goBack();
          warn("Did pop: $didPop,\n result: $result", tag: 'PopScope');
          // msg("Did pop: $didPop,\n result: $result");
        },
        child: Scaffold(
          backgroundColor: bgColor,
          appBar: _buildHomeAppBar(),
          body: Stack(children: [
            _buildContentBasedOnRoute(),
            Obx(() {
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
                        child: MiniMusicPlayer(
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
        ));
  }

  Widget _buildContentBasedOnRoute() {
    return Obx(() {
      switch (widget.routesController.activeLink.value) {
        case 'Favourites':
          return const FavouritePage(); // Replace with actual Favourites widget
        case 'Albums':
          return const AlbumsPage(); // Replace with actual Albums widget
        case 'Artists':
          return const ArtistsPage(); // Replace with actual Artists widget
        case 'Playlists':
          return const GenresPage(); // Replace with actual Playlists widget
        default:
          return const AllSongsPage(); // Default to Songs layout
      }
    });
  }

  Widget _buildSongsLayout() {
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
              child: buildSongList(
                  snapshot: snapshot), // Uses the SongListBuilders mixin
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
          initialChildSize: 0.98,
          builder: (_, scrollController) => MusicPlayer(
            data: songs,
            scrollController: scrollController,
          ),
        );
      },
    );
  }

  Widget _buildNavLinks() {
    return Obx(() {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _buildNavLink('Favourites', '/favourites'),
            _buildNavLink('Songs', '/homepage'),
            _buildNavLink('Albums', '/albums'),
            _buildNavLink('Artists', '/artists'),
            _buildNavLink('Playlists', '/playlists'),
          ],
        ),
      );
    });
  }

  Widget _buildNavLink(String title, String route) {
    return TextButton(
      onPressed: () {
        widget.routesController.setActiveLink(title);
        // Navigator.pushNamed(context, route);
      },
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          color: widget.routesController.activeLink.value == title
              ? Colors.green
              : Colors.white,
        ),
      ),
    );
  }
}
