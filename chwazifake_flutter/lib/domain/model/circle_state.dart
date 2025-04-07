import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class CircleState extends Equatable {
  final String id;
  final Offset position;
  final Color color;
  final double radius;
  final bool isGrowing;
  final double rotationAngle;
  final bool isTouching;

  static const double minRadius = 0.0;
  static const double maxRadius = 35.0;
  static const double initialRadius = 20.0;
  static const double animationStep = 2.0;
  static const double rotationStep = 0.02;
  static const double growthStep = 1.0;

  const CircleState({
    required this.id,
    required this.position,
    required this.color,
    required this.radius,
    required this.isGrowing,
    this.rotationAngle = 0.0,
    this.isTouching = false,
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
    );
  }

  CircleState grow() {
    if (!isTouching && !isGrowing) {
      final newRadius = radius - animationStep;
      if (newRadius <= 0) {
        return copyWith(radius: 0);
      }
      return copyWith(
        radius: newRadius,
        rotationAngle: rotationAngle + rotationStep,
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
  }) {
    return CircleState(
      id: id ?? this.id,
      position: position ?? this.position,
      color: color ?? this.color,
      radius: radius ?? this.radius,
      isGrowing: isGrowing ?? this.isGrowing,
      rotationAngle: rotationAngle ?? this.rotationAngle,
      isTouching: isTouching ?? this.isTouching,
    );
  }

  @override
  List<Object?> get props => [id, position, color, radius, isGrowing, rotationAngle, isTouching];
} 