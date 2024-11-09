import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:thunder_audio_player/consts/styles.dart';
import 'package:thunder_audio_player/consts/utils.dart';
import 'package:thunder_audio_player/screens/homePage.dart';
import 'package:thunder_audio_player/screens/no_permission_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final status = await Utils.requestPermission();

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
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: myTheme,
      home: Homepage(),
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
      home: NoPermissionPage(),
    );
  }
}