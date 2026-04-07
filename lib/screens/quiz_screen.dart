import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'package:google_fonts/google_fonts.dart';

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
        backgroundColor: const Color(0xFF003266),
        body: Column(
          children: [
            // Top navy section
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Back + progress
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => _confirmExit(context),
                          child: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white70, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: (provider.currentQuestionIndex + 1) / provider.totalQuestions,
                              backgroundColor: Colors.white24,
                              color: const Color(0xFF38BDF8),
                              minHeight: 6,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${provider.currentQuestionIndex + 1}/${provider.totalQuestions}',
                          style: GoogleFonts.nunito(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      q.question,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                        fontSize: q.question.length > 200 ? 13 : q.question.length > 100 ? 16 : 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            // White bottom section with choices
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F7FA),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
                  child: Column(
                    children: [
                      ...List.generate(q.choices.length, (i) {
                        Color bgColor = Colors.white;
                        Color borderColor = Colors.transparent;
                        Color textColor = const Color(0xFF003266);
                        Widget? trailingIcon;

                        if (answered) {
                          if (i == q.correctIndex) {
                            bgColor = const Color(0xFF10B981);
                            textColor = Colors.white;
                            trailingIcon = const Icon(Icons.check_circle_rounded, color: Colors.white, size: 22);
                          } else if (i == selected && i != q.correctIndex) {
                            bgColor = const Color(0xFFEF4444);
                            textColor = Colors.white;
                            trailingIcon = const Icon(Icons.cancel_rounded, color: Colors.white, size: 22);
                          }
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: GestureDetector(
                            onTap: answered ? null : () => provider.selectAnswer(i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                              decoration: BoxDecoration(
                                color: bgColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: borderColor),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      q.choices[i],
                                      style: GoogleFonts.nunito(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: textColor,
                                      ),
                                    ),
                                  ),
                                  if (trailingIcon != null) trailingIcon,
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                      if (answered) ...[
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
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
                              backgroundColor: const Color(0xFF003266),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 0,
                            ),
                            child: Text(
                              provider.isLastQuestion ? 'Finish' : 'Next Question',
                              style: GoogleFonts.nunito(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
