import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:thunder_audio_player/consts/colors.dart';
import 'package:thunder_audio_player/utils/loggers.dart';

class AlbumsPage extends StatefulWidget {
  const AlbumsPage({super.key});

  @override
  State<AlbumsPage> createState() => _AlbumsPageState();
}

class _AlbumsPageState extends State<AlbumsPage> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  List<AlbumModel> albums = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAlbumList();
  }

  _loadAlbumList() async {
    try {
      var result = await _audioQuery.queryAlbums(
        sortType: AlbumSortType.ALBUM,
        orderType: OrderType.ASC_OR_SMALLER,
      );
      setState(() {
        albums = result;
        isLoading = false;
      });
    } catch (e) {
      err('Error loading albums: $e', tag: 'AlbumsError');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (albums.isEmpty) {
      return const Center(child: Text('No albums found'));
    }

    return _buildAlbumLayout();
  }

  Widget _buildAlbumLayout() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate columns based on screen width and fixed item width of 225
        int crossAxisCount = (constraints.maxWidth / 250).floor();
        // Ensure at least 2 and at most 5 columns
        crossAxisCount = crossAxisCount.clamp(2, 5);

        return GridView.builder(
          padding: const EdgeInsets.all(8.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            // Force each item to be exactly 225x225
            childAspectRatio: 0.75,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: albums.length,
          itemBuilder: (context, index) =>
              buildAlbumItem(albums: albums, index: index),
        );
      },
    );
  }

  Widget buildAlbumItem(
      {required List<AlbumModel> albums, required int index}) {
    return Card(
      color: Colors.black12,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0, right: 5, left: 5, top: 2),
        child: Column(
          children: [
            // Artwork container with fixed size 185x185
            SizedBox(
              height: 185,
              width: 185,
              child: QueryArtworkWidget(
                id: albums[index].id,
                type: ArtworkType.ALBUM,
                nullArtworkWidget: const Icon(
                  Icons.music_note_rounded,
                  color: whiteColor,
                  size: 80,
                ),
                artworkBorder: BorderRadius.circular(25),
                artworkHeight: 185,
                artworkWidth: 185,
                format: ArtworkFormat.PNG,
                artworkFit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 8),
            // Album title - font size 16
            Text(
              albums[index].album ?? 'Unknown Album',
              style: const TextStyle(
                color: whiteColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // Artist name - font size 12
            Text(
              albums[index].artist ?? 'Unknown Artist',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 10,
              ),
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
            // Remaining space ~12px for future use
          ],
        ),
      ),
    );
  }
}
