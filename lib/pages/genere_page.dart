import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:thunder_audio_player/consts/colors.dart';
import 'package:thunder_audio_player/utils/loggers.dart';

class GenresPage extends StatefulWidget {
  const GenresPage({super.key});

  @override
  State<GenresPage> createState() => _GenresPageState();
}

class _GenresPageState extends State<GenresPage> {
  final OnAudioQuery _audioQuery = OnAudioQuery();

  List<GenreModel> genres = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGenresList();
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

    if (genres.isEmpty) {
      return const Center(child: Text('No artists found'));
    }

    return buildGenreLayout();
  }

  Widget buildGenreLayout() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate columns based on screen width and fixed item width of 225
        int crossAxisCount = (constraints.maxWidth / 225).floor();
        // Ensure at least 2 and at most 5 columns
        crossAxisCount = crossAxisCount.clamp(2, 5);

        return GridView.builder(
          padding: const EdgeInsets.all(8.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            // Set aspect ratio to make height 250 and width 225 (250/225)
            childAspectRatio: 0.75,
            crossAxisSpacing: 5,
            mainAxisSpacing: 8,
          ),
          itemCount: genres.length,
          itemBuilder: (context, index) => buildGenreItem(index),
        );
      },
    );
  }

  _loadGenresList() async {
    try {
      var results = await _audioQuery.queryGenres(
        orderType: OrderType.ASC_OR_SMALLER,
        sortType: null, // GenreSortType doesn't exist in the package
      );

      results.sort((a, b) {
        // Convert genre names to lowercase for case-insensitive comparison
        String genreA = a.genre.toLowerCase();
        String genreB = b.genre.toLowerCase();

        // Check for various "unknown" cases
        bool isUnknownA = genreA == 'unknown' || genreA == '<unknown>';
        bool isUnknownB = genreB == 'unknown' || genreB == '<unknown>';

        // Place unknown genres at start
        if (isUnknownA && !isUnknownB) return -1;
        if (!isUnknownA && isUnknownB) return 1;

        // Normal alphabetical sorting
        return a.genre.compareTo(b.genre);
      });

      setState(() {
        genres = results;
        isLoading = false;
      });
    } catch (e) {
      err('Error loading genres: $e', tag: 'Genres Fetch error');
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildGenreItem(int index) {
    return Card(
      color: Colors.black12,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0, right: 5, left: 5, top: 2),
        child: Column(
          children: [
            // Genre artwork container with fixed size 185x185
            SizedBox(
              height: 185,
              width: 185,
              child: QueryArtworkWidget(
                id: genres[index].id,
                type: ArtworkType.GENRE,
                nullArtworkWidget: const Icon(
                  Icons.queue_music_rounded,
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
            // Genre name
            Text(
              genres[index].genre,
              style: const TextStyle(
                color: whiteColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // Number of tracks
            Text(
              '${genres[index].numOfSongs} tracks',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // Rest of the layout code remains the same, just update references:
  // - artists.length -> genres.length
  // - buildArtistItem -> buildGenreItem
}
