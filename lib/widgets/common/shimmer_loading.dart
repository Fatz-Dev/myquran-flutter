import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoading extends StatelessWidget {
  final Widget child;

  const ShimmerLoading({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade300,
      highlightColor: isDark ? const Color(0xFF3A3A3A) : Colors.grey.shade100,
      child: child,
    );
  }
}

class ShimmerSurahCard extends StatelessWidget {
  const ShimmerSurahCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 16, width: 120, color: Colors.white, margin: const EdgeInsets.only(bottom: 8)),
                  Container(height: 12, width: 80, color: Colors.white),
                ],
              ),
            ),
            Container(height: 32, width: 60, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class ShimmerDoaCard extends StatelessWidget {
  const ShimmerDoaCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 16, width: 150, color: Colors.white, margin: const EdgeInsets.only(bottom: 8)),
            Container(height: 24, color: Colors.white, margin: const EdgeInsets.only(bottom: 8)),
            Container(height: 12, width: double.infinity, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
