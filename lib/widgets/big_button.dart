import 'package:material_ui/material_ui.dart';

import '../theme.dart';

/// A large gradient action card with an icon badge, subtitle and a gentle
/// press animation. Sized for older users: big tap target, big text.
class BigButton extends StatefulWidget {
  const BigButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.subtitle,
    this.gradient = Brand.calm,
    this.foreground = Colors.white,
  });

  final String label;
  final String? subtitle;
  final IconData icon;
  final VoidCallback? onPressed;
  final Gradient gradient;
  final Color foreground;

  @override
  State<BigButton> createState() => _BigButtonState();
}

class _BigButtonState extends State<BigButton> {
  bool _pressed = false;

  void _setPressed(bool v) {
    if (_pressed != v) setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final fg = widget.foreground;
    final shadowColor = widget.gradient.colors.last;
    return Semantics(
      button: true,
      label: widget.subtitle == null
          ? widget.label
          : '${widget.label}. ${widget.subtitle}',
      excludeSemantics: true,
      child: GestureDetector(
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1,
          duration: const Duration(milliseconds: 120),
          child: Container(
            constraints: const BoxConstraints(minHeight: 96),
            decoration: BoxDecoration(
              gradient: widget.gradient,
              borderRadius: BorderRadius.circular(26),
              boxShadow: softShadow(shadowColor),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: fg.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(widget.icon, size: 34, color: fg),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.label,
                        style: TextStyle(
                          color: fg,
                          fontSize: 21,
                          height: 1.2,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (widget.subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.subtitle!,
                          style: TextStyle(
                            color: fg.withValues(alpha: 0.92),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: fg, size: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
