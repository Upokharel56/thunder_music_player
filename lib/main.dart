import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:thunder_audio_player/consts/styles.dart';
import 'package:thunder_audio_player/consts/utils.dart';
import 'package:thunder_audio_player/screens/homePage.dart';
import 'package:thunder_audio_player/screens/no_permission_page.dart';
import 'package:thunder_audio_player/utils/app_bindings.dart';
import 'package:thunder_audio_player/pages/albums_page.dart';
import 'package:thunder_audio_player/pages/artists_page.dart';
import 'package:thunder_audio_player/pages/playlist_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final status = await Utils.requestPermission();

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.example.app.audio',
    androidNotificationChannelName: 'Audio Playback',
    androidNotificationOngoing: true,
  );

  if (status) {
    runApp(const MyApp());
    // await OnAudioQuery().querySongs();
  } else {
    runApp(const NoPermissionScreen());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialBinding: AppBindings(), // Add this line
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: myTheme,
      home: Homepage(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
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

class NoPermissionScreen extends StatelessWidget {
  const NoPermissionScreen({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Permission Denied',
      debugShowCheckedModeBanner: false,
      theme: myTheme,
      home: const NoPermissionPage(),
    );
  }
}
