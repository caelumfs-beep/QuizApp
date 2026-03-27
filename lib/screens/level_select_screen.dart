import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../data/questions_data.dart';
import '../widgets/app_theme.dart';
import '../widgets/star_rating.dart';

class LevelSelectScreen extends StatelessWidget {
  const LevelSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Select Level')),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 0.85,
        ),
        itemCount: totalLevels,
        itemBuilder: (context, i) {
          final level = i + 1;
          final unlocked = level <= provider.unlockedLevels;
          final score = provider.levelScores[level];
          final stars = score != null ? provider.starsForScore(score, getQuestionsForLevel(level).length) : 0;
          return _LevelCard(
            level: level,
            unlocked: unlocked,
            score: score,
            stars: stars,
            onTap: unlocked
                ? () {
                    provider.startLevel(level);
                    Navigator.pushNamed(context, '/quiz');
                  }
                : null,
          );
        },
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final int level;
  final bool unlocked;
  final int? score;
  final int stars;
  final VoidCallback? onTap;

  const _LevelCard({required this.level, required this.unlocked, this.score, required this.stars, this.onTap});

  @override
  Widget build(BuildContext context) {
    final completed = score != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: unlocked ? (completed ? AppTheme.primary : AppTheme.surface) : AppTheme.locked,
          borderRadius: BorderRadius.circular(16),
          boxShadow: unlocked
              ? [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 4))]
              : [],
          border: Border.all(
            color: unlocked ? (completed ? AppTheme.primary : AppTheme.primaryLight) : AppTheme.locked,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              unlocked ? (completed ? Icons.check_circle_rounded : Icons.play_circle_outline_rounded) : Icons.lock_rounded,
              color: unlocked ? (completed ? Colors.white : AppTheme.primary) : Colors.white,
              size: 32,
            ),
            const SizedBox(height: 6),
            Text(
              'Level $level',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: unlocked ? (completed ? Colors.white : AppTheme.textDark) : Colors.white,
              ),
            ),
            if (completed) ...[
              const SizedBox(height: 4),
              Text('$score/${getQuestionsForLevel(level).length}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 4),
              StarRating(stars: stars, size: 14),
            ] else if (unlocked)
              const Text('Tap to play', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
