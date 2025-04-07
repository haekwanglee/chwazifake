import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import '../../domain/model/circle_state.dart';
import 'dart:math' as math;

class TouchCircleCanvas extends StatelessWidget {
  final List<CircleState> circles;
  final Function(Offset, {int? pointerId}) onTouch;
  final Function(Offset, {int? pointerId}) onRelease;
  final Function(Offset, Offset, {int? pointerId}) onMove;
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
        onTouch(event.localPosition, pointerId: event.pointer);
      },
      onPointerMove: (event) {
        developer.log('Touch moved to: ${event.localPosition} (pointer: ${event.pointer})');
        onMove(event.position, event.localPosition, pointerId: event.pointer);
      },
      onPointerUp: (event) {
        developer.log('Touch released at: ${event.localPosition} (pointer: ${event.pointer})');
        onRelease(event.localPosition, pointerId: event.pointer);
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
    if (circles.isEmpty) return;

    // 일반 원들 먼저 그리기
    for (final circle in circles.where((c) => !c.isFocused)) {
      _drawCircle(canvas, circle);
    }

    // 포커스된 원 찾기
    final focusedCircle = circles.firstWhere(
      (c) => c.isFocused,
      orElse: () => circles[0],
    );

    // 포커스 애니메이션 그리기
    if (focusedCircle.isFocused) {
      // 화면 전체를 마지막 선택된 원의 색상으로 덮는 레이어
      final backgroundPaint = Paint()
        ..color = focusedCircle.color
        ..style = PaintingStyle.fill;

      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        backgroundPaint,
      );

      // 중앙 구멍 (투명)
      final holePaint = Paint()
        ..color = Colors.transparent
        ..style = PaintingStyle.fill
        ..blendMode = BlendMode.clear;

      // 구멍의 크기는 애니메이션 진행도에 따라 감소
      final maxHoleRadius = math.min(size.width, size.height) * 0.9; // 화면 크기의 90%로 증가 (2배)
      final minHoleRadius = focusedCircle.radius * 1.8; // 원래 원 크기의 1.8배 유지
      final holeRadius = maxHoleRadius - (maxHoleRadius - minHoleRadius) * focusedCircle.focusProgress;

      canvas.drawCircle(
        focusedCircle.position,
        holeRadius,
        holePaint,
      );

      // 포커스된 원 다시 그리기
      _drawCircle(canvas, focusedCircle);
    }
  }

  void _drawCircle(Canvas canvas, CircleState circle) {
    // 원 그리기
    final circlePaint = Paint()
      ..color = circle.color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(circle.position, circle.radius, circlePaint);

    // 회전하는 테두리
    final rotatingArcPaint = Paint()
      ..color = circle.color.withAlpha((255 * 0.5).toInt())
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(
      center: circle.position,
      radius: circle.radius + 5,
    );

    canvas.drawArc(
      rect,
      circle.rotationAngle,
      math.pi * 5/3,
      false,
      rotatingArcPaint,
    );
  }

  @override
  bool shouldRepaint(CirclePainter oldDelegate) {
    return true;
  }
} 