import 'package:dial_slider/dial_slider.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dial Slider Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff00A6CE)),
      ),
      home: const DialSliderExamplePage(),
    );
  }
}

class DialSliderExamplePage extends StatefulWidget {
  const DialSliderExamplePage({super.key});

  @override
  State<DialSliderExamplePage> createState() => _DialSliderExamplePageState();
}

class _DialSliderExamplePageState extends State<DialSliderExamplePage> {
  int selectedWeek = 20;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Dial Slider Example'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Selected: $selectedWeek',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              const Text('Drag left/right or tap a tick.'),
              const SizedBox(height: 12),
              FittedBox(
                child: DialSlider(
                  initialValue: selectedWeek,
                  min: 1,
                  max: 50,
                  onChanged: (value) => setState(() => selectedWeek = value),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
