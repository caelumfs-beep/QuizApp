import 'package:flutter/material.dart';
import 'app_theme.dart';

class StarRating extends StatelessWidget {
  final int stars;
  final double size;
  const StarRating({super.key, required this.stars, this.size = 36});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) => Icon(
        i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
        color: i < stars ? AppTheme.accent : AppTheme.locked,
        size: size,
      )),
    );
  }
}
