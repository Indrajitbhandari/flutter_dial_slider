import 'package:flutter/material.dart';
import 'dial_control.dart';

class DialSlider extends StatelessWidget {
  final int initialValue;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const DialSlider({
    super.key,
    required this.initialValue,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 360,
      height: 190,
      child: DialControl(
        initialValue: initialValue,
        min: min,
        max: max,
        onSelected: (value) {
          onChanged(value);
        },
      ),
    );
  }
}
