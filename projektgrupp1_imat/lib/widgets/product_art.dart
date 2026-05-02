import 'package:flutter/material.dart';
import 'package:projektgrupp1_imat/util/home_models.dart';

class ProductArt extends StatelessWidget {
  const ProductArt({super.key, required this.type});

  final ProductArtType type;

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case ProductArtType.apple:
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFFD74444), Color(0xFFB91414)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            const Positioned(
              top: 16,
              child: Icon(Icons.eco, color: Color(0xFF2E7D32), size: 26),
            ),
          ],
        );
      case ProductArtType.banana:
        return Stack(
          alignment: Alignment.center,
          children: [
            Transform.rotate(
              angle: -0.2,
              child: Container(
                width: 95,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFF6D44A),
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
            ),
            Transform.rotate(
              angle: 0.35,
              child: Container(
                width: 95,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFE4BE2D),
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
            ),
          ],
        );
      case ProductArtType.potato:
        return Stack(
          alignment: Alignment.center,
          children: const [
            Positioned(
              left: 28,
              top: 46,
              child: _Oval(color: Color(0xFFCEAB76), width: 54, height: 42),
            ),
            Positioned(
              right: 34,
              top: 50,
              child: _Oval(color: Color(0xFFD8B988), width: 56, height: 44),
            ),
            Positioned(
              left: 58,
              top: 26,
              child: _Oval(color: Color(0xFFD4B480), width: 62, height: 48),
            ),
          ],
        );
      case ProductArtType.chili:
        return Stack(
          alignment: Alignment.center,
          children: [
            Transform.rotate(
              angle: -0.35,
              child: Container(
                width: 102,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFFB72020),
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            const Positioned(
              top: 40,
              right: 50,
              child: Icon(Icons.eco, color: Color(0xFF2E7D32), size: 20),
            ),
          ],
        );
    }
  }
}

class _Oval extends StatelessWidget {
  const _Oval({required this.color, required this.width, required this.height});

  final Color color;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(height / 2),
      ),
    );
  }
}
