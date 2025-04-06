import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class CircleState extends Equatable {
  final String id;
  final Offset position;
  final Color color;
  final double innerRadius;
  final double outerRadius;
  final bool isGrowing;

  static const double minRadius = 20.0;
  static const double maxRadius = 100.0;
  static const double animationStep = 2.0;

  const CircleState({
    required this.id,
    required this.position,
    required this.color,
    required this.innerRadius,
    required this.outerRadius,
    required this.isGrowing,
  });

  factory CircleState.create({
    required Offset position,
    required Color color,
  }) {
    return CircleState(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      position: position,
      color: color,
      innerRadius: minRadius,
      outerRadius: minRadius + 10,
      isGrowing: true,
    );
  }

  CircleState grow() {
    if (!isGrowing) {
      final newInnerRadius = innerRadius - animationStep;
      final newOuterRadius = outerRadius - animationStep;
      
      if (newInnerRadius <= 0) {
        return copyWith(
          innerRadius: 0,
          outerRadius: 0,
        );
      }
      
      return copyWith(
        innerRadius: newInnerRadius,
        outerRadius: newOuterRadius,
      );
    } else {
      final newInnerRadius = innerRadius + animationStep;
      final newOuterRadius = outerRadius + animationStep;
      
      if (newOuterRadius >= maxRadius) {
        return copyWith(
          innerRadius: maxRadius - 10,
          outerRadius: maxRadius,
          isGrowing: false,
        );
      }
      
      return copyWith(
        innerRadius: newInnerRadius,
        outerRadius: newOuterRadius,
      );
    }
  }

  bool shouldBeRemoved() {
    return innerRadius <= 0;
  }

  CircleState changeDirection() {
    return copyWith(isGrowing: !isGrowing);
  }

  CircleState copyWith({
    String? id,
    Offset? position,
    Color? color,
    double? innerRadius,
    double? outerRadius,
    bool? isGrowing,
  }) {
    return CircleState(
      id: id ?? this.id,
      position: position ?? this.position,
      color: color ?? this.color,
      innerRadius: innerRadius ?? this.innerRadius,
      outerRadius: outerRadius ?? this.outerRadius,
      isGrowing: isGrowing ?? this.isGrowing,
    );
  }

  @override
  List<Object?> get props => [id, position, color, innerRadius, outerRadius, isGrowing];
} 