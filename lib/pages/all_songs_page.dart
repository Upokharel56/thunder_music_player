import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:thunder_audio_player/builders/song_list_builders.dart';
import 'package:thunder_audio_player/consts/colors.dart';

class AllSongsPage extends StatefulWidget {
  const AllSongsPage({super.key});

  @override
  _AllSongsPageState createState() => _AllSongsPageState();
}

class _AllSongsPageState extends State<AllSongsPage> with SongListBuilders {
  final OnAudioQuery audioQuery = OnAudioQuery();

  List<SongModel> songList = [];
  // final String _sortValue = 'name';
  SongSortType _sortType = SongSortType.TITLE;
  OrderType _orderType = OrderType.ASC_OR_SMALLER;

  @override
  void initState() {
    super.initState();
    _loadSongs();
  }

  Future<void> _loadSongs() async {
    songList = await _getSongList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: bgColor,
        body: RefreshIndicator(
          onRefresh: () async {
            // Force a rebuild by calling setState
            setState(() {});
            await Future.delayed(const Duration(milliseconds: 300));
            return Future.value();
          },
          child: Column(
            children: [
              // Safe area padding for top
              SizedBox(height: MediaQuery.of(context).padding.top),
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
        ));
  }

  Widget _buildSortDropDownBtn() {
    return Container(
      alignment: Alignment.topRight,
      margin: const EdgeInsets.only(top: 5, right: 5),
      child: DropdownButton<String>(
        value: 'name',
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
      orderType: OrderType.ASC_OR_SMALLER,
      sortType: _sortType,
      uriType: UriType.EXTERNAL,
    );
  }

  Widget _buildSongsLayout() {
    if (songList.isEmpty) {
      return const Center(child: CircularProgressIndicator());
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
}
