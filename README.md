This app was used as a part of a talk to illustrate how to leverage native APIs within a Flutter environment.


### Features

The application includes the following demos:

- Blurhash: Transition Example
- Image Processing: Blur
- Blurhash Using Different Methods

### Directory Structure:

The project is structured as follows:

```css
lib/
├── platform_channels/
│   └── blurhash_decoder.dart
├── samples/
│   ├── blurhash-transition/
│   │   └── images.dart
│   ├── blurhash_benchmark/
│   │   └── blurhash_demo.dart
│   └── image_processing/
│       └── gaussian_blur.dart
```

## Implementation Notes
### Gaussian Blur
The Gaussian blur implemented in Dart uses a different algorithm compared to the Rust implementation. While the Dart version can be optimized, it was intentionally kept as-is to showcase existing methods without any modifications or optimizations. This decision was made to demonstrate the use of readily available tools and libraries.

### Blurhash Example
Similarly, the Blurhash example leverages existing methods and libraries without any forking or optimization. The goal was to present the functionality as it is available in the current ecosystem.