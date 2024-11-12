import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

class ArtistsPage extends StatefulWidget {
  const ArtistsPage({super.key});

  @override
  State<ArtistsPage> createState() => _ArtistsPageState();
}

class _ArtistsPageState extends State<ArtistsPage> {
  final OnAudioQuery _audioQuery = OnAudioQuery();

  List<ArtistModel> artists = [];

  @override
  void initState() {
    super.initState();
    _getArtists();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }

  _getArtists() async {
    // Get artists
    artists = await _audioQuery.queryArtists(
      orderType: OrderType.ASC_OR_SMALLER,
      sortType: ArtistSortType.ARTIST,
    );
  }

  Widget _buildContent() {
    if (artists.isEmpty) {
      return const Center(child: Text('No artists found'));
    }

    return _buildArtistsLayout();
  }

  Widget _buildArtistsLayout() {
    return ListView.builder(
      itemCount: artists.length,
      itemBuilder: (context, index) {
        final artist = artists[index];
        return ListTile(
          title: Text(artist.artist),
          subtitle: Text('${artist.numberOfTracks} songs'),
        );
      },
    );
  }
}
