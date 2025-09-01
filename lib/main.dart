import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'widgets/starry_painter.dart'; // StarryPainter که اصلاح شد
import 'audio_manager.dart'; // سیستم مدیریت چند صدا

void main() {
  runApp(const RamaApp());
}

class RamaApp extends StatelessWidget {
  const RamaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StarryBackgroundPage(),
    );
  }
}

class StarryBackgroundPage extends StatefulWidget {
  const StarryBackgroundPage({super.key});

  @override
  _StarryBackgroundPageState createState() => _StarryBackgroundPageState();
}

class _StarryBackgroundPageState extends State<StarryBackgroundPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    // شروع موزیک پس‌زمینه با AudioManager
    AudioManager().play("bg", "rain.mp3", loop: true, volume: 0.5);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    AudioManager().stopAll(); // توقف صداها هنگام خروج
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: StarryPainter(progress: _controller.value),
            size: MediaQuery.of(context).size,
          );
        },
      ),
    );
  }
}
