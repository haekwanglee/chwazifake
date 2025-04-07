import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import '../../domain/model/circle_state.dart';
import 'dart:math' as math;

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
      canvas.save();
      canvas.translate(circle.position.dx, circle.position.dy);
      
      // 중심 원
      final centerPaint = Paint()
        ..color = circle.color
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset.zero,
        circle.radius * 0.8,  // 중심 원은 테두리보다 약간 작게
        centerPaint,
      );

      // 회전하는 테두리
      final rotatingArcPaint = Paint()
        ..color = circle.color.withOpacity(0.7)  // 테두리에 30% 투명도 추가
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6.0
        ..strokeCap = StrokeCap.round;

      // 회전하는 원호 (약 300도)
      canvas.save();
      canvas.rotate(circle.rotationAngle);
      canvas.drawArc(
        Rect.fromCircle(center: Offset.zero, radius: circle.radius),
        0,  // 0도부터 시작
        math.pi * 5/3,  // 300도 만큼 그림
        false,
        rotatingArcPaint,
      );
      canvas.restore();

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(CirclePainter oldDelegate) {
    return oldDelegate.circles != circles;
  }
} 