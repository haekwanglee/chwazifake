import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import '../../domain/model/circle_state.dart';

class TouchCircleCanvas extends StatelessWidget {
  final List<CircleState> circles;
  final Function(Offset) onTouch;
  final Function(Offset) onRelease;
  final VoidCallback onAnimate;

  const TouchCircleCanvas({
    super.key,
    required this.circles,
    required this.onTouch,
    required this.onRelease,
    required this.onAnimate,
  });

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (event) {
        developer.log('Touch detected at: ${event.localPosition} (pointer: ${event.pointer})');
        onTouch(event.localPosition);
      },
      onPointerUp: (event) {
        developer.log('Touch released at: ${event.localPosition} (pointer: ${event.pointer})');
        if (circles.isNotEmpty) {
          CircleState? closestCircle;
          double minDistance = double.infinity;
          
          for (var circle in circles) {
            final distance = (circle.position - event.localPosition).distance;
            if (distance < minDistance) {
              minDistance = distance;
              closestCircle = circle;
            }
          }
          
          if (closestCircle != null) {
            onRelease(closestCircle.position);
          }
        }
      },
      child: CustomPaint(
        painter: CirclePainter(circles: circles),
        size: Size.infinite,
        child: Container(
          color: Colors.transparent,
        ),
      ),
    );
  }
}

class CirclePainter extends CustomPainter {
  final List<CircleState> circles;

  CirclePainter({required this.circles});

  @override
  void paint(Canvas canvas, Size size) {
    for (var circle in circles) {
      // 외부 원
      final outerPaint = Paint()
        ..color = circle.color.withAlpha(128)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        circle.position,
        circle.outerRadius,
        outerPaint,
      );

      // 내부 원
      final innerPaint = Paint()
        ..color = circle.color
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        circle.position,
        circle.innerRadius,
        innerPaint,
      );
    }
  }

  @override
  bool shouldRepaint(CirclePainter oldDelegate) {
    return oldDelegate.circles != circles;
  }
} 