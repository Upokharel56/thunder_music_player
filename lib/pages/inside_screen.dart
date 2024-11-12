import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:thunder_audio_player/builders/song_list_builders.dart';
import 'package:thunder_audio_player/consts/colors.dart';

enum AudioModelType {
  album,
  artist,
  genre,
  playlist,
}

class InsideScreen extends StatefulWidget {
  final dynamic model;
  final AudioModelType type;

  const InsideScreen({
    super.key,
    required this.model,
    required this.type,
  });

  @override
  State<InsideScreen> createState() => _InsideScreenState();
}

class _InsideScreenState extends State<InsideScreen> with SongListBuilders {
  final OnAudioQuery audioQuery = OnAudioQuery();
  List<SongModel> songList = [];
  late AudiosFromType queryType;

  @override
  void initState() {
    super.initState();
    queryType = _getQueryType(widget.type);
    _loadSongs();
  }

  AudiosFromType _getQueryType(AudioModelType type) {
    switch (type) {
      case AudioModelType.album:
        return AudiosFromType.ALBUM_ID;
      case AudioModelType.artist:
        return AudiosFromType.ARTIST_ID;
      case AudioModelType.genre:
        return AudiosFromType.GENRE_ID;
      case AudioModelType.playlist:
        return AudiosFromType.PLAYLIST;
    }
  }

  Future<void> _loadSongs() async {
    try {
      var results = await audioQuery.queryAudiosFrom(
        queryType,
        widget.model.id,
        sortType: SongSortType.TITLE,
        orderType: OrderType.ASC_OR_SMALLER,
      );
      setState(() {
        songList = results;
      });
    } catch (e) {
      debugPrint('Error loading songs: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildDetailsArtwork(),
            Expanded(child: _buildSongsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsArtwork() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Back button and type
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: whiteColor),
              ),
              const Spacer(),
              Text(
                widget.type.name.toUpperCase(),
                style: const TextStyle(
                  color: whiteColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 20),
          // Artwork
          QueryArtworkWidget(
            id: widget.model.id,
            type: switch (widget.type) {
              AudioModelType.album => ArtworkType.ALBUM,
              AudioModelType.artist => ArtworkType.ARTIST,
              AudioModelType.genre => ArtworkType.GENRE,
              AudioModelType.playlist => ArtworkType.PLAYLIST,
            },
            nullArtworkWidget: Icon(
              switch (widget.type) {
                AudioModelType.album => Icons.album,
                AudioModelType.artist => Icons.person,
                AudioModelType.genre => Icons.queue_music,
                AudioModelType.playlist => Icons.playlist_play,
              },
              color: whiteColor,
              size: 80,
            ),
            artworkHeight: 200,
            artworkWidth: 200,
            artworkBorder: BorderRadius.circular(25),
          ),
          const SizedBox(height: 16),
          // Title
          Text(
            switch (widget.type) {
              AudioModelType.album => widget.model.album,
              AudioModelType.artist => widget.model.artist,
              AudioModelType.genre => widget.model.genre,
              AudioModelType.playlist => widget.model.playlist,
            },
            style: const TextStyle(
              color: whiteColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSongsList() {
    if (songList.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    return buildSongList(
      snapshot: AsyncSnapshot.withData(ConnectionState.done, songList),
    );
  }
}
