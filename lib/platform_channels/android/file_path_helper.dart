import 'package:flutter/services.dart';

mixin FilePathResolverMixin {
  static const MethodChannel _channel =
      MethodChannel('com.example.app/filepath');

  // Method to get real path from content URI
  Future<String?> resolveContentUri(String contentUri) async {
    try {
      final String? path =
          await _channel.invokeMethod('getRealPath', contentUri);

      print(
          "Resolved path sucessfully from content URI of \n Content URI: $contentUri \n Real Path: $path");
      return path;
    } catch (e) {
      print("Error getting real path: $e");
      return null;
    }
  }
}
