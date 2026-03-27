import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/app_theme.dart';

class MistakesScreen extends StatelessWidget {
  const MistakesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final mistakes = provider.mistakes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Mistakes'),
        actions: [
          if (mistakes.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              tooltip: 'Clear all mistakes',
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Clear Mistakes?'),
                    content: const Text('This will remove all saved mistakes.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Clear')),
                    ],
                  ),
                );
                if (confirm == true) provider.clearMistakes();
              },
            ),
        ],
      ),
      body: mistakes.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_outline_rounded, size: 72, color: AppTheme.success),
                  SizedBox(height: 16),
                  Text('No mistakes yet!', style: TextStyle(fontSize: 18, color: AppTheme.textMuted)),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: mistakes.length,
                    itemBuilder: (context, i) {
                      final m = mistakes[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6, offset: const Offset(0, 3))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text('Q${m.question.id}',
                                      style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(m.question.question,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppTheme.textDark)),
                            const SizedBox(height: 12),
                            _AnswerRow(
                              label: 'Your answer',
                              answer: m.selectedAnswer,
                              color: AppTheme.error,
                              icon: Icons.cancel_rounded,
                            ),
                            const SizedBox(height: 6),
                            _AnswerRow(
                              label: 'Correct answer',
                              answer: m.correctAnswer,
                              color: AppTheme.success,
                              icon: Icons.check_circle_rounded,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.replay_rounded),
                    label: Text('Retry Wrong Questions (${mistakes.length})'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.error,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {
                      provider.startRetryMistakes();
                      Navigator.pushNamed(context, '/quiz');
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class _AnswerRow extends StatelessWidget {
  final String label;
  final String answer;
  final Color color;
  final IconData icon;

  const _AnswerRow({required this.label, required this.answer, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 14, color: AppTheme.textDark),
              children: [
                TextSpan(text: '$label: ', style: TextStyle(color: color, fontWeight: FontWeight.w600)),
                TextSpan(text: answer),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
