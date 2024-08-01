import 'dart:isolate';

import 'dart:async';
import 'dart:ui' as ui;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:talk_to_your_host/src/rust/api/simple.dart';
import 'package:talk_to_your_host/src/rust/frb_generated.dart';

// Entry point for the isolate
void _blurImageEntryPoint(SendPort sendPort) async {
  final port = ReceivePort();
  sendPort.send(port.sendPort);

  await for (final data in port) {
    if (data is _BlurImageData) {
      final image = img.decodeImage(data.bytes)!;
      final blurredImage = img.gaussianBlur(image, radius: data.sigma.toInt());
      final encodedImage = img.encodePng(blurredImage);

      // Send the result back to the main isolate
      data.resultPort.send(Uint8List.fromList(encodedImage));
    }
  }
}

void _rustBlurImageEntryPoint(SendPort sendPort) async {
  final port = ReceivePort();
  sendPort.send(port.sendPort);

  await for (final data in port) {
    if (data is _BlurImageData) {
      await RustLib.init();
      final blurredImage = applyGaussianBlur(
        imageData: data.bytes,
        sigma: data.sigma,
      );

      // Send the result back to the main isolate
      data.resultPort.send(blurredImage);
    }
  }
}

// Data class to hold the input data for the isolate
class _BlurImageData {
  final Uint8List bytes;
  final int sigma;
  final SendPort resultPort;

  _BlurImageData(this.bytes, this.sigma, this.resultPort);
}

class BlurEffectDemo extends StatefulWidget {
  const BlurEffectDemo({super.key});

  @override
  State<BlurEffectDemo> createState() => _BlurEffectDemoState();
}

class _BlurEffectDemoState extends State<BlurEffectDemo> {
  Image? imageMethod1;
  Image? imageMethod2;
  Duration? durationMethod1;
  Duration? durationMethod2;
  List<int> method1Durations = [];
  List<int> method2Durations = [];

  final String imagePath = 'assets/image_2.jpg';

  int sigma = 1;
  bool useIsolate = false;
  Future<void> _benchmarkMethods() async {
    final imageBytes = await _loadImageBytes(imagePath);

    durationMethod1 = Duration.zero;
    final stopwatch1 = Stopwatch()..start();
    if (useIsolate) {
      imageMethod1 =
          await _applyGaussianBlurMethod1WithIsolate(imageBytes, sigma);
    } else {
      imageMethod1 = await _applyGaussianBlurMethod1(imageBytes);
    }

    stopwatch1.stop();
    durationMethod1 = stopwatch1.elapsed;
    setState(() {});

    durationMethod2 = Duration.zero;
    final stopwatch2 = Stopwatch()..start();
    if (useIsolate) {
      imageMethod2 = await _applyGaussianBlurMethod2WithIsolate(imageBytes);
    } else {
      imageMethod2 = await _applyGaussianBlurMethod2(imageBytes);
    }
    stopwatch2.stop();
    durationMethod2 = stopwatch2.elapsed;

    setState(() {});
  }

  int run = 0;

  Future<void> _runBenchmarksWithDelay() async {
    run = 0;
    method1Durations.clear();
    method2Durations.clear();
    for (int i = 0; i < 100; i++) {
      run = i;
      sigma = i.toInt() + 1;
      setState(() {});
      await _benchmarkMethods();
      method1Durations.add(durationMethod1!.inMicroseconds);
      method2Durations.add(durationMethod2!.inMicroseconds);
      setState(() {});
      await Future.delayed(const Duration(milliseconds: 100));
    }
    setState(() {});
  }

  bool isLoading = false;

  Future<Image> _applyGaussianBlurMethod1WithIsolate(
      Uint8List bytes, int sigma) async {
    final port = ReceivePort();
    setState(() => isLoading = true);
    final isolate = await Isolate.spawn(_blurImageEntryPoint, port.sendPort);

    final completer = Completer<Uint8List>();
    port.listen((message) {
      if (message is SendPort) {
        message.send(_BlurImageData(bytes, sigma, port.sendPort));
      } else if (message is Uint8List) {
        completer.complete(message);
        port.close();
        isolate.kill();
      }
    });

    final blurredImageBytes = await completer.future;
    setState(() => isLoading = false);

    return Image.memory(
      blurredImageBytes,
      gaplessPlayback: true,
    );
  }

