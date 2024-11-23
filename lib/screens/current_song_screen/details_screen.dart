import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:thunder_audio_player/consts/colors.dart';
import 'package:thunder_audio_player/controllers/music_controller.dart';

enum ArtType { album, artist, playlist, genre, song }

class SongDetailsScreen extends StatelessWidget {
  SongDetailsScreen({super.key});

  final MusicController controller = Get.find<MusicController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentSong = controller.songs[controller.currentIndex.value];

      return Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Details:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: whiteColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: _buildDetails(currentSong),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildDetails(SongModel currentSong) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "Title:",
            style: TextStyle(color: whiteColor, fontSize: 18),
          ),
          Text(
            currentSong.title,
            style: const TextStyle(color: whiteColor, fontSize: 16),
          ),
          const Divider(),
          const Text(
            "Artist:",
            style: TextStyle(color: whiteColor, fontSize: 16),
          ),
          Text(
            currentSong.artist ?? 'Unknown Artist',
            style: const TextStyle(color: whiteColor, fontSize: 16),
          ),
          const Divider(),
          const Text(
            'Album:',
            style: TextStyle(color: whiteColor, fontSize: 18),
          ),
          _buildArtwork(currentSong, ArtType.album),
          const Divider(),
          const Text(
            'Artist:',
            style: TextStyle(color: whiteColor, fontSize: 18),
          ),
          _buildArtwork(currentSong, ArtType.artist),
          const Divider(),
          const Text(
            'Duration:',
            style: TextStyle(color: whiteColor, fontSize: 18),
          ),
          Text(
            _getFormattedDuration(currentSong.duration),
            style: const TextStyle(color: whiteColor, fontSize: 16),
          ),
          const Divider(),
          const Text(
            'File Size:',
            style: TextStyle(color: whiteColor, fontSize: 18),
          ),
          Text(
            '${(currentSong.size / 1024 / 1024).toStringAsFixed(2)} MB',
            style: const TextStyle(color: whiteColor, fontSize: 16),
          ),
          const Divider(),
          const Text(
            'Date Added:',
            style: TextStyle(color: whiteColor, fontSize: 18),
          ),
          Text(
            _getFormattedDate(currentSong.dateAdded ?? 0),
            style: const TextStyle(color: whiteColor, fontSize: 16),
          ),
          const Divider(),
          const Text(
            'Storage path',
            style: TextStyle(color: whiteColor, fontSize: 18),
          ),
          Text(
            currentSong.data,
            style: const TextStyle(color: whiteColor, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildArtwork(SongModel currentSong, ArtType type) {
    return Column(
      children: [
        SizedBox(
          height: 100,
          width: 100,
          child: QueryArtworkWidget(
            id: (type == ArtType.album
                    ? currentSong.albumId
                    : currentSong.artistId) ??
                0,
            type:
                type == ArtType.album ? ArtworkType.ALBUM : ArtworkType.ARTIST,
            artworkHeight: 75,
            artworkWidth: 75,
            size: 100,
            format: ArtworkFormat.PNG,
            artworkFit: BoxFit.contain,
            nullArtworkWidget: Icon(
              type == ArtType.album ? Icons.album : Icons.person,
              color: whiteColor,
              size: 50,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          type == ArtType.album
              ? (currentSong.album ?? 'Unknown Album')
              : (currentSong.artist ?? 'Unknown Artist'),
          style: const TextStyle(color: whiteColor, fontSize: 16),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  String _getFormattedDuration(int? duration) {
    if (duration == null) return '0:00';

    final durationInSeconds = duration ~/ 1000;
    final minutes =
        ((durationInSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final seconds = (durationInSeconds % 60).toString().padLeft(2, '0');

    return '$minutes:$seconds';
  }

  String _getFormattedDate(int timestamp) {
    // Convert seconds to milliseconds
    DateTime date =
        DateTime.fromMillisecondsSinceEpoch(timestamp * 1000, isUtc: true);

    // Format the date as YYYY-MM-DD
    String formattedDate =
        "${date.year}-${_twoDigits(date.month)}-${_twoDigits(date.day)}";

    return formattedDate;
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');
}
