import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class MistakesScreen extends StatelessWidget {
  const MistakesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final mistakes = provider.mistakes;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_rounded, color: Color(0xFF003266)),
        ),
        title: Text('Review Mistakes', style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w900, color: const Color(0xFF003266))),
        centerTitle: true,
        actions: [
          if (mistakes.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFF003266)),
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
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle_outline_rounded, size: 72, color: Color(0xFF003266)),
                  const SizedBox(height: 16),
                  Text('No mistakes yet!', style: GoogleFonts.nunito(fontSize: 18, color: Colors.grey)),
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
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 3))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF003266).withOpacity(0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text('Q${m.question.id}',
                                  style: GoogleFonts.nunito(color: const Color(0xFF003266), fontWeight: FontWeight.w800, fontSize: 12)),
                            ),
                            const SizedBox(height: 8),
                            Text(m.question.question,
                                style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 15, color: const Color(0xFF1E293B))),
                            const SizedBox(height: 12),
                            _AnswerRow(label: 'Your answer', answer: m.selectedAnswer, color: const Color(0xFFEF4444), icon: Icons.cancel_rounded),
                            const SizedBox(height: 6),
                            _AnswerRow(label: 'Correct answer', answer: m.correctAnswer, color: const Color(0xFF10B981), icon: Icons.check_circle_rounded),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        provider.startRetryMistakes();
                        Navigator.pushNamed(context, '/quiz');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF003266),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: Text('Retry Wrong Questions (${mistakes.length})',
                          style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
                    ),
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
              style: GoogleFonts.nunito(fontSize: 14, color: const Color(0xFF1E293B)),
              children: [
                TextSpan(text: '$label: ', style: TextStyle(color: color, fontWeight: FontWeight.w700)),
                TextSpan(text: answer),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
