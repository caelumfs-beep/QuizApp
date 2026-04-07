import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final score = provider.score;
    final total = provider.totalQuestions;
    final passed = score >= provider.passingScoreForTrack;
    final stars = provider.starsForScore(score, total);
    final hasMistakes = provider.sessionMistakes.isNotEmpty;
    final totalLvls = provider.totalLevelsForTrack;

    return Scaffold(
      backgroundColor: const Color(0xFF003266),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 36),
            // Icon
            passed
                ? Image.asset('assets/images/result_trophy.png', height: 90)
                : Image.asset('assets/images/sad.png', height: 90),
            const SizedBox(height: 16),
            Text(
              passed ? 'Level Passed!' : 'Not Quite!',
              style: GoogleFonts.nunito(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white),
            ),
            const SizedBox(height: 6),
            Text(
              'Level ${provider.currentLevel}',
              style: GoogleFonts.nunito(color: Colors.white60, fontSize: 15),
            ),
            const SizedBox(height: 20),
            // Stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Image.asset(
                  i < stars ? 'assets/images/gold star.png' : 'assets/images/blank star.png',
                  height: 40,
                ),
              )),
            ),
            const SizedBox(height: 20),
            Text(
              '$score / $total',
              style: GoogleFonts.nunito(fontSize: 52, fontWeight: FontWeight.w900, color: Colors.white),
            ),
            Text(
              passed ? 'Great job! Keep going!' : 'You need ${provider.passingScoreForTrack}/$total to pass.',
              style: GoogleFonts.nunito(color: Colors.white60, fontSize: 14),
            ),
            const SizedBox(height: 32),
            // Buttons
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                color: const Color(0xFFF5F7FA),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (passed && provider.currentLevel < totalLvls) ...[
                      _ResultButton(
                        label: 'Next Level',
                        onTap: () {
                          provider.startLevel(provider.currentLevel + 1);
                          Navigator.pushReplacementNamed(context, '/quiz');
                        },
                      ),
                      const SizedBox(height: 12),
                    ],
                    _ResultButton(
                      label: 'Retry Level',
                      onTap: () {
                        provider.startLevel(provider.currentLevel);
                        Navigator.pushReplacementNamed(context, '/quiz');
                      },
                    ),
                    if (hasMistakes) ...[
                      const SizedBox(height: 12),
                      _ResultButton(
                        label: 'Review Mistakes (${provider.sessionMistakes.length})',
                        onTap: () => Navigator.pushNamed(context, '/mistakes'),
                      ),
                    ],
                    const SizedBox(height: 12),
                    _ResultButton(
                      label: 'Home',
                      onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false),
                    ),
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

class _ResultButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ResultButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF003266),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: const Color(0xFF003266).withOpacity(0.15)),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF003266),
          ),
        ),
      ),
    );
  }
}
