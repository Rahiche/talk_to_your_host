import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart' as lib1;
import 'package:blurhash_ffi/blurhash_ffi.dart' as lib2;
import 'package:fl_chart/fl_chart.dart';
import 'package:talk_to_your_host/platform_channels/blurhash_decoder.dart';
import 'dart:ui' as ui;

import 'package:talk_to_your_host/src/rust/api/simple.dart';

class BlurhashDemo extends StatefulWidget {
  const BlurhashDemo({super.key});

  @override
  State<BlurhashDemo> createState() => _BlurhashDemoState();
}

class _BlurhashDemoState extends State<BlurhashDemo> {
  String blurhash = "L7JQ1PF{00]%.jEk9Hwc9G5R}?Xk";
  List<String> blurhashes = [
    r'''LD7V[mCnZ$r:][D|aLtm%gP4XlxI''',
    r'''LhSXx^mAk]cUoffja|fQ%%kokVf+''',
    r'''LEBMx@8D1r}[.mTGMwof2=#l:lEy''',
    r'''LK8P4ZQ3Oi%1yGnmiIV?PmpbtRX9''',
    r'''LBCQ7T3H-CEL}_5~+$THtPTIRir]''',
    r'''LfGj:a_+cREl^P#Xx[nPngtRw$Sx''',
    r'''LE740DU0r?tSy=x@bqsqR*s:i_R$''',
    r'''LTE|3z|QxGSz-=sBb[X5$lxuofbu''',
    r'''LFC7sfRjIUrs?^VFixkUoyrwa0yC''',
    r'''L7JQ1PF{00]%.jEk9Hwc9G5R}?Xk''',
  ];
  ui.Image? imageMethod1;
  ui.Image? imageMethod2;
  Image? imageMethod3;
  Image? imageMethod4;
  Duration? durationMethod1;
  Duration? durationMethod2;
  Duration? durationMethod3;
  Duration? durationMethod4;
  List<int> method1Durations = [];
  List<int> method2Durations = [];
  List<int> method3Durations = [];
  List<int> method4Durations = [];

  Future<void> _benchmarkMethods() async {
    durationMethod1 = Duration.zero;
    final stopwatch1 = Stopwatch()..start();
    imageMethod1 = await decodeBlurhashMethod1(blurhash);
    stopwatch1.stop();
    durationMethod1 = stopwatch1.elapsed;

    durationMethod2 = Duration.zero;
    final stopwatch2 = Stopwatch()..start();
    imageMethod2 = await decodeBlurhashMethod2(blurhash);
    stopwatch2.stop();
    durationMethod2 = stopwatch2.elapsed;

    durationMethod3 = Duration.zero;
    final stopwatch3 = Stopwatch()..start();
    imageMethod3 = decodeBlurhashMethod3(blurhash);
    stopwatch3.stop();
    durationMethod3 = stopwatch3.elapsed;

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      durationMethod4 = Duration.zero;
      final stopwatch4 = Stopwatch()..start();
      imageMethod4 = await decodeBlurhashMethod4(blurhash);
      stopwatch4.stop();
      durationMethod4 = stopwatch4.elapsed;
    }

