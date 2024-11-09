import 'package:get/get.dart';
import 'package:volume_controller/volume_controller.dart';
import '../utils/loggers.dart';

mixin VolumeControls {
// Volume controller
  RxDouble volume = 0.5.obs; // Observable to track volume level
  RxBool isMuted = false.obs; // Observable to track if volume is muted
  RxDouble volumeBeforeMute = 0.5.obs; // Observable to store volume before mute

  final VolumeController volumeController = VolumeController();

  void onInit() {
    try {
      // Initialize volume and listen to volume changes
      volumeController.listener((newVolume) {
        volume.value = newVolume;
        if (newVolume == 0) {
          isMuted.value = true;
        } else {
          isMuted.value = false;
        }
      });
    } catch (e) {
      err("Error while initializing volume : \n $e");
    }

    try {
      // Set initial volume
      volumeController.getVolume().then((initialVolume) {
        volume.value = initialVolume;

        if (initialVolume == 0) {
          isMuted.value = true;
        }
      });
    } catch (e) {
      err("Error while getting volume : \n $e");
    }
  }

// Set volume to a specific level
  void setVolume(double newVolume) {
    try {
      volume.value = newVolume;
      volumeController.setVolume(newVolume);
      if (newVolume > 0) {
        isMuted.value = false; // Set unmuted if volume is above zero
      }
    } catch (e) {
      err("Error while setting volume : \n $e");
    }
  }

  // Get the current volume level
  Future<double> getVolume() async {
    try {
      volume.value = await volumeController.getVolume();
      return volume.value;
    } catch (e) {
      err("Error while getting volume : \n $e");
      return 0.0;
    }
  }

  // Mute volume and store the current volume
  void muteVolume() {
    try {
      if (!isMuted.value) {
        volumeBeforeMute.value = volume.value; // Store current volume
        setVolume(0); // Set volume to 0 to mute
        isMuted.value = true;
      }
      log("Volume muted successfully");
    } catch (e) {
      err("Error while muting volume : \n $e");
    }
  }

  // Unmute volume by restoring to previous volume level
  void unmuteVolume() {
    try {
      if (isMuted.value) {
        setVolume(volumeBeforeMute.value); // Restore previous volume
        isMuted.value = false;
      }
      log("Volume unmuted successfully with volume: ${volume.value}");
    } catch (e) {
      err("Error while unmuting volume : \n $e");
    }
  }

  void toggleMute() {
    if (isMuted.value) {
      unmuteVolume();
    } else {
      muteVolume();
    }
  }
}
