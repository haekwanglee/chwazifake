import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../domain/model/circle_state.dart';
import '../../domain/usecase/handle_circle_usecase.dart';
import '../../domain/repository/circle_repository.dart';
import 'dart:developer' as developer;

final circleProvider = StateNotifierProvider<CircleNotifier, List<CircleState>>((ref) {
  return CircleNotifier(ref.watch(handleCircleUseCaseProvider));
});

final handleCircleUseCaseProvider = Provider((ref) {
  return HandleCircleUseCase(ref.watch(circleRepositoryProvider));
});

final circleRepositoryProvider = Provider((ref) {
  return CircleRepositoryImpl();
});

class CircleNotifier extends StateNotifier<List<CircleState>> {
  final HandleCircleUseCase _handleCircleUseCase;
  static const int maxCircles = 10;  // 최대 동시 터치 개수

  CircleNotifier(this._handleCircleUseCase) : super([]);

  static const List<Color> colors = [
    Color(0xFF2196F3), // Blue
    Color(0xFFE91E63), // Red
    Color(0xFF4CAF50), // Green
    Color(0xFFFFEB3B), // Yellow
    Color(0xFF9C27B0), // Purple
    Color(0xFFFF9800), // Orange
    Color(0xFF00BCD4), // Cyan
    Color(0xFFFF4081), // Pink
    Color(0xFF009688), // Teal
    Color(0xFFCDDC39), // Lime
  ];

  void onTouch(Offset position) {
    if (state.length >= maxCircles) {
      developer.log('Maximum number of circles reached: $maxCircles');
      return;
    }

    final newCircle = _handleCircleUseCase.createCircle(position);
    developer.log('Creating circle at: $position (total circles: ${state.length + 1})');
    state = [...state, newCircle];
  }

  void onMove(Offset globalPosition, Offset localPosition) {
    if (state.isEmpty) return;

    // 이동된 터치 포인트와 가장 가까운 원을 찾습니다
    var minDistance = double.infinity;
    var closestCircleIndex = -1;

    for (var i = 0; i < state.length; i++) {
      final distance = (state[i].position - globalPosition).distance;
      if (distance < minDistance) {
        minDistance = distance;
        closestCircleIndex = i;
      }
    }

    if (closestCircleIndex != -1 && minDistance < 100) {  // 100은 터치 인식 범위
      final updatedCircles = List<CircleState>.from(state);
      updatedCircles[closestCircleIndex] = state[closestCircleIndex].copyWith(
        position: localPosition,
      );
      state = updatedCircles;
      developer.log('Moving circle at index $closestCircleIndex to: $localPosition');
    }
  }

  void onRelease(Offset position) {
    if (state.isEmpty) {
      developer.log('No circles to release');
      return;
    }

    // 가장 가까운 원을 찾아서 방향을 바꿈
    var minDistance = double.infinity;
    var closestCircleIndex = -1;

    for (var i = 0; i < state.length; i++) {
      final distance = (state[i].position - position).distance;
      if (distance < minDistance) {
        minDistance = distance;
        closestCircleIndex = i;
      }
    }

    if (closestCircleIndex != -1) {
      final updatedCircles = List<CircleState>.from(state);
      updatedCircles[closestCircleIndex] = _handleCircleUseCase.changeGrowthDirection(state[closestCircleIndex]);
      developer.log('Changing direction for circle at index: $closestCircleIndex');
      state = updatedCircles;
    }
  }

  void animateCircles() {
    if (state.isEmpty) return;

    final updatedCircles = <CircleState>[];
    var circlesRemoved = false;

    for (final circle in state) {
      final updatedCircle = _handleCircleUseCase.animateCircle(circle);
      if (!updatedCircle.shouldBeRemoved()) {
        updatedCircles.add(updatedCircle);
      } else {
        circlesRemoved = true;
        developer.log('Removing circle at: ${circle.position}');
      }
    }

    if (updatedCircles.length != state.length || circlesRemoved) {
      developer.log('Circles after animation: ${updatedCircles.length}');
    }
    
    state = updatedCircles;
  }
} 