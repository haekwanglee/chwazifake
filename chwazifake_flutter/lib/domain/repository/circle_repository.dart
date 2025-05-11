import '../model/circle_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final circleRepositoryProvider = Provider<CircleRepository>((ref) {
  return CircleRepositoryImpl();
});

abstract class CircleRepository {
  List<CircleState> getCircles();
  void addCircle(CircleState circle);
  void removeCircle(CircleState circle);
  void updateCircle(CircleState circle);
}

class CircleRepositoryImpl implements CircleRepository {
  final List<CircleState> _circles = [];

  @override
  List<CircleState> getCircles() => _circles;

  @override
  void addCircle(CircleState circle) {
    _circles.add(circle);
  }

  @override
  void removeCircle(CircleState circle) {
    _circles.remove(circle);
  }

  @override
  void updateCircle(CircleState circle) {
    // Implementation needed
  }
} 