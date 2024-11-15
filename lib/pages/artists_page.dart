import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:thunder_audio_player/consts/colors.dart';
import 'package:thunder_audio_player/pages/inside_screen.dart';
import 'package:thunder_audio_player/utils/loggers.dart';

class ArtistsPage extends StatefulWidget {
  const ArtistsPage({super.key});

  @override
  State<ArtistsPage> createState() => _ArtistsPageState();
}

class _ArtistsPageState extends State<ArtistsPage>
    with AutomaticKeepAliveClientMixin {
  final OnAudioQuery _audioQuery = OnAudioQuery();

  List<ArtistModel> artists = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadArtistsList();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: RefreshIndicator(
          child: _buildContent(), onRefresh: () async => _loadArtistsList()),
    );
  }

  _loadArtistsList() async {
    // Get artists
    try {
      var results = await _audioQuery.queryArtists(
        orderType: OrderType.ASC_OR_SMALLER,
        sortType: ArtistSortType.ARTIST,
      );

      results.sort((a, b) {
        // Convert artist names to lowercase for case-insensitive comparison
        String artistA = a.artist.toLowerCase();
        String artistB = b.artist.toLowerCase();

        // Check for various "unknown" cases
        bool isUnknownA = artistA == 'unknown' || artistA == '<unknown>';
        bool isUnknownB = artistB == 'unknown' || artistB == '<unknown>';

        // Place unknown artists at start
        if (isUnknownA && !isUnknownB) return -1;
        if (!isUnknownA && isUnknownB) return 1;

        // Normal alphabetical sorting for other cases
        return a.artist.compareTo(b.artist);
      });

      setState(() {
        artists = results;
        isLoading = false;
      });
    } catch (e) {
      // Handle error
      err('Error loading albums: $e', tag: 'Artists Fetch error');
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (artists.isEmpty) {
      return const Center(child: Text('No artists found'));
    }

    return buildArtistsLayout();
  }

  Widget buildArtistsLayout() {
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
          itemCount: artists.length,
          itemBuilder: (context, index) => buildArtistItem(index),
        );
      },
    );
  }

  Widget buildArtistItem(int index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InsideScreen(
              model: artists[index],
              type: AudioModelType.artist,
            ),
          ),
        );
      },
      child: Card(
        color: Colors.black12,
        child: Padding(
          padding:
              const EdgeInsets.only(bottom: 8.0, right: 5, left: 5, top: 2),
          child: Column(
            children: [
              // Artist artwork container with fixed size 185x185
              SizedBox(
                height: 185,
                width: 185,
                child: QueryArtworkWidget(
                  id: artists[index].id,
                  type: ArtworkType.ARTIST,
                  nullArtworkWidget: const Icon(
                    Icons.person_rounded,
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
              // Artist name
              Text(
                artists[index].artist,
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
                '${artists[index].numberOfTracks} tracks',
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
      ),
    );
  }
}
