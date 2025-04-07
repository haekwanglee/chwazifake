import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/circle_state.dart';
import '../repository/circle_repository.dart';
import 'dart:math';
import 'dart:developer' as developer;

final handleCircleUseCaseProvider = Provider<HandleCircleUseCase>((ref) {
  return HandleCircleUseCase(ref.watch(circleRepositoryProvider));
});

class HandleCircleUseCase {
  final CircleRepository _repository;
  static const List<Color> colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
    Colors.pink,
    Colors.teal,
    Colors.cyan,
    Colors.amber,
  ];

  final Random _random = Random();

  HandleCircleUseCase(this._repository);

  void addCircle(CircleState circle) {
    _repository.addCircle(circle);
  }

  void removeCircle(CircleState circle) {
    _repository.removeCircle(circle);
  }

  void updateCircle(CircleState circle) {
    _repository.updateCircle(circle);
  }

  List<CircleState> getCircles() => _repository.getCircles();

  CircleState createCircle(Offset position) {
    final circle = CircleState.create(
      position: position,
      color: colors[_random.nextInt(colors.length)],
    );
    developer.log('Creating new circle at $position with initial radius: ${circle.radius}');
    return circle;
  }

  CircleState animateCircle(CircleState circle) {
    final updatedCircle = circle.grow();
    
    if (updatedCircle.shouldBeRemoved()) {
      developer.log('Circle at ${circle.position} should be removed');
      return updatedCircle;
    }
    
    if (circle.isGrowing != updatedCircle.isGrowing) {
      developer.log('Circle at ${circle.position} changed direction: ${circle.isGrowing ? "growing" : "shrinking"} -> ${updatedCircle.isGrowing ? "growing" : "shrinking"}');
    }
    
    return updatedCircle;
  }

  CircleState changeGrowthDirection(CircleState circle) {
    final updatedCircle = circle.changeDirection();
    developer.log('Manually changing direction for circle at ${circle.position}: ${circle.isGrowing ? "growing" : "shrinking"} -> ${updatedCircle.isGrowing ? "growing" : "shrinking"}');
    return updatedCircle;
  }
} 