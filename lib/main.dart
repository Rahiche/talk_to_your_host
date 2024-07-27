import 'package:flutter/material.dart';
import 'package:talk_to_your_host/samples/blurhash_demo.dart';

void main() {
  runApp(GalleryApp());
}

class GalleryApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gallery App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GalleryHomePage(),
    );
  }
}

class GalleryHomePage extends StatelessWidget {
  final List<String> samples = [
    'BlurhashDemo',
    'Sample 2',
    'Sample 3',
    'Sample 4',
    'Sample 5',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gallery App'),
      ),
      body: ListView.builder(
        itemCount: samples.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(samples[index]),
            onTap: () {
              if (samples[index] == "BlurhashDemo") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlurhashDemo(),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        SamplePage(sampleName: samples[index]),
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

class SamplePage extends StatelessWidget {
  final String sampleName;

  SamplePage({required this.sampleName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(sampleName),
      ),
      body: Center(
        child: Text(
          sampleName,
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
