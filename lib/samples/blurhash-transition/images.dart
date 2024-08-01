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
      appBar: AppBar(),
      body: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("FFI: "),
              SizedBox(
                width: 100,
                child: FittedBox(
                  child: Switch(
                    value: showBlurHashFFI,
                    onChanged: (v) {
                      showBlurHashFFI = v;
                      setState(() {});
                    },
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
              const Text(" Blur: "),
              SizedBox(
                width: 100,
                child: FittedBox(
                  child: Switch(
                    value: showBlurHash,
                    onChanged: (v) {
                      showBlurHash = v;
                      setState(() {});
                    },
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: GridView.builder(
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
              },
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<Uint8List> ffiDecode(value) async {
    final compl = Completer<Uint8List>();
    compl.complete(decodeBlurhash(blurhash: value));
    return compl.future;
  }
}
