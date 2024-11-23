import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:thunder_audio_player/builders/song_list_builders.dart';
import 'package:thunder_audio_player/consts/colors.dart';
import 'package:thunder_audio_player/screens/mini_music_player.dart';
import 'package:thunder_audio_player/screens/music_player.dart';

class SongListScreen extends StatefulWidget {
  final List<String>? songFetchPaths;
  final String title;

  const SongListScreen(
      {super.key, this.songFetchPaths, this.title = 'All Songs'});

  @override
  _SongListScreenState createState() => _SongListScreenState();
}

class _SongListScreenState extends State<SongListScreen>
    with
        SongListBuilders,
        AutomaticKeepAliveClientMixin,
        SingleTickerProviderStateMixin {
  final OnAudioQuery audioQuery = OnAudioQuery();

  List<SongModel> songList = [];
  // final String _sortValue = 'name';
  SongSortType _sortType = SongSortType.DATE_ADDED;
  OrderType _orderType = OrderType.DESC_OR_GREATER;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSongs();
  }

  Future<void> _loadSongs() async {
    songList = await _getSongList();
    songList = (await getFilteredSongList(songList));

    isLoading = false;
    setState(() {});
  }

  Future<List<SongModel>> getFilteredSongList(List<SongModel> songList) async {
    List<SongModel> filteredSongs = songList.where((song) {
      String filePath = song.data;

      // Exclude hidden paths

      // Check inclusion criteria uncomment to add whitelists only
      // bool isIncluded = includeFolders.isEmpty
      //     ? true
      //     : includeFolders.any((folder) => filePath.startsWith(folder));

      // Check exclusion criteria
      bool isInFavorites =
          widget.songFetchPaths!.any((folder) => filePath.startsWith(folder));

      // Include the song only if it's included and not excluded
      return isInFavorites;
    }).toList();

    return filteredSongs;
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Stack(children: [
        _buildMainBody(),
        Obx(() {
          return controller.isMiniPlayerActive.value
              ? Align(
                  alignment: Alignment.bottomCenter,
                  child: GestureDetector(
                    onVerticalDragUpdate: (details) {
                      if (details.primaryDelta! < -10) {
                        _showMusicPlayerModal(context, songs: controller.songs);
                      }
                    },
                    child: MiniMusicPlayer(
                      showDismiss: true,
                      tapAction: () {
                        _showMusicPlayerModal(context, songs: controller.songs);
                      },
                    ),
                  ),
                )
              : const SizedBox.shrink();
        })
      ]),
    );
  }

  Widget _buildMainBody() {
    return RefreshIndicator(
      onRefresh: () async {
        // Force a rebuild by calling setState
        setState(() {});
        await Future.delayed(const Duration(milliseconds: 300));
        return Future.value();
      },
      child: Column(
        children: [
          // Safe area padding for top
          // SizedBox(height: MediaQuery.of(context).padding.top),
          // Dropdown button in a contained row
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
                )
              ],
            ),
          ),
          // Expanded list view
          Expanded(
            child: _buildSongsLayout(),
          ),
        ],
      ),
    );
  }

  Widget _buildSortDropDownBtn() {
    return Container(
      alignment: Alignment.topRight,
      margin: const EdgeInsets.only(top: 5, right: 5),
      child: DropdownButton<String>(
        value: 'date',
        onChanged: (String? newValue) {
          setState(() {
            updateSortType(newValue!);
            _sortList();
          });
        },
        dropdownColor: bgColor,
        items: _getDropDownItems(),
        icon: IconButton(
          onPressed: () {
            setState(() {
              _orderType = _orderType == OrderType.ASC_OR_SMALLER
                  ? OrderType.DESC_OR_GREATER
                  : OrderType.ASC_OR_SMALLER;
              songList = songList.reversed.toList();
            });
          },
          icon: _orderType == OrderType.ASC_OR_SMALLER
              ? const Icon(Icons.arrow_upward)
              : const Icon(Icons.arrow_downward),
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> _getDropDownItems() {
    return [
      const DropdownMenuItem(
        value: 'date',
        child: Text(
          'Date Added',
        ),
      ),
      const DropdownMenuItem(
        value: 'name',
        child: Text(
          'Name',
        ),
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

  void updateSortType(String sortType) {
    switch (sortType) {
      case 'date':
        _sortType = SongSortType.DATE_ADDED;
        break;
      case 'name':
        _sortType = SongSortType.TITLE;
        break;
      case 'time':
        _sortType = SongSortType.DURATION;
        break;
      case 'artist':
        _sortType = SongSortType.ARTIST;
        break;
      case 'album':
        _sortType = SongSortType.ALBUM;
        break;
    }
  }

  Future<List<SongModel>> _getSongList() {
    return audioQuery.querySongs(
      ignoreCase: true,
      orderType: OrderType.DESC_OR_GREATER,
      sortType: _sortType,
      uriType: UriType.EXTERNAL,
    );
  }

  Widget _buildSongsLayout() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (songList.isEmpty) {
      return const Center(child: Text('No songs found'));
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: buildSongList(
          snapshot: AsyncSnapshot.withData(
        ConnectionState.done,
        songList,
      )),
    );
  }

  void _sortList() {
    setState(() {
      switch (_sortType) {
        case SongSortType.DATE_ADDED:
          songList.sort((a, b) => a.dateAdded!.compareTo(b.dateAdded ?? 0));

        case SongSortType.TITLE:
          songList.sort((a, b) => a.title.compareTo(b.title));
        case SongSortType.DURATION:
          songList.sort((a, b) => a.duration?.compareTo(b.duration ?? 0) ?? 0);
        case SongSortType.ARTIST:
          songList.sort((a, b) => (a.artist ?? '').compareTo(b.artist ?? ''));
        case SongSortType.ALBUM:
          songList.sort((a, b) => (a.album ?? '').compareTo(b.album ?? ''));
        default:
          songList.sort((a, b) => a.title.compareTo(b.title));
      }
      if (_orderType == OrderType.DESC_OR_GREATER) {
        songList = songList.reversed.toList();
      }
    });
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
}