    setState(() {});
  }

  int run = 0;
  Future<void> _runBenchmarksWithDelay() async {
    run = 0;
    method1Durations.clear();
    method2Durations.clear();
    method3Durations.clear();
    method4Durations.clear();
    for (int i = 1; i < 1000; i++) {
      blurhash = blurhashes[i % blurhashes.length];

      run = i;
      setState(() {});
      await _benchmarkMethods();
      method1Durations.add(durationMethod1!.inMicroseconds);
      method2Durations.add(durationMethod2!.inMicroseconds);
      method3Durations.add(durationMethod3!.inMicroseconds);
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        method4Durations.add(durationMethod4!.inMicroseconds);
      }
      setState(() {});
      await Future.delayed(const Duration(milliseconds: 100));
    }
    setState(() {});
  }

  Future<ui.Image> decodeBlurhashMethod1(String blurhash) async {
    final img = await lib1.blurHashDecodeImage(
      blurHash: blurhash,
      width: 100,
      height: 100,
      punch: 1,
    );
    return img;
  }

  Image decodeBlurhashMethod3(String blurhash) {
    return Image.memory(
      decodeBlurhash(blurhash: blurhash),
      gaplessPlayback: true,
    );
  }

  Future<ui.Image> decodeBlurhashMethod2(String blurhash) async {
    final img = await lib2.BlurhashFFI.decode(
      blurhash,
      width: 100,
      height: 100,
      punch: 1,
    );
    return img;
  }

  Future<Image> decodeBlurhashMethod4(String blurhash) async {
    final a = await BlurHashDecoder.decodeBlurHash(blurhash, 100, 100);

    return Image.memory(
      a!,
      gaplessPlayback: true,
    );
  }

  List<FlSpot> _generateSpots(List<int> durations) {
    return durations
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.toDouble()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Blurhash"),
        actions: [
          const CircularProgressIndicator(),
          const SizedBox(width: 10, height: 10),
          FloatingActionButton(
            heroTag: "start",
            child: const Icon(Icons.start),
            onPressed: () {
              _benchmarkMethods();
            },
          ),
          const SizedBox(width: 10, height: 10),
          FloatingActionButton(
            child: const Icon(Icons.run_circle),
            onPressed: () {
              _runBenchmarksWithDelay();
            },
          ),
          const SizedBox(width: 10, height: 10),
          SizedBox(width: 100, child: Text(run.toString()))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Method 1: Dart",
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: 30,
                              ),
                            ),
                            Text(
                                "Duration: ${durationMethod1?.inMilliseconds} ms"),
                          ],
                        ),
                      ),
                      // SizedBox(width: 100, height: 100, child: imageMethod1),
                      if (imageMethod1 != null)
                        DrawImageWidget(
                          image: imageMethod1!,
                          size: const Size(100, 100),
                        ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Method 2: FFI",
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 30,
                              ),
                            ),
                            Text(
                                "Duration: ${durationMethod2?.inMilliseconds} ms"),
                          ],
                        ),
                      ),
                      // SizedBox(width: 100, height: 100, child: imageMethod2),
                      if (imageMethod2 != null)
                        DrawImageWidget(
                          image: imageMethod2!,
                          size: const Size(100, 100),
                        ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Method 3: Rust",
                              style: TextStyle(
                                color: Colors.pink,
                                fontSize: 30,
                              ),
                            ),
                            Text(
                                "Duration: ${durationMethod3?.inMilliseconds} ms"),
                          ],
                        ),
                      ),
                      // if (imageMethod3 != null)
                      //   DrawImageWidget(
                      //     image: imageMethod3!,
                      //     size: size,
                      //   ),
                      SizedBox(width: 100, height: 100, child: imageMethod3),
                    ],
                  ),
                  if (defaultTargetPlatform == TargetPlatform.iOS)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                child: Text(
                                  "Method 4: Platform channel",
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 30,
                                  ),
                                ),
                              ),
                              Text(
                                  "Duration: ${durationMethod4?.inMilliseconds} ms"),
                            ],
                          ),
                        ),
                        if (imageMethod4 != null)
                          SizedBox(
                              width: 100, height: 100, child: imageMethod4),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (method1Durations.isNotEmpty &&
                method2Durations.isNotEmpty &&
                method3Durations.isNotEmpty)
              Expanded(
                child: LineChart(
                  LineChartData(
                    lineBarsData: [
                      LineChartBarData(
                        spots: _generateSpots(method1Durations),
                        isCurved: true,
                        barWidth: 1,
                        color: Colors.orange,
                        dotData: const FlDotData(show: false),
                      ),
                      LineChartBarData(
                        spots: _generateSpots(method2Durations),
                        isCurved: true,
                        color: Colors.blue,
                        barWidth: 1,
                        dotData: const FlDotData(show: false),
                      ),
                      LineChartBarData(
                        spots: _generateSpots(method3Durations),
                        isCurved: true,
                        color: Colors.pink,
                        barWidth: 1,
                        dotData: const FlDotData(show: false),
                      ),
                      LineChartBarData(
                        spots: _generateSpots(method4Durations),
                        isCurved: true,
                        color: Colors.green,
                        barWidth: 1,
                        dotData: const FlDotData(show: false),
                      ),
                    ],
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: Colors.black),
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: Container(),
              )
          ],
        ),
      ),
    );
  }
}

class DrawImageWidget extends StatelessWidget {
  const DrawImageWidget({
    super.key,
    required this.image,
    required this.size,
  });
  final ui.Image image;
  final Size size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        children: [
          CustomPaint(
            size: size,
            painter: ImagePainter(image),
          ),
        ],
      ),
    );
  }
}

class ImagePainter extends CustomPainter {
  final ui.Image image;

  ImagePainter(this.image);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    canvas.drawImage(image, Offset.zero, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
