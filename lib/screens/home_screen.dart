import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primary, Color(0xFF1D4ED8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Icon(Icons.school_rounded, size: 72, color: Colors.white),
              const SizedBox(height: 12),
              const Text('Trad Reviewer', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 4),
              Text(
                'Level ${provider.unlockedLevels > 13 ? 13 : provider.unlockedLevels} unlocked',
                style: const TextStyle(color: Colors.white70, fontSize: 15),
              ),
              const SizedBox(height: 48),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
                  decoration: const BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _HomeButton(
                        icon: Icons.play_circle_fill_rounded,
                        label: 'Start Review',
                        color: AppTheme.primary,
                        onTap: () => Navigator.pushNamed(context, '/levels'),
                      ),
                      const SizedBox(height: 16),
                      _HomeButton(
                        icon: Icons.replay_rounded,
                        label: 'Review Mistakes',
                        color: AppTheme.error,
                        onTap: () {
                          if (provider.mistakes.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('No mistakes recorded yet!')),
                            );
                          } else {
                            Navigator.pushNamed(context, '/mistakes');
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      _HomeButton(
                        icon: Icons.bar_chart_rounded,
                        label: 'Progress',
                        color: AppTheme.success,
                        onTap: () => Navigator.pushNamed(context, '/progress'),
                      ),
                      const SizedBox(height: 16),
                      _HomeButton(
                        icon: Icons.menu_book_rounded,
                        label: 'Review All Questions',
                        color: AppTheme.accent,
                        onTap: () {
                          provider.startReviewMode();
                          Navigator.pushNamed(context, '/quiz');
                        },
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

class _HomeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _HomeButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 28),
              const SizedBox(width: 16),
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white54, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
