import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../data/questions_data.dart';
import '../widgets/app_theme.dart';
import '../widgets/star_rating.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final score = provider.score;
    final total = provider.totalQuestions;
    final passed = score >= passingScore;
    final stars = provider.starsForScore(score, total);
    final hasMistakes = provider.sessionMistakes.isNotEmpty;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: passed
                ? [AppTheme.success, const Color(0xFF059669)]
                : [AppTheme.error, const Color(0xFFDC2626)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 32),
              Icon(
                passed ? Icons.emoji_events_rounded : Icons.sentiment_dissatisfied_rounded,
                size: 80,
                color: Colors.white,
              ),
              const SizedBox(height: 12),
              Text(
                passed ? 'Level Passed!' : 'Not Quite!',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                'Level ${provider.currentLevel}',
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 24),
              StarRating(stars: stars, size: 48),
              const SizedBox(height: 16),
              Text(
                '$score / $total',
                style: const TextStyle(fontSize: 52, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Text(
                passed ? 'Great job! Keep going!' : 'You need $passingScore/$total to pass.',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 15),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                  decoration: const BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (passed && provider.currentLevel < totalLevels)
                        _ResultButton(
                          icon: Icons.arrow_forward_rounded,
                          label: 'Next Level',
                          color: AppTheme.success,
                          onTap: () {
                            provider.startLevel(provider.currentLevel + 1);
                            Navigator.pushReplacementNamed(context, '/quiz');
                          },
                        ),
                      if (passed && provider.currentLevel < totalLevels) const SizedBox(height: 12),
                      _ResultButton(
                        icon: Icons.replay_rounded,
                        label: 'Retry Level',
                        color: AppTheme.primary,
                        onTap: () {
                          provider.startLevel(provider.currentLevel);
                          Navigator.pushReplacementNamed(context, '/quiz');
                        },
                      ),
                      if (hasMistakes) ...[
                        const SizedBox(height: 12),
                        _ResultButton(
                          icon: Icons.find_in_page_rounded,
                          label: 'Review Mistakes (${provider.sessionMistakes.length})',
                          color: AppTheme.error,
                          onTap: () => Navigator.pushNamed(context, '/mistakes'),
                        ),
                      ],
                      const SizedBox(height: 12),
                      _ResultButton(
                        icon: Icons.home_rounded,
                        label: 'Home',
                        color: AppTheme.textMuted,
                        onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ResultButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
