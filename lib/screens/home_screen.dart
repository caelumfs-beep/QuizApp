import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../data/questions_data.dart';
import '../data/set_a_data.dart';
import '../data/set_b_data.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                'CFS Quiz App',
                style: GoogleFonts.nunito(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF003266),
                ),
              ),
              Text(
                'Choose your reviewer',
                style: GoogleFonts.nunito(fontSize: 14, color: Colors.grey[500]),
              ),
              const SizedBox(height: 24),
              _TrackCard(
                title: 'TRAD',
                subtitle: 'Traditional Life Insurance',
                levels: totalLevels,
                questions: allQuestions.length,
                color: const Color(0xFF003266),
                progressValue: (context.watch<AppProvider>().getTrackUnlocked(QuizTrack.trad) - 1) / totalLevels,
                onTap: () {
                  context.read<AppProvider>().setTrack(QuizTrack.trad);
                  Navigator.pushNamed(context, '/track_home');
                },
              ),
              const SizedBox(height: 16),
              _TrackCard(
                title: 'VUL',
                subtitle: 'Variable Universal Life',
                levels: setATotalLevels + setBTotalLevels,
                questions: setAQuestions.length + setBQuestions.length,
                color: const Color(0xFF0F5132),
                progressValue: (() {
                  final p = context.watch<AppProvider>();
                  final a = p.getTrackUnlocked(QuizTrack.vulSetA) - 1;
                  final b = p.getTrackUnlocked(QuizTrack.vulSetB) - 1;
                  return (a + b) / (setATotalLevels + setBTotalLevels);
                })(),
                badge: 'Set A + Set B',
                onTap: () => Navigator.pushNamed(context, '/vul_sets'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrackCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final int levels;
  final int questions;
  final Color color;
  final double progressValue;
  final VoidCallback onTap;
  final String? badge;

  const _TrackCard({
    required this.title,
    required this.subtitle,
    required this.levels,
    required this.questions,
    required this.color,
    required this.progressValue,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.nunito(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 3,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.nunito(fontSize: 13, color: Colors.white60),
                    ),
                  ],
                ),
                Image.asset('assets/images/bbook.png', height: 75),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$levels levels · $questions questions',
                  style: GoogleFonts.nunito(fontSize: 12, color: Colors.white60),
                ),
                if (badge != null)
                  Text(badge!, style: GoogleFonts.nunito(fontSize: 12, color: Colors.white60)),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progressValue.clamp(0.0, 1.0),
                backgroundColor: Colors.white24,
                color: const Color(0xFF38BDF8),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 243, 240, 240),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                badge != null ? 'Select Set' : 'Enter',
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
