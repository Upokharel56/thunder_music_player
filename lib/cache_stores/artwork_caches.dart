import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:thunder_audio_player/consts/colors.dart';

enum IdType { album, artist, playlist, genre, song }

class ArtworkCaches extends GetxController {
  final artworkCache = {
    IdType.album: {},
    IdType.artist: {},
    IdType.playlist: {},
    IdType.genre: {},
    IdType.song: {},
  }.obs;

  Widget getAtwork(
      {required String id,
      required IdType idType,
      double size = 200,
      double height = 55,
      double width = 50}) {
    if (artworkCache[idType]!.containsKey(id)) {
      return artworkCache[idType]![id];
    }

    switch (idType) {
      case IdType.album:
        return getAlbumArtwork(id, size, height: height, width: width);

      case IdType.artist:
        return getArtistArtwork(id, size);

      case IdType.playlist:
        return getPlaylistArtwork(id, size);

      case IdType.genre:
        return getGenreArtwork(id, size);

      case IdType.song:
        return getSongArtwork(id, size);
    }
  }

  Widget getAlbumArtwork(dynamic id, double size,
      {double height = 55, double width = 50}) {
    final albumArtwork = QueryArtworkWidget(
      id: int.parse(id),
      type: ArtworkType.ALBUM,
      nullArtworkWidget: Icon(
        Icons.music_note_rounded,
        color: whiteColor,
        size: 0.7 * size,
      ),
      artworkHeight: height,
      artworkWidth: width,
      artworkBorder: const BorderRadius.all(Radius.circular(8)),
    );

    artworkCache[IdType.album]![id] = albumArtwork;

    return albumArtwork;
  }

  Widget getArtistArtwork(dynamic id, double size) {
    final artistArtwork = QueryArtworkWidget(
      id: int.parse(id),
      type: ArtworkType.ARTIST,
      nullArtworkWidget: Icon(
        Icons.person,
        color: whiteColor,
        size: 0.7 * size,
      ),
      artworkHeight: size,
      artworkWidth: size,
      artworkBorder: const BorderRadius.all(Radius.circular(8)),
    );

    artworkCache[IdType.artist]![id] = artistArtwork;

    return artistArtwork;
  }

  Widget getPlaylistArtwork(dynamic id, double size) {
    final playlistArtwork = QueryArtworkWidget(
      id: int.parse(id),
      type: ArtworkType.PLAYLIST,
      nullArtworkWidget: Icon(
        Icons.playlist_play,
        color: whiteColor,
        size: 0.7 * size,
      ),
      artworkHeight: size,
      artworkWidth: size,
      artworkBorder: const BorderRadius.all(Radius.circular(8)),
    );

    artworkCache[IdType.playlist]![id] = playlistArtwork;

    return playlistArtwork;
  }

  Widget getGenreArtwork(dynamic id, double size) {
    final genreArtwork = QueryArtworkWidget(
      id: int.parse(id),
      type: ArtworkType.GENRE,
      nullArtworkWidget: Icon(
        Icons.category,
        color: whiteColor,
        size: 0.7 * size,
      ),
      artworkHeight: size,
      artworkWidth: size,
      artworkBorder: const BorderRadius.all(Radius.circular(8)),
    );

    artworkCache[IdType.genre]![id] = genreArtwork;

    return genreArtwork;
  }

  Widget getSongArtwork(dynamic id, double size) {
    final songArtwork = QueryArtworkWidget(
      id: int.parse(id),
      type: ArtworkType.AUDIO,
      nullArtworkWidget: Icon(
        Icons.music_note,
        color: whiteColor,
        size: 0.7 * size,
      ),
      artworkHeight: size,
      artworkWidth: size,
      artworkBorder: const BorderRadius.all(Radius.circular(8)),
    );

    artworkCache[IdType.song]![id] = songArtwork;

    return songArtwork;
  }
}
