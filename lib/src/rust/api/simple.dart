// This file is automatically generated, so please do not edit it.
// Generated by `flutter_rust_bridge`@ 2.1.0.

// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import '../frb_generated.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

Uint8List decodeBlurhash({required String blurhash}) =>
    RustLib.instance.api.crateApiSimpleDecodeBlurhash(blurhash: blurhash);

Uint8List applyGaussianBlur(
        {required List<int> imageData, required int sigma}) =>
    RustLib.instance.api
        .crateApiSimpleApplyGaussianBlur(imageData: imageData, sigma: sigma);
