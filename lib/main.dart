import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:thunder_audio_player/consts/styles.dart';
import 'package:thunder_audio_player/pages/albums_page.dart';
import 'package:thunder_audio_player/pages/artists_page.dart';
import 'package:thunder_audio_player/pages/favourite_page.dart';
import 'package:thunder_audio_player/pages/playlist_page.dart';
import 'package:thunder_audio_player/screens/homePage.dart';
import 'package:thunder_audio_player/screens/no_permission_page.dart';
import 'package:thunder_audio_player/utils/app_bindings.dart';
import 'package:thunder_audio_player/utils/utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final status = await Utils.requestPermission();

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.example.app.audio',
    androidNotificationChannelName: 'Audio Playback',
    androidNotificationOngoing: true,
    preloadArtwork: true,
    notificationColor: const Color.fromARGB(255, 104, 191, 253),
  );

  await GetStorage.init('favourite_songs');

  runApp(MyApp(permissionGranted: status));
}

class MyApp extends StatelessWidget {
  final bool permissionGranted;

  const MyApp({super.key, required this.permissionGranted});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialBinding: AppBindings(),
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: myTheme,
      home: permissionGranted ? Homepage() : const NoPermissionPage(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/favorites':
            return MaterialPageRoute(
                builder: (context) => const FavouritePage());
          case '/homepage':
            return MaterialPageRoute(builder: (context) => Homepage());
          case '/playlists':
            return MaterialPageRoute(
                builder: (context) => const PlaylistsPage());
          case '/artists':
            return MaterialPageRoute(builder: (context) => const ArtistsPage());
          case '/albums':
            return MaterialPageRoute(builder: (context) => const AlbumsPage());
          default:
            return MaterialPageRoute(builder: (context) => Homepage());
        }
      },
    );
  }
}
