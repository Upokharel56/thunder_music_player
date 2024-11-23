import 'package:flutter/material.dart';
import 'package:thunder_audio_player/utils/loggers.dart';

class NormalLyricsScreen extends StatelessWidget {
  final String lyrics;
  const NormalLyricsScreen({super.key, required this.lyrics});

  @override
  Widget build(BuildContext context) {
    msg('inside normal lyrics screen: ', tag: 'Lyrics');
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              lyrics,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}
