import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../domain/model/circle_state.dart';
import '../../domain/usecase/handle_circle_usecase.dart';
import '../../domain/repository/circle_repository.dart';
import 'dart:developer' as developer;
import 'dart:async';

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
  Timer? _focusTimer;
  Timer? _holdTimer;
  String? _lastTouchedCircleId;
  bool _isAnimationComplete = false;
  bool _isHolding = false;
  int _activePointers = 0;

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
    _activePointers++;
    
    // 애니메이션이 완료되었거나 holding 상태라면 터치 무시
    if (_isAnimationComplete || _isHolding) {
      developer.log('Touch ignored: animation complete or holding');
      return;
    }

    if (state.length >= maxCircles) {
      developer.log('Maximum number of circles reached: $maxCircles');
      return;
    }

    // 이전 타이머들 취소
    _focusTimer?.cancel();
    _holdTimer?.cancel();
    _isHolding = false;
    _isAnimationComplete = false;

    final newCircle = _handleCircleUseCase.createCircle(position);
    _lastTouchedCircleId = newCircle.id;
    developer.log('Creating circle at: $position (total circles: ${state.length + 1})');
    state = [...state, newCircle];

    // 4초 후 포커스 애니메이션 시작
    _focusTimer = Timer(const Duration(seconds: 4), () {
      if (state.isEmpty) return;

      final updatedCircles = state.map((circle) {
        if (circle.id == _lastTouchedCircleId) {
          return circle.copyWith(isFocused: true);
        }
        return circle;
      }).toList();

      state = updatedCircles;
      _isHolding = true;
    });
  }

  void onMove(Offset globalPosition, Offset localPosition) {
    // 애니메이션이 완료되었거나 holding 상태라면 이동 무시
    if (_isAnimationComplete || _isHolding) {
      developer.log('Move ignored: animation complete or holding');
      return;
    }

    if (state.isEmpty) return;

    var minDistance = double.infinity;
    var closestCircleIndex = -1;

    for (var i = 0; i < state.length; i++) {
      final distance = (state[i].position - globalPosition).distance;
      if (distance < minDistance) {
        minDistance = distance;
        closestCircleIndex = i;
      }
    }

    if (closestCircleIndex != -1 && minDistance < 100) {
      final updatedCircles = List<CircleState>.from(state);
      final updatedCircle = state[closestCircleIndex].copyWith(
        position: localPosition,
      );
      _lastTouchedCircleId = updatedCircle.id;
      updatedCircles[closestCircleIndex] = updatedCircle;
      state = updatedCircles;
    }
  }

  void onRelease(Offset position) {
    _activePointers--;
    developer.log('Pointer released. Active pointers: $_activePointers');
    
    // 모든 손가락이 떼어졌을 때 초기화
    if (_activePointers <= 0) {
      _activePointers = 0;
      if (_isAnimationComplete || _isHolding) {
        reset();
        developer.log('All pointers released, resetting state');
      }
      return;
    }

    // 애니메이션이 완료되었거나 holding 상태라면 릴리즈 무시
    if (_isAnimationComplete || _isHolding) {
      developer.log('Release ignored: animation complete or holding');
      return;
    }

    if (state.isEmpty) return;

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
      final updatedCircle = state[closestCircleIndex].copyWith(
        isGrowing: false,
      );
      _lastTouchedCircleId = updatedCircle.id;
      updatedCircles[closestCircleIndex] = updatedCircle;
      state = updatedCircles;
    }
  }

  void animateCircles() {
    if (state.isEmpty) return;

    final updatedCircles = <CircleState>[];
    bool allAnimationsComplete = true;

    for (final circle in state) {
      var updatedCircle = circle;
      
      if (circle.isFocused) {
        // 포커스 애니메이션 진행 (속도 감소)
        final newProgress = (circle.focusProgress + 0.01).clamp(0.0, 1.0);
        updatedCircle = circle.copyWith(
          focusProgress: newProgress,
          isFocused: true
        );
        
        // 애니메이션이 완료되고 아직 타이머가 설정되지 않았다면
        if (newProgress >= 1.0 && _holdTimer == null) {
          // 2초 후에 모든 원 제거
          _holdTimer = Timer(const Duration(seconds: 2), () {
            reset();
            developer.log('Hold timer completed, resetting state');
          });
        }
        
        // 아직 애니메이션이 완료되지 않았다면 체크
        if (newProgress < 1.0) {
          allAnimationsComplete = false;
        }
      } else {
        updatedCircle = _handleCircleUseCase.animateCircle(circle);
        allAnimationsComplete = false;
      }

      if (!updatedCircle.shouldBeRemoved()) {
        updatedCircles.add(updatedCircle);
      }
    }
    
    state = updatedCircles;
  }

  void reset() {
    _isAnimationComplete = false;
    _isHolding = false;
    _focusTimer?.cancel();
    _holdTimer?.cancel();
    _lastTouchedCircleId = null;
    state = [];
    developer.log('State reset completed');
  }

  @override
  void dispose() {
    _focusTimer?.cancel();
    _holdTimer?.cancel();
    super.dispose();
  }
} 