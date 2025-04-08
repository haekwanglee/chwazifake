import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../domain/model/circle_state.dart';
import '../../domain/usecase/handle_circle_usecase.dart';
import '../../domain/repository/circle_repository.dart';
import 'dart:developer' as developer;
import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'dart:math' as math;
import 'package:flutter/painting.dart';

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
  final Set<int> _activePointerIds = {};  // 활성화된 포인터 ID 추적
  AudioPlayer _focusAudioPlayer = AudioPlayer();  // 포커스 효과음용 오디오 플레이어
  AudioPlayer _touchAudioPlayer = AudioPlayer();  // 터치 효과음용 오디오 플레이어

  CircleNotifier(this._handleCircleUseCase) : super([]) {
    _initAudio();  // 생성자에서 _initAudio 호출
  }

  static const List<Color> colors = [
    // 밝은 색상
    Color(0xFFFFEB3B), // 밝은 노랑
    Color(0xFFFFC107), // 호박색
    Color(0xFFFF9800), // 주황색
    Color(0xFFFF5722), // 진한 주황
    Color(0xFFE91E63), // 핑크
    Color(0xFFFF4081), // 밝은 핑크
    Color(0xFF9C27B0), // 보라
    Color(0xFF673AB7), // 진한 보라
    Color(0xFF3F51B5), // 인디고
    Color(0xFF2196F3), // 밝은 파랑
    Color(0xFF03A9F4), // 하늘색
    Color(0xFF00BCD4), // 청록
    Color(0xFF009688), // 틸
    Color(0xFF4CAF50), // 초록
    Color(0xFF8BC34A), // 라임
    Color(0xFFCDDC39), // 연한 라임
    Color(0xFFFFEB3B), // 노랑
    Color(0xFFFFC107), // 호박색
    Color(0xFFFF9800), // 주황색
    Color(0xFFFF5722), // 진한 주황
    Color(0xFFE91E63), // 핑크
    Color(0xFFFF4081), // 밝은 핑크
    Color(0xFF9C27B0), // 보라
    Color(0xFF673AB7), // 진한 보라
    Color(0xFF3F51B5), // 인디고
    Color(0xFF2196F3), // 밝은 파랑
    Color(0xFF03A9F4), // 하늘색
    Color(0xFF00BCD4), // 청록
    Color(0xFF009688), // 틸
    Color(0xFF4CAF50), // 초록
    // 추가 색상
    Color(0xFF795548), // 갈색
    Color(0xFF607D8B), // 청회색
    Color(0xFF9E9E9E), // 회색
    Color(0xFFF44336), // 빨강
    Color(0xFFFF5252), // 밝은 빨강
    Color(0xFFFF1744), // 진한 빨강
    Color(0xFFD50000), // 어두운 빨강
    Color(0xFF00E676), // 밝은 초록
    Color(0xFF00C853), // 진한 초록
    Color(0xFF00BFA5), // 청록
    Color(0xFF00ACC1), // 진한 청록
    Color(0xFF0091EA), // 밝은 파랑
    Color(0xFF2962FF), // 진한 파랑
    Color(0xFF304FFE), // 어두운 파랑
    Color(0xFF651FFF), // 보라
    Color(0xFF7C4DFF), // 밝은 보라
    Color(0xFF6200EA), // 진한 보라
    Color(0xFFAA00FF), // 자주
    Color(0xFFD500F9), // 밝은 자주
    Color(0xFFC51162), // 진한 자주
    Color(0xFFFF6D00), // 주황
  ];

  Future<void> _initAudio() async {
    try {
      // 포커스 효과음 초기화
      await _focusAudioPlayer.setAsset('assets/audio/focus_sound.mp3');
      await _focusAudioPlayer.setVolume(1.0);
      await _focusAudioPlayer.setSpeed(1.0);
      
      // 터치 효과음 초기화
      await _touchAudioPlayer.setAsset('assets/audio/touch_sound.mp3');
      await _touchAudioPlayer.setVolume(0.7);
      await _touchAudioPlayer.setSpeed(1.0);
      await _touchAudioPlayer.setLoopMode(LoopMode.off);
      
      developer.log('Audio initialization completed successfully');
    } catch (e) {
      developer.log('Error initializing audio: $e');
      // 오류 발생 시 오디오 플레이어 재초기화
      await _cleanupAudioPlayers();
      _focusAudioPlayer = AudioPlayer();
      _touchAudioPlayer = AudioPlayer();
      await _initAudio();
    }
  }

  Future<void> _cleanupAudioPlayers() async {
    try {
      await _focusAudioPlayer.dispose();
      await _touchAudioPlayer.dispose();
    } catch (e) {
      developer.log('Error during audio cleanup: $e');
    }
  }

  void playFocusSound() async {
    try {
      developer.log('Attempting to play focus sound...');
      await _focusAudioPlayer.seek(Duration.zero);
      await _focusAudioPlayer.play();
      developer.log('Focus sound playback started');
    } catch (e) {
      developer.log('Error playing focus sound: $e');
      // 재생 실패 시 오디오 재초기화
      await _initAudio();
    }
  }

  void playTouchSound() async {
    try {
      developer.log('Attempting to play touch sound...');
      await _touchAudioPlayer.seek(Duration.zero);
      await _touchAudioPlayer.play();
      developer.log('Touch sound playback started');
    } catch (e) {
      developer.log('Error playing touch sound: $e');
      // 재생 실패 시 오디오 재초기화
      await _initAudio();
    }
  }

  // 색상 간의 차이를 계산하는 메서드 (HSV 색상 공간 사용)
  double _calculateColorDifference(Color color1, Color color2) {
    // RGB를 HSV로 변환
    final hsv1 = HSVColor.fromColor(color1);
    final hsv2 = HSVColor.fromColor(color2);
    
    // 색상(H), 채도(S), 명도(V) 차이 계산
    final hueDiff = (hsv1.hue - hsv2.hue).abs();
    final saturationDiff = (hsv1.saturation - hsv2.saturation).abs();
    final valueDiff = (hsv1.value - hsv2.value).abs();
    
    // 가중치를 적용하여 전체 차이 계산
    // 색상 차이에 더 큰 가중치를 부여
    return (hueDiff * 0.6) + (saturationDiff * 0.2) + (valueDiff * 0.2);
  }

  // 이전 터치와 가장 다른 색상 선택
  Color _selectDistinctColor() {
    if (state.isEmpty) {
      return colors[math.Random().nextInt(colors.length)];  // 첫 번째 터치인 경우 랜덤 색상 사용
    }

    // 최근 10개의 색상을 고려하여 선택
    final recentColors = state.length > 10 
        ? state.sublist(state.length - 10).map((c) => c.color).toList()
        : state.map((c) => c.color).toList();
    
    // 사용 가능한 색상 중에서 랜덤하게 5개 선택
    final availableColors = List<Color>.from(colors);
    availableColors.shuffle(math.Random());
    final candidateColors = availableColors.take(5).toList();
    
    // 후보 색상들 중에서 최근 색상들과 가장 다른 색상 선택
    var maxDifference = 0.0;
    var selectedColor = candidateColors[0];
    
    for (final color in candidateColors) {
      // 현재 색상과 최근 색상들의 평균 차이 계산
      final averageDifference = recentColors
          .map((c) => _calculateColorDifference(color, c))
          .reduce((a, b) => a + b) / recentColors.length;
      
      if (averageDifference > maxDifference) {
        maxDifference = averageDifference;
        selectedColor = color;
      }
    }
    
    return selectedColor;
  }

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

    // 터치 효과음 재생
    playTouchSound();

    // 이전 터치와 다른 색상 선택
    final selectedColor = _selectDistinctColor();
    final newCircle = _handleCircleUseCase.createCircle(position, color: selectedColor);
    
    // 포인터 ID와 원 ID 매핑 저장
    if (pointerId != null) {
      _pointerToCircleId[pointerId] = newCircle.id;
    }
    
    // 새로운 터치가 발생했을 때만 마지막 터치 갱신
    _lastTouchedCircleId = newCircle.id;
    
    developer.log('Creating circle at: $position with color: $selectedColor (total circles: ${state.length + 1})');
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
        final newProgress = (circle.focusProgress + 0.016).clamp(0.0, 1.0);
        updatedCircle = circle.copyWith(
          focusProgress: newProgress,
          isFocused: true
        );
        
        if (newProgress >= 1.0 && _holdTimer == null) {
          _holdTimer = Timer(const Duration(seconds: 2), () {
            reset();
            developer.log('Hold timer completed, resetting state');
          });
        }
      } else if (circle.isTouching) {
        updatedCircle = _handleCircleUseCase.animateCircle(circle);
        developer.log('Circle ${circle.id} radius: ${updatedCircle.radius}');
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
    
    // 레이어가 사라질 때 효과음 정지
    try {
      _focusAudioPlayer.stop();
      _touchAudioPlayer.stop();
    } catch (e) {
      developer.log('Error stopping audio during reset: $e');
    }
  }

  @override
  void dispose() {
    _focusTimer?.cancel();
    _holdTimer?.cancel();
    _cleanupAudioPlayers();
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

      // 진동 피드백이 끝난 후, 레이어가 등장하기 직전에 효과음 재생
      playFocusSound();
      
      // 짧은 지연 후 레이어 등장
      await Future.delayed(const Duration(milliseconds: 100));
      
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