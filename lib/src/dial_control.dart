import 'dart:math';
import 'package:dial_slider/src/dial_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const smartCurve = Cubic(0.72, 0.02, 0.18, 1.0);

class DialControl extends StatefulWidget {
  final int initialValue;
  final int min;
  final int max;
  final ValueChanged<int> onSelected;

  const DialControl({
    super.key,
    required this.initialValue,
    required this.min,
    required this.max,
    required this.onSelected,
  });

  @override
  State<DialControl> createState() => _DialControlState();
}

class _DialControlState extends State<DialControl>
    with SingleTickerProviderStateMixin {
  static const int visibleCount = 9;
  static const int middleIndex = visibleCount ~/ 2;

  late AnimationController _controller;
  late Animation<double> _animation;

  double dialOffset = 0;
  double targetOffset = 0;
  double smoothVelocity = 0;

  int get totalValues => (widget.max - widget.min + 1).clamp(1, 1 << 30);

  double get minOffset => -middleIndex.toDouble();
  double get maxOffset => (totalValues - 1 - middleIndex).toDouble();

  int get startIndex => dialOffset.floor();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );

    final minValue = widget.min;
    final maxValue = widget.max;
    final initial = widget.initialValue.clamp(minValue, maxValue);
    final initialIndex = initial - minValue;

    dialOffset = (initialIndex - middleIndex).toDouble().clamp(
          minOffset,
          maxOffset,
        );

    targetOffset = dialOffset;
    _animation = AlwaysStoppedAnimation(dialOffset);
  }

  void animateDial({bool logAfterComplete = false}) {
    _controller.stop();

    targetOffset = targetOffset.clamp(minOffset, maxOffset);

    _animation = Tween<double>(
      begin: dialOffset,
      end: targetOffset,
    ).animate(CurvedAnimation(parent: _controller, curve: smartCurve));

    _animation.addListener(() {
      setState(() => dialOffset = _animation.value);
    });

    _controller.forward(from: 0);

    if (logAfterComplete) {
      Future.delayed(_controller.duration!, _logCurrentSelected);
    }
  }

  void _logCurrentSelected() {
    final selectedIndex =
        (dialOffset + middleIndex).round().clamp(0, totalValues - 1);
    final selected = widget.min + selectedIndex;

    debugPrint("🎯 Selected Value: $selected");
    widget.onSelected(selected);
  }

  void onDragUpdate(DragUpdateDetails details) {
    final input = -details.delta.dx * 0.05;
    smoothVelocity = smoothVelocity * 0.7 + input * 0.3;
    targetOffset += smoothVelocity;
    animateDial();
  }

  void onDragEnd(DragEndDetails details) {
    final inertia = smoothVelocity * 10;
    targetOffset += inertia;

    // 🔒 HARD SNAP to exact tick
    targetOffset = targetOffset.roundToDouble().clamp(minOffset, maxOffset);

    smoothVelocity = 0;

    animateDial(logAfterComplete: true);
    HapticFeedback.selectionClick();
  }

  void onTapDown(TapDownDetails d, Size size) {
    if (_controller.isAnimating) return;

    final x = d.localPosition.dx;
    final tappedSlot = (x / size.width) * visibleCount;
    final deltaFromCenter = tappedSlot - middleIndex;

    double newTarget = dialOffset + deltaFromCenter;

    if (deltaFromCenter > 0) {
      newTarget -= 1;
    }

    targetOffset = newTarget.roundToDouble().clamp(minOffset, maxOffset);

    animateDial(logAfterComplete: true);
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    final subOffset = dialOffset - startIndex;

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, 260);

        return ClipPath(
          clipper: SemiCircleClipper(),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanUpdate: onDragUpdate,
            onPanEnd: onDragEnd,
            onTapDown: (d) => onTapDown(d, size),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                CustomPaint(
                  size: size,
                  painter: DialPainter(
                    minValue: widget.min,
                    startIndex: startIndex,
                    subOffset: subOffset,
                    visibleCount: visibleCount,
                    totalValues: totalValues,
                  ),
                ),
                Positioned(
                  bottom: -12,
                  child: _InnerWidget(
                    label: 'Current Value',
                    value: widget.min +
                        (dialOffset + middleIndex)
                            .round()
                            .clamp(0, totalValues - 1),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _InnerWidget extends StatelessWidget {
  final String label;
  final int value;

  const _InnerWidget({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 12),
        Icon(Icons.arrow_drop_up, size: 40),
        Text(
          label,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Text(
          "$value",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xff00A6CE),
            height: 1.0,
          ),
        ),
        SizedBox(height: 18),
      ],
    );
  }
}

class SemiCircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;

    final path = Path();
    path.moveTo(0, size.height);
    path.arcTo(Rect.fromCircle(center: center, radius: radius), pi, pi, false);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
