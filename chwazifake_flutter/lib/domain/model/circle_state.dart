import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class CircleState extends Equatable {
  final String id;
  final Offset position;
  final Color color;
  final double radius;
  final bool isGrowing;
  final double rotationAngle;
  final bool isTouching;
  final bool isFocused;
  final double focusProgress;
  final double touchHoldProgress;

  static const double minRadius = 0.0;
  static const double maxRadius = 50.0;
  static const double initialRadius = 20.0;
  static const double animationStep = 1.0;
  static const double rotationStep = 0.02;
  static const double growthStep = 1.0;
  static const double pulseSpeed = 0.01;  // 맥박 속도를 0.03에서 0.01로 감소
  static const double pulseAmplitude = 0.2;  // 맥박 진폭은 유지

  const CircleState({
    required this.id,
    required this.position,
    required this.color,
    required this.radius,
    required this.isGrowing,
    this.rotationAngle = 0.0,
    this.isTouching = false,
    this.isFocused = false,
    this.focusProgress = 0.0,
    this.touchHoldProgress = 0.0,
  });

  factory CircleState.create({
    required Offset position,
    required Color color,
  }) {
    return CircleState(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      position: position,
      color: color,
      radius: initialRadius,
      isGrowing: true,
      rotationAngle: 0.0,
      isTouching: true,
      isFocused: false,
      focusProgress: 0.0,
      touchHoldProgress: 0.5,
    );
  }

  CircleState grow() {
    if (!isTouching && !isGrowing) {
      // 터치를 놓았을 때 사라지는 애니메이션
      final newRadius = radius - animationStep;
      if (newRadius <= 0) {
        return copyWith(radius: 0);
      }
      return copyWith(
        radius: newRadius,
        rotationAngle: rotationAngle + rotationStep,
      );
    } else if (isTouching) {
      // 심장이 두근두근 거리는 효과
      // 사인 함수를 사용하여 부드러운 맥박 효과 생성
      final pulse = math.sin(touchHoldProgress * math.pi * 2) * pulseAmplitude;
      final newProgress = 0.5 + pulse;  // 0.5를 중심으로 맥박
      
      // initialRadius에서 maxRadius 사이에서 크기 변화
      final newRadius = initialRadius + (maxRadius - initialRadius) * newProgress;
      
      return copyWith(
        radius: newRadius,
        rotationAngle: rotationAngle + rotationStep,
        touchHoldProgress: (touchHoldProgress + pulseSpeed) % 1.0,  // 0~1 사이에서 순환
      );
    } else {
      final newRadius = radius + animationStep;
      if (newRadius >= maxRadius) {
        return copyWith(
          radius: maxRadius,
          rotationAngle: rotationAngle + rotationStep,
        );
      }
      return copyWith(
        radius: newRadius,
        rotationAngle: rotationAngle + rotationStep,
      );
    }
  }

  bool shouldBeRemoved() {
    return !isTouching && radius <= 0;
  }

  CircleState changeDirection() {
    return copyWith(isGrowing: !isGrowing, isTouching: false);
  }

  CircleState copyWith({
    String? id,
    Offset? position,
    Color? color,
    double? radius,
    bool? isGrowing,
    double? rotationAngle,
    bool? isTouching,
    bool? isFocused,
    double? focusProgress,
    double? touchHoldProgress,
  }) {
    return CircleState(
      id: id ?? this.id,
      position: position ?? this.position,
      color: color ?? this.color,
      radius: radius ?? this.radius,
      isGrowing: isGrowing ?? this.isGrowing,
      rotationAngle: rotationAngle ?? this.rotationAngle,
      isTouching: isTouching ?? this.isTouching,
      isFocused: isFocused ?? this.isFocused,
      focusProgress: focusProgress ?? this.focusProgress,
      touchHoldProgress: touchHoldProgress ?? this.touchHoldProgress,
    );
  }

  @override
  List<Object?> get props => [id, position, color, radius, isGrowing, rotationAngle, isTouching, isFocused, focusProgress, touchHoldProgress];
} 