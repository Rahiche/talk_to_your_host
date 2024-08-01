import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:talk_to_your_host/src/rust/api/simple.dart';

class ImagePageView extends StatefulWidget {
  const ImagePageView({super.key});

  @override
  State<ImagePageView> createState() => _ImagePageViewState();
}

class _ImagePageViewState extends State<ImagePageView> {
  final List<String> imageUrls = [
    "https://i.imgur.com/Ommm2w8.png",
    "https://i.imgur.com/uvrFkeb.png",
    "https://i.imgur.com/fsXfsTP.png",
    "https://i.imgur.com/hRXYeIh.png",
    "https://i.imgur.com/PLhcdZ5.png",
    "https://i.imgur.com/ZcJMJ6j.png",
  ];

  bool showBlurHash = false;
  bool showBlurHashFFI = false;

  @override
  Widget build(BuildContext context) {
    final List<String> imageBlurhash = [
      "TQF#{rt39G~Wt7E1x@%LRkw[-pW.",
      r'''TZK9.fWU4.~X$~M{WKn$t6REV^t5''',
      "TAE.F94p0%~pIB-T0jD*%L0Ls9-p",
      "TTI3,aNa5T=x%2WE}S%1I=NGaJ-T",
      "THD0Z300DP.mZ#Mx_2E1M|%LIVWV",
      "TcKe1J-:bI~qn+t7-URjIU%0xuj=",
      //
    ];
    return Scaffold(
      appBar: AppBar(
        actions: [
          const Text("FFI: "),
          Switch(
            value: showBlurHashFFI,
            onChanged: (v) {
              showBlurHashFFI = v;
              setState(() {});
            },
          ),
          const CircularProgressIndicator(),
          const Text(" Blur: "),
          Switch(
            value: showBlurHash,
            onChanged: (v) {
              showBlurHash = v;
              setState(() {});
            },
          )
        ],
      ),
      body: GridView.builder(
        // controller: PageController(viewportFraction: 0.8, initialPage: 2),
        itemCount: imageUrls.length,
        scrollDirection: Axis.vertical,
        itemBuilder: (context, index) {
          if (showBlurHash) {
            if (showBlurHashFFI) {
              return Image.memory(
                decodeBlurhash(blurhash: imageBlurhash[index]),
                fit: BoxFit.cover,
              );
            }
            return BlurHash(
              hash: imageBlurhash[index],
              decodingHeight: 100,
              decodingWidth: 100,
              imageFit: BoxFit.cover,
              color: Colors.transparent,
            );
          }
          return Image.network(
            imageUrls[index],
            fit: BoxFit.cover,
          );

          // return Image.memory(
          //   decodeBlurhash(blurhash: imageBlurhash[index]),
          //   fit: BoxFit.cover,
          // );
          // return FutureBuilder(
          //   future: BlurHashDecoder.decodeBlurHash(
          //       imageBlurhash[index], 100, 100),
          //   builder: (BuildContext context,
          //       AsyncSnapshot<Uint8List?> snapshot) {
          //     if (!snapshot.hasData) {
          //       return Container(
          //         color: Colors.red,
          //       );
          //     }
          //     return Image.memory(
          //       snapshot.data!,
          //       fit: BoxFit.cover,
          //     );
          //   },
          // );

          ///
          ///
          // return FutureBuilder(
          //   future: ffiDecode(imageBlurhash[index]),
          //   builder:
          //       (BuildContext context, AsyncSnapshot<Uint8List?> snapshot) {
          //     if (!snapshot.hasData) {
          //       return Container(
          //         color: Colors.red,
          //       );
          //     }
          //     return Image.memory(
          //       snapshot.data!,
          //       fit: BoxFit.cover,
          //     );
          //   },
          // );
        },
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
      ),
    );
  }

  Future<Uint8List> ffiDecode(value) async {
    final compl = Completer<Uint8List>();
    compl.complete(decodeBlurhash(blurhash: value));
    return compl.future;
  }
}
