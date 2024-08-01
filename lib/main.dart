import 'package:flutter/material.dart';
import 'package:talk_to_your_host/samples/blurhash-transition/images.dart';
import 'package:talk_to_your_host/samples/blurhash_benchmark/blurhash_demo.dart';
import 'package:talk_to_your_host/samples/image_processing/gaussian_blur.dart';
import 'package:talk_to_your_host/src/rust/frb_generated.dart';

void main() async {
  await RustLib.init();
  runApp(const GalleryApp());
}

class GalleryApp extends StatelessWidget {
  const GalleryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gallery App',
      theme: ThemeData.dark(useMaterial3: true),
      home: GalleryHomePage(),
    );
  }
}

class GalleryHomePage extends StatelessWidget {
  GalleryHomePage({super.key});

  final List<String> samples = [
    'Blurhash: transition example',
    'Image Processing: blur',
    'Blurhash Using different methods',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gallery App'),
      ),
      body: ListView.builder(
        itemCount: samples.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(samples[index]),
            onTap: () {
              if (samples[index] == 'Blurhash Using different methods') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BlurhashDemo(),
                  ),
                );
              } else if (samples[index] == 'Image Processing: blur') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BlurEffectDemo(),
                  ),
                );
              } else if (samples[index] == 'Blurhash: transition example') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ImagePageView(),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}
