import 'package:flutter/material.dart';
import 'package:thunder_audio_player/consts/colors.dart';
import 'package:thunder_audio_player/consts/utils.dart';

class NoPermissionPage extends StatefulWidget {
  const NoPermissionPage({super.key});

  @override
  State<NoPermissionPage> createState() => _NoPermissionPageState();
}

class _NoPermissionPageState extends State<NoPermissionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "No Permission Granted",
            style: TextStyle(color: whiteColor, fontSize: 20),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            "Please grant storage permission to continue",
            style: TextStyle(color: whiteColor, fontSize: 16),
          ),
          TextButton(
              onPressed: () async {
                final status = await Utils.requestPermission();
                if (status) {
                  Navigator.pushReplacementNamed(context, "/");
                }
              },
              child: Text(
                "Grant Permission",
                style: TextStyle(color: buttonColor, fontSize: 16),
              ))
        ],
      )),
    );
  }
}
