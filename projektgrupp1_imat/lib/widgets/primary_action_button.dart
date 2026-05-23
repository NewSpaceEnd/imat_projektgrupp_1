import 'package:flutter/material.dart';

/// En anpassad lila knapp med gradient och animerad tryckeffekt.
/// Används för alla primära CTAs ("Till kassan", "Lägg till i varukorgen", etc.)
/// 
/// Features:
/// - Gradient-bakgrund (lila) med hover- och pressed-tillstånd
/// - AnimatedScale och AnimatedContainer för smooth press-animation
/// - Skugga som ändras baserat på tryck
/// - Support för ikon + etikett
/// - Disabled-stånd med grå utseende när onPressed är null
class PrimaryActionButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color textColor;
  final Color iconColor;
  final Color baseTopColor;
  final Color baseBottomColor;
  final Color hoverTopColor;
  final Color hoverBottomColor;
  final Color pressedTopColor;
  final Color pressedBottomColor;
  final Color borderColor;
  final double? textSize;

  const PrimaryActionButton({
    required this.label,
    this.icon,
    this.onPressed,
    this.textColor = Colors.white,
    this.iconColor = Colors.white,
    this.baseTopColor = const Color(0xFF6C3BD6),
    this.baseBottomColor = const Color(0xFF4B23B7),
    this.hoverTopColor = const Color(0xFF7B4AE0),
    this.hoverBottomColor = const Color(0xFF5A2BD2),
    this.pressedTopColor = const Color(0xFF4F25B2),
    this.pressedBottomColor = const Color(0xFF351A82),
    this.borderColor = const Color(0xFF8E6AF0),
    this.textSize,
    super.key,
  });

  @override
  State<PrimaryActionButton> createState() => _PrimaryActionButtonState();
}

class _PrimaryActionButtonState extends State<PrimaryActionButton> {
  static const double buttonTextSize = 20.0;
  static const double buttonIconSize = 25.0;

  bool _isHovered = false; // True när musen är över knappen
  bool _isPressed = false; // True när knappen trycks in

  @override
  Widget build(BuildContext context) {
    // Knappen är disabled om onPressed är null
    final enabled = widget.onPressed != null;
    
    // Välj gradient-färger baserat på enabled/hover/pressed
    final topColor = !enabled
        ? const Color(0xFF8E84A8)
        : _isPressed
        ? widget.pressedTopColor
            : _isHovered
          ? widget.hoverTopColor
          : widget.baseTopColor;
    final bottomColor = !enabled
        ? const Color(0xFF6F6782)
        : _isPressed
        ? widget.pressedBottomColor
            : _isHovered
          ? widget.hoverBottomColor
          : widget.baseBottomColor;
    
    // Justera skugga-opacity baserat på tillstånd
    final shadowOpacity = !enabled ? 0.0 : _isPressed ? 0.18 : 0.28;

    // Semantics för accessibility
    return Semantics(
      button: true,
      enabled: enabled,
      child: MouseRegion(
        // Visa pekarkursor när musen är över enabled-knapp
        cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onEnter: enabled ? (_) => setState(() => _isHovered = true) : null,
        onExit: enabled ? (_) => setState(() => _isHovered = false) : null,
        // GestureDetector för att fanga tap-events
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: enabled ? (_) => setState(() => _isPressed = true) : null,
          onTapUp: enabled ? (_) => setState(() => _isPressed = false) : null,
          onTapCancel: enabled ? () => setState(() => _isPressed = false) : null,
          onTap: widget.onPressed,
          // AnimatedScale: minska knappen lite när den trycks in
          child: AnimatedScale(
            scale: _isPressed ? 0.985 : 1.0,
            duration: const Duration(milliseconds: 90),
            curve: Curves.easeOut,
            // AnimatedContainer: smooth gradient, shadow, och border-animationer
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              curve: Curves.easeOut,
              constraints: const BoxConstraints(minHeight: 48),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                // Gradient från top to bottom med lila/blå färger
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [topColor, bottomColor],
                ),
                borderRadius: BorderRadius.circular(12),
                // Subtil lila border
                border: Border.all(
                  color: widget.borderColor.withOpacity(enabled ? 0.55 : 0.25),
                ),
                // Skugga som ändras baserat på tillstånd
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
              // Text-stil: vit, medel storlek, semi-bold
              child: DefaultTextStyle(
                style: TextStyle(
                  color: widget.textColor,
                  fontSize: widget.textSize ?? buttonTextSize,
                  fontWeight: FontWeight.w600,
                ),
                // Ikon-stil: vit, 20px
                child: IconTheme(
                  data: IconThemeData(color: widget.iconColor, size: buttonIconSize),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Visa ikon om en finns, med space till texten
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