  Future<Image> _applyGaussianBlurMethod1(Uint8List bytes) async {
    final image = img.decodeImage(bytes)!;
    final blurredImage = img.gaussianBlur(image, radius: sigma.toInt());
    return Image.memory(img.encodePng(blurredImage));
  }

  Future<Image> _applyGaussianBlurMethod2WithIsolate(Uint8List bytes) async {
    final port = ReceivePort();
    setState(() => isLoading = true);
    final isolate =
        await Isolate.spawn(_rustBlurImageEntryPoint, port.sendPort);

    final completer = Completer<Uint8List>();
    port.listen((message) {
      if (message is SendPort) {
        message.send(_BlurImageData(bytes, sigma, port.sendPort));
      } else if (message is Uint8List) {
        completer.complete(message);
        port.close();
        isolate.kill();
      }
    });

    final blurredImageBytes = await completer.future;
    setState(() => isLoading = false);

    return Image.memory(
      blurredImageBytes,
      gaplessPlayback: true,
    );
  }

  Future<Image> _applyGaussianBlurMethod2(Uint8List bytes) async {
    final result = applyGaussianBlur(
      imageData: bytes,
      sigma: sigma,
    );

    return Image.memory(
      result,
      gaplessPlayback: true,
    );
  }

  Future<Uint8List> _loadImageBytes(String path) async {
    final byteData = await rootBundle.load(path);
    return byteData.buffer.asUint8List();
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
        title: const Text("Gaussian Blur"),
        actions: [
          Row(
            children: [
              const Text("Use Isolate:"),
              Switch(
                value: useIsolate,
                onChanged: (value) {
                  setState(() => useIsolate = value);
                },
              ),
              Text("Sigma: $sigma"),
              Slider(
                value: sigma.toDouble(),
                min: 0,
                max: 150,
                divisions: 150,
                label: sigma.round().toString(),
                onChanged: (value) {
                  setState(() {
                    sigma = value.toInt();
                  });
                },
              ),
            ],
          ),
          FloatingActionButton(
            heroTag: "start",
            onPressed: _benchmarkMethods,
            child: isLoading
                ? const CircularProgressIndicator()
                : const Icon(Icons.start),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _runBenchmarksWithDelay,
            child: const Icon(Icons.run_circle),
          ),
          const SizedBox(height: 10),
          SizedBox(width: 100, child: Text(run.toString()))
        ],
      ),
      body: PageView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(
                        width: 250,
                        child: Text(
                          "Method 2: FFI",
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 30,
                          ),
                        ),
                      ),
                      Text("Duration: ${durationMethod2?.inMilliseconds} ms"),
                      if (imageMethod2 != null) Expanded(child: imageMethod2!),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(
                        width: 250,
                        child: Text(
                          "Method 1: Image Package",
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 30,
                          ),
                        ),
                      ),
                      Text("Duration: ${durationMethod1?.inMilliseconds} ms"),
                      if (imageMethod1 != null) Expanded(child: imageMethod1!),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          if (method1Durations.isNotEmpty && method2Durations.isNotEmpty)
            LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: _generateSpots(method1Durations),
                    isCurved: true,
                    barWidth: 1,
                    color: Colors.orange,
                    // isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                  ),
                  LineChartBarData(
                    spots: _generateSpots(method2Durations),
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 1,
                    // isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                  ),
                ],
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.black),
                ),
              ),
            )
          else
            Container()
        ],
      ),
    );
  }
}

class DrawImageWidget extends StatelessWidget {
  DrawImageWidget({
    required this.image,
    required this.size,
  });
  final ui.Image image;
  final ui.Size size;

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
  void paint(Canvas canvas, ui.Size size) {
    Paint paint = Paint();
    canvas.drawImage(image, Offset.zero, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
