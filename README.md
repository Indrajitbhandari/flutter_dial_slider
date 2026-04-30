`dial_slider` is a smooth animated semicircular dial slider for Flutter.

## Features

- Semi-circular dial UI with tick marks
- Drag and tap to select a value
- Animated snapping to the nearest tick

## Getting started

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  dial_slider: ^0.0.1
```

## Usage

```dart
import 'package:dial_slider/dial_slider.dart';
import 'package:flutter/material.dart';

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  int value = 12;

  @override
  Widget build(BuildContext context) {
    return DialSlider(
      initialValue: value,
      min: 1,
      max: 40,
      onChanged: (v) => setState(() => value = v),
    );
  }
}
```

## Additional information

- A runnable demo app is included in `example/`.
