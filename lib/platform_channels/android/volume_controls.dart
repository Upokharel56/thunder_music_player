import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../utils/loggers.dart';

mixin VolumeControls {
  static const MethodChannel _channel = MethodChannel('com.example.app/volume');

  RxDouble volume = 0.5.obs; // Observable to track volume level
  RxBool isMuted = false.obs; // Observable to track if volume is muted
  RxDouble volumeBeforeMute = 0.5.obs; // Observable to store volume before mute

  // Initialize volume status and listener
  void onInit() async {
    try {
      // Fetch initial volume and update the state
      double initialVolume = await getVolume();
      volume.value = initialVolume;
      isMuted.value = initialVolume == 0;
    } catch (e) {
      err("Error while initializing volume: $e");
    }
  }

  // Set volume to a specific level
  Future<void> setVolume(double newVolume) async {
    try {
      volume.value = newVolume;
      await _channel.invokeMethod('setVolume', newVolume);
      isMuted.value = newVolume == 0;
    } catch (e) {
      err("Error while setting volume: $e");
    }
  }

  // Get the current volume level
  Future<double> getVolume() async {
    try {
      double currentVolume = await _channel.invokeMethod('getVolume');
      volume.value = currentVolume;
      isMuted.value = currentVolume == 0;
      return currentVolume;
    } catch (e) {
      err("Error while getting volume: $e");
      return 0.0;
    }
  }

  // Mute volume and store the current volume
  Future<void> muteVolume() async {
    try {
      if (!isMuted.value) {
        volumeBeforeMute.value = volume.value; // Store current volume
        await setVolume(0); // Set volume to 0 to mute
        isMuted.value = true;
        msg("Volume muted successfully");
      }
    } catch (e) {
      err("Error while muting volume: $e");
    }
  }

  // Unmute volume by restoring to previous volume level
  Future<void> unmuteVolume() async {
    try {
      if (isMuted.value) {
        await setVolume(volumeBeforeMute.value); // Restore previous volume
        isMuted.value = false;
        msg("Volume unmuted successfully with volume: ${volume.value}");
      }
    } catch (e) {
      err("Error while unmuting volume: $e");
    }
  }

  // Toggle mute state
  Future<void> toggleMute() async {
    if (isMuted.value) {
      await unmuteVolume();
    } else {
      await muteVolume();
    }
  }

  // Show the system volume slider UI without changing volume
  Future<void> showVolumeSlider() async {
    try {
      await _channel.invokeMethod('showVolumeSlider');
    } catch (e) {
      err("Error while showing volume slider: $e");
    }
  }
}
