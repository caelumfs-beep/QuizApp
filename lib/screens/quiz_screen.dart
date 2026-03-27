import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/app_theme.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  Future<void> _confirmExit(BuildContext context) async {
    final exit = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Exit Quiz?'),
        content: const Text('Your progress in this session will be lost.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Exit')),
        ],
      ),
    );
    if ((exit ?? false) && context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final q = provider.currentQuestion;
    final answered = provider.answered;
    final selected = provider.selectedAnswerIndex;
    final isReview = provider.isReviewMode || provider.isRetryMistakes;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmExit(context);
      },
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          title: Text(isReview
              ? (provider.isRetryMistakes ? 'Retry Mistakes' : 'Review Mode')
              : 'Level ${provider.currentLevel}'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '${provider.currentQuestionIndex + 1}/${provider.totalQuestions}',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            LinearProgressIndicator(
              value: (provider.currentQuestionIndex + 1) / provider.totalQuestions,
              backgroundColor: Colors.white,
              color: AppTheme.accent,
              minHeight: 5,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!isReview)
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: AppTheme.accent, size: 20),
                          const SizedBox(width: 4),
                          Text('Score: ${provider.score}',
                              style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textDark)),
                        ],
                      ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 4))],
                      ),
                      child: Text(
                        q.question,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textDark, height: 1.5),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ...List.generate(q.choices.length, (i) {
                      Color bgColor = AppTheme.surface;
                      Color borderColor = const Color(0xFFE2E8F0);
                      Color textColor = AppTheme.textDark;
                      IconData? trailingIcon;

                      if (answered) {
                        if (i == q.correctIndex) {
                          bgColor = AppTheme.success.withValues(alpha: 0.12);
                          borderColor = AppTheme.success;
                          textColor = AppTheme.success;
                          trailingIcon = Icons.check_circle_rounded;
                        } else if (i == selected && i != q.correctIndex) {
                          bgColor = AppTheme.error.withValues(alpha: 0.10);
                          borderColor = AppTheme.error;
                          textColor = AppTheme.error;
                          trailingIcon = Icons.cancel_rounded;
                        }
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: answered ? null : () => provider.selectAnswer(i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: borderColor, width: 2),
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4)],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: borderColor.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      String.fromCharCode(65 + i),
                                      style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(q.choices[i],
                                      style: TextStyle(fontSize: 15, color: textColor, fontWeight: FontWeight.w500)),
                                ),
                                if (trailingIcon != null)
                                  Icon(trailingIcon, color: textColor, size: 22),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    if (answered) ...[
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () async {
                          if (provider.isLastQuestion) {
                            await provider.finishLevel();
                            if (context.mounted) {
                              if (isReview) {
                                Navigator.pop(context);
                              } else {
                                Navigator.pushReplacementNamed(context, '/result');
                              }
                            }
                          } else {
                            provider.nextQuestion();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text(
                          provider.isLastQuestion ? 'Finish' : 'Next Question',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
