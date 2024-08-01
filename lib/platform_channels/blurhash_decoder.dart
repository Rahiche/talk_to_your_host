import 'package:flutter/services.dart';

class BlurHashDecoder {
  static const MethodChannel _channel = MethodChannel(
    'app.talktoyourhost/blurhash',
  );

  static Future<Uint8List?> decodeBlurHash(
    String blurHash,
    int width,
    int height, {
    double punch = 1.0,
  }) async {
    try {
      final Uint8List image = await _channel.invokeMethod('decodeBlurHash', {
        'blurHash': blurHash,
        'width': width.toDouble(),
        'height': height.toDouble(),
        'punch': punch,
      });
      return image;
    } catch (e) {
      print("Error decoding blur hash: $e");
      return null;
    }
  }
}
