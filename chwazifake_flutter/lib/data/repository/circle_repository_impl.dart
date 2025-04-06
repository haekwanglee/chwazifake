import 'package:chwazifake_flutter/domain/model/circle_state.dart';
import 'package:chwazifake_flutter/domain/repository/circle_repository.dart';

class CircleRepositoryImpl implements CircleRepository {
  final List<CircleState> _circles = [];

  @override
  List<CircleState> getCircles() => List.unmodifiable(_circles);

  @override
  void addCircle(CircleState circle) {
    if (_circles.length < 10) {
      _circles.add(circle);
    }
  }

  @override
  void removeCircle(CircleState circle) {
    _circles.removeWhere((element) => element.id == circle.id);
  }

  @override
  void updateCircle(CircleState circle) {
    final index = _circles.indexWhere((element) => element.id == circle.id);
    if (index != -1) {
      _circles[index] = circle;
    }
  }
} 