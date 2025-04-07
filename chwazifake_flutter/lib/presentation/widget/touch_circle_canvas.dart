import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import '../../domain/model/circle_state.dart';
import 'dart:math' as math;

class TouchCircleCanvas extends StatelessWidget {
  final List<CircleState> circles;
  final Function(Offset) onTouch;
  final Function(Offset) onRelease;
  final Function(Offset, Offset) onMove;
  final VoidCallback onAnimate;

  const TouchCircleCanvas({
    super.key,
    required this.circles,
    required this.onTouch,
    required this.onRelease,
    required this.onMove,
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
      onPointerMove: (event) {
        developer.log('Touch moved to: ${event.localPosition} (pointer: ${event.pointer})');
        onMove(event.position, event.localPosition);
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
    for (final circle in circles) {
      // 원 그리기
      final circlePaint = Paint()
        ..color = circle.color
        ..style = PaintingStyle.fill;

      canvas.drawCircle(circle.position, circle.radius, circlePaint);

      // 회전하는 테두리
      final rotatingArcPaint = Paint()
        ..color = circle.color.withAlpha((255 * 0.5).toInt())  // 50% 불투명도
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6.0
        ..strokeCap = StrokeCap.round;

      final rect = Rect.fromCircle(
        center: circle.position,
        radius: circle.radius + 5,
      );

      // 첫 번째 호
      canvas.drawArc(
        rect,
        circle.rotationAngle,
        math.pi * 5/3,  // 300도
        false,
        rotatingArcPaint,
      );
    }
  }

  @override
  bool shouldRepaint(CirclePainter oldDelegate) {
    return true;
  }
} 