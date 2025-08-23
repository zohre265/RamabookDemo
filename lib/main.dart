import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
void main() => runApp(const RamaBookApp());
class RamaBookApp extends StatelessWidget {
  const RamaBookApp({super.key});
  @override
  Widget build(BuildContext context) {
    final baseColor = const Color(0xFF0e1b3c);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RamaBook',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        scaffoldBackgroundColor: baseColor,
        useMaterial3: true,
      ),
      home: const DashboardPage(),
    );
  }
}
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}
class _DashboardPageState extends State<DashboardPage> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 20))..repeat();
  }
  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) => CustomPaint(
              painter: _StarryPainter(progress: _ctrl.value),
            ),
          ),
          SafeArea(
            child: Center(
              child: GlassCard(
                width: 380,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    const _Header(),
                    const SizedBox(height: 12),
                    GlassButton(text: "My Library",      onPressed: () {}),
                    const SizedBox(height: 10),
                    GlassButton(text: "Audio Player",     onPressed: () {}),
                    const SizedBox(height: 10),
                    GlassButton(text: "Profile",          onPressed: () {}),
                    const SizedBox(height: 10),
                    GlassButton(text: "Settings",         onPressed: () {}),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class _Header extends StatelessWidget {
  const _Header();
  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _CurvedHeaderClipper(),
      child: Container(
        height: 120,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0x3322c1ff), Color(0x3312a5ff)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: const [
            Align(
              alignment: Alignment.center,
              child: Text(
                "RamaBook",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  shadows: [Shadow(blurRadius: 12, color: Colors.black54, offset: Offset(0,2))],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class _CurvedHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final p = Path()
      ..lineTo(0, size.height - 30)
      ..quadraticBezierTo(size.width * .25, size.height, size.width * .5, size.height - 24)
      ..quadraticBezierTo(size.width * .75, size.height - 48, size.width, size.height - 12)
      ..lineTo(size.width, 0)
      ..close();
    return p;
  }
  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
class GlassCard extends StatelessWidget {
  final double width;
  final Widget child;
  const GlassCard({super.key, required this.width, required this.child});
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white24, width: 1),
            color: Colors.white.withOpacity(0.08),
            boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 18, offset: Offset(0,10))],
          ),
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}
class GlassButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  const GlassButton({super.key, required this.text, required this.onPressed});
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.18),
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            elevation: 0,
          ),
          onPressed: onPressed,
          child: Text(
            text,
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
class _StarryPainter extends CustomPainter {
  final double progress;
  _StarryPainter({required this.progress});
  final _rng = math.Random(42);
  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..shader = const LinearGradient(
      colors: [Color(0xFF0b1023), Color(0xFF0e1b3c), Color(0xFF142a5b)],
      begin: Alignment.topLeft, end: Alignment.bottomRight).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, bg);
    final starPaint = Paint()..color = Colors.white.withOpacity(0.9);
    for (int i = 0; i < 220; i++) {
      final x = (i * 123.45) % size.width;
      final y = (i * 89.32) % size.height;
      final twinkle = 0.6 + 0.4 * math.sin(progress * 2 * math.pi + i);
      canvas.drawCircle(Offset(x, y), twinkle * 0.9 + 0.3, starPaint);
    }
    final cometPaint = Paint()
      ..shader = const LinearGradient(colors: [Colors.white, Colors.transparent])
          .createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    for (int c = 0; c < 3; c++) {
      final t = (progress + c / 3) % 1.0;
      final start = Offset(size.width * (1 - t), size.height * (0.15 + 0.25 * c));
      final end = start + const Offset(-120, 40);
      cometPaint.strokeWidth = 2;
      cometPaint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawLine(start, end, cometPaint);
    }
    final swirl = Paint()
      ..color = const Color(0x22ffffff)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    for (double r = 18; r < 120; r += 12) {
      final path = Path();
      for (double a = 0; a < math.pi * 2; a += 0.2) {
        final rr = r + 4 * math.sin(a * 3 + progress * 6.28);
        final x = size.width * 0.78 + rr * math.cos(a);
        final y = size.height * 0.28 + rr * math.sin(a);
        if (a == 0) { path.moveTo(x, y); } else { path.lineTo(x, y); }
      }
      canvas.drawPath(path, swirl);
    }
  }
  @override
  bool shouldRepaint(covariant _StarryPainter oldDelegate) => oldDelegate.progress != progress;
}
