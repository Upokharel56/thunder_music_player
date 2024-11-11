import 'package:flutter/services.dart';

mixin class AudioMetadataHelper {
  static const MethodChannel _channel =
      MethodChannel('com.example.app/metadata');

  Future<Map<String, dynamic>> getAudioMetadata(String filePath) async {
    try {
      final Map<String, dynamic>? metadata = await _channel
          .invokeMapMethod<String, dynamic>('getAudioMetadata', filePath);
      return metadata ?? {};
    } catch (e) {
      print("Error getting audio metadata: $e");
      return {};
    }
  }
}
