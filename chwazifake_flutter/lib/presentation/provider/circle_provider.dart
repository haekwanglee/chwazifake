import 'package:flutter/services.dart';
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
  static const int maxCircles = 10;
  Timer? _focusTimer;
  Timer? _holdTimer;
  String? _lastTouchedCircleId;
  bool _isAnimationComplete = false;
  bool _isHolding = false;
  int _activePointers = 0;
  final Map<int, String> _pointerToCircleId = {};  // 포인터 ID와 원 ID 매핑

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

  void onTouch(Offset position, {int? pointerId}) {
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
    
    // 포인터 ID와 원 ID 매핑 저장
    if (pointerId != null) {
      _pointerToCircleId[pointerId] = newCircle.id;
    }
    
    // 새로운 터치가 발생했을 때만 마지막 터치 갱신
    _lastTouchedCircleId = newCircle.id;
    
    developer.log('Creating circle at: $position (total circles: ${state.length + 1})');
    state = [...state, newCircle];

    // 4초 타이머 재설정
    _startFocusTimer();
  }

  void onMove(Offset globalPosition, Offset localPosition, {int? pointerId}) {
    // 애니메이션이 완료되었거나 holding 상태라면 이동 무시
    if (_isAnimationComplete || _isHolding) {
      developer.log('Move ignored: animation complete or holding');
      return;
    }

    if (state.isEmpty) return;

    String? targetCircleId = pointerId != null ? _pointerToCircleId[pointerId] : null;
    
    if (targetCircleId != null) {
      // 특정 포인터에 매핑된 원 찾기
      final circleIndex = state.indexWhere((circle) => circle.id == targetCircleId);
      if (circleIndex != -1) {
        final updatedCircles = List<CircleState>.from(state);
        final updatedCircle = state[circleIndex].copyWith(
          position: localPosition,
        );
        updatedCircles[circleIndex] = updatedCircle;
        state = updatedCircles;
      }
    }
  }

  void onRelease(Offset position, {int? pointerId}) {
    _activePointers--;
    developer.log('Pointer released. Active pointers: $_activePointers');
    
    if (pointerId != null) {
      // 해당 포인터에 매핑된 원 제거 (사라지는 애니메이션 적용)
      final circleId = _pointerToCircleId.remove(pointerId);
      if (circleId != null) {
        final updatedCircles = state.map((circle) {
          if (circle.id == circleId) {
            return circle.copyWith(
              isGrowing: false,  // 사라지는 애니메이션 시작
              isTouching: false  // 터치 상태 해제
            );
          }
          return circle;
        }).toList();
        state = updatedCircles;
      }
    }

    // 모든 손가락이 떼어졌을 때 초기화
    if (_activePointers <= 0) {
      _activePointers = 0;
      if (_isAnimationComplete || _isHolding) {
        reset();
        developer.log('All pointers released, resetting state');
      } else if (state.isNotEmpty) {
        // 마지막으로 터치된 원에 대해 포커스 애니메이션 시작
        _startFocusTimer();
      }
      return;
    }

    // 애니메이션이 완료되었거나 holding 상태라면 릴리즈 무시
    if (_isAnimationComplete || _isHolding) {
      developer.log('Release ignored: animation complete or holding');
      return;
    }
  }

  void animateCircles() {
    if (state.isEmpty) return;

    final updatedCircles = <CircleState>[];

    for (final circle in state) {
      var updatedCircle = circle;
      
      if (circle.isFocused) {
        // 포커스 애니메이션 진행 (속도 2배 증가)
        final newProgress = (circle.focusProgress + 0.016).clamp(0.0, 1.0);
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
      } else {
        updatedCircle = _handleCircleUseCase.animateCircle(circle);
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
    _pointerToCircleId.clear();
    state = [];
    developer.log('State reset completed');
  }

  @override
  void dispose() {
    _focusTimer?.cancel();
    _holdTimer?.cancel();
    super.dispose();
  }

  // 포커스 타이머 시작 메서드 추출
  void _startFocusTimer() {
    _focusTimer?.cancel();
    _holdTimer?.cancel();
    _isHolding = false;
    _isAnimationComplete = false;

    _focusTimer = Timer(const Duration(seconds: 4), () async {
      if (state.isEmpty) return;

      // 최대 강도의 진동 피드백
      for (int i = 0; i < 2; i++) {
        await HapticFeedback.vibrate();
        await Future.delayed(const Duration(milliseconds: 50));
        await HapticFeedback.heavyImpact();
        await Future.delayed(const Duration(milliseconds: 50));
        await HapticFeedback.vibrate();
        await Future.delayed(const Duration(milliseconds: 50));
        await HapticFeedback.heavyImpact();
        await Future.delayed(const Duration(milliseconds: 100));
      }

      if (state.isEmpty) return;  // 진동 중에 상태가 변경될 수 있으므로 한번 더 체크

      final updatedCircles = state.map((circle) {
        if (circle.id == _lastTouchedCircleId) {
          return circle.copyWith(isFocused: true);
        }
        return circle;
      }).toList();

      state = updatedCircles;
      _isHolding = true;
      developer.log('Focus animation started for circle: $_lastTouchedCircleId');
    });
  }
} 