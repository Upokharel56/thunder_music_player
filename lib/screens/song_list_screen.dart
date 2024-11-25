import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:thunder_audio_player/builders/song_list_builders.dart';
import 'package:thunder_audio_player/consts/colors.dart';
import 'package:thunder_audio_player/screens/mini_music_player.dart';
import 'package:thunder_audio_player/screens/music_player.dart';
import 'package:thunder_audio_player/utils/loggers.dart';

class SongListController extends GetxController {
  var songList = <SongModel>[].obs;
  var sortType = 'date'.obs;
  var orderType = OrderType.DESC_OR_GREATER.obs;

  void setSongs(List<SongModel> songs) {
    songList.value = songs;
  }

  void sortSongs(String newSortType) {
    sortType.value = newSortType;
    switch (newSortType) {
      case 'date':
        songList.sort(
            (a, b) => (b.dateModified ?? 0).compareTo(a.dateModified ?? 0));
        break;
      case 'name':
        songList.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'time':
        songList.sort((a, b) => (a.duration ?? 0).compareTo(b.duration ?? 0));
        break;
      case 'artist':
        songList.sort((a, b) => (a.artist ?? '').compareTo(b.artist ?? ''));
        break;
      case 'album':
        songList.sort((a, b) => (a.album ?? '').compareTo(b.album ?? ''));
        break;
    }
  }

  void toggleOrderType() {
    if (orderType.value == OrderType.ASC_OR_SMALLER) {
      orderType.value = OrderType.DESC_OR_GREATER;
      songList.value = songList.reversed.toList();
    } else {
      orderType.value = OrderType.ASC_OR_SMALLER;
      songList.value = songList.reversed.toList();
    }
  }
}

class SongListScreen extends StatelessWidget with SongListBuilders {
  final List<String>? songFetchPaths;
  final String title;

  final SongListController listController = Get.put(SongListController());

  SongListScreen({super.key, this.songFetchPaths, this.title = 'All Songs'});

  final OnAudioQuery audioQuery = OnAudioQuery();

  Future<void> _fetchSongs() async {
    List<SongModel> songs = await audioQuery.querySongs(
      ignoreCase: true,
      orderType: listController.orderType.value,
      sortType: SongSortType.DATE_ADDED,
      uriType: UriType.EXTERNAL,
    );

    msg('Songs fetched: ${songs.length}', tag: 'SongListScreen');
    if (songFetchPaths == null) {
      listController.setSongs(songs);
      return;
    }

    if (songFetchPaths != null && songFetchPaths!.isNotEmpty) {
      songs = songs.where((song) {
        return songFetchPaths!.any((path) => song.data.startsWith(path));
      }).toList();
    }
    listController.setSongs(songs);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
      ),
      body: FutureBuilder<void>(
        future: _fetchSongs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          return Obx(() {
            if (listController.songList.isEmpty) {
              return const Center(child: Text('No songs found'));
            }

            return Stack(
              children: [
                _buildMainBody(listController.songList),
                Obx(() {
                  return controller.isMiniPlayerActive.value
                      ? Align(
                          alignment: Alignment.bottomCenter,
                          child: GestureDetector(
                            onVerticalDragUpdate: (details) {
                              if (details.primaryDelta! < -10) {
                                Get.to(MusicPlayer());
                              }
                            },
                            child: MiniMusicPlayer(
                              showDismiss: true,
                              tapAction: () => Get.to(MusicPlayer()),
                            ),
                          ),
                        )
                      : const SizedBox.shrink();
                }),
              ],
            );
          });
        },
      ),
    );
  }

  Widget _buildMainBody(List<SongModel> songList) {
    return RefreshIndicator(
      onRefresh: () async {
        await _fetchSongs();
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: Text(
                        'Sort by:',
                        style: TextStyle(
                          color: whiteColor,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    _buildSortDropDownBtn(),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: buildSongList(
                snapshot: AsyncSnapshot.withData(
                  ConnectionState.done,
                  songList,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortDropDownBtn() {
    return Obx(() {
      return DropdownButton<String>(
        value: listController.sortType.value,
        onChanged: (String? newValue) {
          if (newValue != null) {
            listController.sortSongs(newValue);
          }
        },
        dropdownColor: bgColor,
        items: _getDropDownItems(),
        icon: IconButton(
          onPressed: () {
            listController.toggleOrderType();
          },
          icon: listController.orderType.value == OrderType.ASC_OR_SMALLER
              ? const Icon(Icons.arrow_upward)
              : const Icon(Icons.arrow_downward),
        ),
      );
    });
  }

  List<DropdownMenuItem<String>> _getDropDownItems() {
    return [
      const DropdownMenuItem(
        value: 'date',
        child: Text('Date Added'),
      ),
      const DropdownMenuItem(
        value: 'name',
        child: Text('Name'),
      ),
      const DropdownMenuItem(
        value: 'time',
        child: Text('Time'),
      ),
      const DropdownMenuItem(
        value: 'artist',
        child: Text('Artist'),
      ),
      const DropdownMenuItem(
        value: 'album',
        child: Text('Album'),
      ),
    ];
  }
}
