import 'package:flutter/material.dart';
import 'package:imat_app/widgets/top_nav_bar.dart';

const double authShellTitleTextSize = 30.0;
const double authShellSubtitleTextSize = 14.0;

class AuthShell extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final double maxWidth;

  const AuthShell({
    required this.title,
    required this.subtitle,
    required this.child,
    this.maxWidth = 420,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopNavBar(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF7F9FF), Color(0xFFE9EEF9)],
          ),
        ),
        child: Stack(
          children: [
            const Positioned(
              top: -60,
              right: -30,
              child: _GlowCircle(size: 180, color: Color(0xFFDBE8FF)),
            ),
            const Positioned(
              bottom: -80,
              left: -50,
              child: _GlowCircle(size: 220, color: Color(0xFFD9F0FF)),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFE7ECF5)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 30,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: authShellTitleTextSize, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          subtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: authShellSubtitleTextSize,
                            color: Colors.grey.shade700,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 24),
                        child,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.32),
      ),
    );
  }
}