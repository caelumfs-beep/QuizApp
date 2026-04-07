import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../data/set_a_data.dart';
import '../data/set_b_data.dart';
import 'package:google_fonts/google_fonts.dart';

class VulSetSelectScreen extends StatelessWidget {
  const VulSetSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_rounded, color: Color(0xFF003266)),
        ),
        title: Text(
          'VUL Reviewer',
          style: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF003266),
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select a Set',
              style: GoogleFonts.nunito(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF003266),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Each set has its own progress and scores',
              style: GoogleFonts.nunito(fontSize: 13, color: Colors.grey[500]),
            ),
            const SizedBox(height: 24),
            _SetCard(
              setName: 'Set A',
              description: '',
              levels: setATotalLevels,
              questions: setAQuestions.length,
              unlockedLevels: provider.getTrackUnlocked(QuizTrack.vulSetA),
              color: const Color(0xFF1A3A5C),
              onTap: () {
                provider.setTrack(QuizTrack.vulSetA);
                Navigator.pushNamed(context, '/track_home');
              },
            ),
            const SizedBox(height: 16),
            _SetCard(
              setName: 'Set B',
              description: '',
              levels: setBTotalLevels,
              questions: setBQuestions.length,
              unlockedLevels: provider.getTrackUnlocked(QuizTrack.vulSetB),
              color: const Color(0xFF1A3A5C),
              onTap: () {
                provider.setTrack(QuizTrack.vulSetB);
                Navigator.pushNamed(context, '/track_home');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SetCard extends StatelessWidget {
  final String setName;
  final String description;
  final int levels;
  final int questions;
  final int unlockedLevels;
  final Color color;
  final VoidCallback onTap;

  const _SetCard({
    required this.setName,
    required this.description,
    required this.levels,
    required this.questions,
    required this.unlockedLevels,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (unlockedLevels - 1) / levels;

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
                      setName,
                      style: GoogleFonts.nunito(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    Text(
                      description,
                      style: GoogleFonts.nunito(fontSize: 13, color: Colors.white60),
                    ),
                  ],
                ),
                Image.asset('assets/images/bbook.png', height: 65),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '$levels levels · $questions questions',
              style: GoogleFonts.nunito(fontSize: 12, color: Colors.white60),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: Colors.white24,
                color: const Color(0xFF38BDF8),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Level ${unlockedLevels > levels ? levels : unlockedLevels} unlocked',
              style: GoogleFonts.nunito(fontSize: 12, color: Colors.white60),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Enter',
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
