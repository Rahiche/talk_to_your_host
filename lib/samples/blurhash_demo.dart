import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart' as lib1;
import 'package:blurhash_ffi/blurhash_ffi.dart' as lib2;
import 'package:fl_chart/fl_chart.dart';
import 'dart:ui' as ui;

class BlurhashDemo extends StatefulWidget {
  const BlurhashDemo({Key? key}) : super(key: key);

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
  ];
  ui.Image? imageMethod1;
  ui.Image? imageMethod2;
  Duration? durationMethod1;
  Duration? durationMethod2;
  List<int> method1Durations = [];
  List<int> method2Durations = [];

  Future<void> _benchmarkMethods() async {
    durationMethod1 = Duration.zero;
    durationMethod2 = Duration.zero;
    final stopwatch1 = Stopwatch()..start();
    imageMethod1 = await decodeBlurhashMethod1(blurhash);
    stopwatch1.stop();
    durationMethod1 = stopwatch1.elapsed;

    final stopwatch2 = Stopwatch()..start();
    imageMethod2 = await decodeBlurhashMethod2(blurhash);
    stopwatch2.stop();
    durationMethod2 = stopwatch2.elapsed;

    setState(() {});
  }

  int run = 0;
  Future<void> _runBenchmarksWithDelay() async {
    run = 0;
    method1Durations.clear();
    method2Durations.clear();
    for (int i = 1; i < 100; i++) {
      blurhash = blurhashes[i % blurhashes.length];
      run = i;
      setState(() {});
      await Future.delayed(Duration(milliseconds: 100));
      await _benchmarkMethods();
      await Future.delayed(Duration(milliseconds: 100));
      method1Durations.add(durationMethod1!.inMilliseconds);
      method2Durations.add(durationMethod2!.inMilliseconds);
      setState(() {});
      await Future.delayed(Duration(milliseconds: 100));
    }
    setState(() {});
  }

  Future<ui.Image> decodeBlurhashMethod1(String blurhash) async {
    final bytes = await lib1.blurHashDecodeImage(
      blurHash: blurhash,
      width: 100,
      height: 100,
      punch: 1,
    );
    return bytes;
    // return Image.memory(bytes);
  }

  Future<ui.Image> decodeBlurhashMethod2(String blurhash) async {
    final img = await lib2.BlurhashFFI.decode(
      blurhash,
      height: 100,
      width: 100,
      punch: 1,
    );
    return img;
    // final bytes = (await img.toByteData())!.buffer.asUint8List();
    // return Image.memory(bytes);
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
        actions: [Text(run.toString())],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "start",
            child: const Icon(Icons.start),
            onPressed: () {
              _benchmarkMethods();
            },
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            child: const Icon(Icons.run_circle),
            onPressed: () {
              _runBenchmarksWithDelay();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    SizedBox(
                      width: 250,
                      child: const Text(
                        "Method 1: Dart",
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 30,
                        ),
                      ),
                    ),
                    Text("Duration: ${durationMethod1?.inMilliseconds} ms"),
                  ],
                ),
                if (imageMethod1 != null) DrawImageWidget(image: imageMethod1!),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    SizedBox(
                      width: 250,
                      child: const Text(
                        "Method 2: FFI",
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 30,
                        ),
                      ),
                    ),
                    Text("Duration: ${durationMethod2?.inMilliseconds} ms"),
                  ],
                ),
                if (imageMethod2 != null) DrawImageWidget(image: imageMethod2!),
              ],
            ),
            const SizedBox(height: 16),
            if (method1Durations.isNotEmpty && method2Durations.isNotEmpty)
              Expanded(
                child: LineChart(
                  LineChartData(
                    lineBarsData: [
                      LineChartBarData(
                        spots: _generateSpots(method1Durations),
                        isCurved: true,
                        barWidth: 2,
                        color: Colors.orange,
                        isStrokeCapRound: true,
                        dotData: FlDotData(show: false),
                      ),
                      LineChartBarData(
                        spots: _generateSpots(method2Durations),
                        isCurved: true,
                        color: Colors.blue,
                        barWidth: 2,
                        isStrokeCapRound: true,
                        dotData: FlDotData(show: false),
                      ),
                    ],
                    titlesData: FlTitlesData(
                        // leftTitles: SideTitles(showTitles: true),
                        // bottomTitles: SideTitles(showTitles: true),
                        ),
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
  final ui.Image image;

  DrawImageWidget({required this.image});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(100, 100),
      painter: ImagePainter(image),
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
    return false;
  }
}
