import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../data/questions_data.dart';
import '../widgets/app_theme.dart';
import '../widgets/star_rating.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final completedLevels = provider.levelScores.length;
    final accuracy = provider.totalAccuracy;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reset all progress',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Reset Progress?'),
                  content: const Text('All progress, scores, and mistakes will be deleted.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                    TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Reset', style: TextStyle(color: AppTheme.error))),
                  ],
                ),
              );
              if (confirm == true) provider.resetAllProgress();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            decoration: const BoxDecoration(
              color: AppTheme.primary,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatCard(label: 'Completed', value: '$completedLevels / $totalLevels'),
                _StatCard(label: 'Unlocked', value: '${provider.unlockedLevels > totalLevels ? totalLevels : provider.unlockedLevels} / $totalLevels'),
                _StatCard(label: 'Accuracy', value: '${(accuracy * 100).toStringAsFixed(0)}%'),
              ],
            ),
          ),
          // Accuracy bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Overall Accuracy', style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textDark)),
                    Text('${(accuracy * 100).toStringAsFixed(1)}%', style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: accuracy,
                    backgroundColor: AppTheme.locked,
                    color: AppTheme.success,
                    minHeight: 10,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Level list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: totalLevels,
              itemBuilder: (context, i) {
                final level = i + 1;
                final unlocked = level <= provider.unlockedLevels;
                final score = provider.levelScores[level];
                final total = getQuestionsForLevel(level).length;
                final stars = score != null ? provider.starsForScore(score, total) : 0;

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: score != null ? AppTheme.primary.withValues(alpha: 0.3) : AppTheme.locked,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: score != null
                              ? AppTheme.primary
                              : (unlocked ? AppTheme.primaryLight.withValues(alpha: 0.15) : AppTheme.locked),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            score != null ? Icons.check_rounded : (unlocked ? Icons.play_arrow_rounded : Icons.lock_rounded),
                            color: score != null ? Colors.white : (unlocked ? AppTheme.primary : Colors.white),
                            size: 22,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Level $level',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textDark)),
                            Text(
                              score != null ? 'Best: $score/$total' : (unlocked ? 'Not attempted' : 'Locked'),
                              style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      if (score != null) StarRating(stars: stars, size: 20),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
      ],
    );
  }
}
