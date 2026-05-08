import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerAvatar extends StatelessWidget {
  final double radio;

  const ShimmerAvatar({super.key, this.radio = 25});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDarkMode ? Colors.grey[850]! : Colors.grey[300]!,
      highlightColor: isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
      child: CircleAvatar(
        radius: radio,
        backgroundColor: Colors.white,
      ),
    );
  }
}