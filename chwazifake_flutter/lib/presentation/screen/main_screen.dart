import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../provider/circle_provider.dart';
import '../widget/touch_circle_canvas.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16), // ~60fps
    )..addListener(() {
        ref.read(circleProvider.notifier).animateCircles();
      });
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final circles = ref.watch(circleProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: TouchCircleCanvas(
        circles: circles,
        onTouch: ref.read(circleProvider.notifier).onTouch,
        onRelease: ref.read(circleProvider.notifier).onRelease,
        onAnimate: ref.read(circleProvider.notifier).animateCircles,
      ),
    );
  }
} 