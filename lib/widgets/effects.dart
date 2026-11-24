import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../theme.dart';

/// Fades and slides a child up into place, optionally after a delay, so
/// screens build in gracefully. Instant when the user reduces motion.
class Entrance extends StatelessWidget {
  const Entrance({super.key, required this.child, this.delayMs = 0});

  final Widget child;
  final int delayMs;

  @override
  Widget build(BuildContext context) {
    if (reduceMotion(context)) return child;
    const runMs = 420;
    final total = delayMs + runMs;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: total),
      builder: (context, t, child) {
        final local = ((t * total - delayMs) / runMs).clamp(0.0, 1.0);
        final eased = Curves.easeOutCubic.transform(local);
        return Opacity(
          opacity: eased,
          child: Transform.translate(
            offset: Offset(0, 24 * (1 - eased)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// A circular progress ring that animates to [value] (0..1) with a label
/// in the middle.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.value,
    required this.center,
    this.size = 92,
    this.color = Brand.mint,
    this.track = const Color(0x33FFFFFF),
  });

  final double value;
  final Widget center;
  final double size;
  final Color color;
  final Color track;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: reduceMotion(context)
          ? Duration.zero
          : const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _RingPainter(v, color, track),
          child: Center(child: center),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.value, this.color, this.track);

  final double value;
  final Color color;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 9.0;
    final rect = Offset.zero & size;
    final arcRect = rect.deflate(stroke / 2);
    canvas.drawArc(
      arcRect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..color = track
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );
    canvas.drawArc(
      arcRect,
      -math.pi / 2,
      math.pi * 2 * value,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value || old.color != color;
}

/// A slow "breathe in, breathe out" guide: a glowing circle that grows and
/// shrinks for a few calm breaths, then rests. Static when motion is reduced.
class BreathingGuide extends StatefulWidget {
  const BreathingGuide({super.key, this.breaths = 3});

  final int breaths;

  @override
  State<BreathingGuide> createState() => _BreathingGuideState();
}

class _BreathingGuideState extends State<BreathingGuide>
    with SingleTickerProviderStateMixin {
  static const _breath = Duration(seconds: 8);
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: _breath * widget.breaths,
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started && !reduceMotion(context)) {
      _started = true;
      _c.forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final done = !_c.isAnimating;
        final phase = (_c.value * widget.breaths) % 1.0;
        // 0..0.5 breathing in (grow), 0.5..1 breathing out (shrink).
        final grow = done
            ? 1.0
            : Curves.easeInOut.transform(
                phase < 0.5 ? phase * 2 : 2 - phase * 2,
              );
        final label = done
            ? 'You are calm\nand in control'
            : phase < 0.5
            ? 'Breathe in'
            : 'Breathe out';
        final d = 150 + 60 * grow;
        return SizedBox(
          height: 230,
          child: Center(
            child: Container(
              width: d,
              height: d,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [Brand.mint, Brand.teal],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Brand.mint.withValues(alpha: 0.25 + 0.25 * grow),
                    blurRadius: 30 + 30 * grow,
                    spreadRadius: 4 + 10 * grow,
                  ),
                ],
              ),
              alignment: Alignment.center,
              padding: const EdgeInsets.all(22),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// A rounded white panel with a soft shadow.
class Panel extends StatelessWidget {
  const Panel({super.key, required this.child, this.padding = 20, this.color});

  final Widget child;
  final double padding;
  final Color? color;

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(padding),
    decoration: BoxDecoration(
      color: color ?? Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: softShadow(const Color(0xFF8FA3BF)),
    ),
    child: child,
  );
}
