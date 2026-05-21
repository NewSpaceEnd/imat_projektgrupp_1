import 'package:flutter/material.dart';

class PrimaryActionButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;

  const PrimaryActionButton({
    required this.label,
    this.icon,
    this.onPressed,
    super.key,
  });

  @override
  State<PrimaryActionButton> createState() => _PrimaryActionButtonState();
}

class _PrimaryActionButtonState extends State<PrimaryActionButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  static const Color _baseTop = Color(0xFF6C3BD6);
  static const Color _baseBottom = Color(0xFF4B23B7);
  static const Color _hoverTop = Color(0xFF7B4AE0);
  static const Color _hoverBottom = Color(0xFF5A2BD2);
  static const Color _pressedTop = Color(0xFF4F25B2);
  static const Color _pressedBottom = Color(0xFF351A82);

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final topColor = !enabled
        ? const Color(0xFF8E84A8)
        : _isPressed
            ? _pressedTop
            : _isHovered
                ? _hoverTop
                : _baseTop;
    final bottomColor = !enabled
        ? const Color(0xFF6F6782)
        : _isPressed
            ? _pressedBottom
            : _isHovered
                ? _hoverBottom
                : _baseBottom;
    final shadowOpacity = !enabled ? 0.0 : _isPressed ? 0.18 : 0.28;

    return Semantics(
      button: true,
      enabled: enabled,
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onEnter: enabled ? (_) => setState(() => _isHovered = true) : null,
        onExit: enabled ? (_) => setState(() => _isHovered = false) : null,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: enabled ? (_) => setState(() => _isPressed = true) : null,
          onTapUp: enabled ? (_) => setState(() => _isPressed = false) : null,
          onTapCancel: enabled ? () => setState(() => _isPressed = false) : null,
          onTap: widget.onPressed,
          child: AnimatedScale(
            scale: _isPressed ? 0.985 : 1.0,
            duration: const Duration(milliseconds: 90),
            curve: Curves.easeOut,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              curve: Curves.easeOut,
              constraints: const BoxConstraints(minHeight: 48),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [topColor, bottomColor],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF8E6AF0).withOpacity(enabled ? 0.55 : 0.25),
                ),
                boxShadow: enabled
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(shadowOpacity),
                          blurRadius: _isPressed ? 6 : 14,
                          offset: Offset(0, _isPressed ? 2 : 6),
                        ),
                      ]
                    : const [],
              ),
              child: DefaultTextStyle(
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                child: IconTheme(
                  data: const IconThemeData(color: Colors.white, size: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon),
                        const SizedBox(width: 10),
                      ],
                      Text(widget.label),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}