import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../data/questions_data.dart';
import 'package:google_fonts/google_fonts.dart';

class LevelSelectScreen extends StatelessWidget {
  const LevelSelectScreen({super.key});

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
          'Select Level',
          style: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF003266),
          ),
        ),
        centerTitle: true,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 0.85,
        ),
        itemCount: totalLevels,
        itemBuilder: (context, i) {
          final level = i + 1;
          final unlocked = level <= provider.unlockedLevels;
          final score = provider.levelScores[level];
          final stars = score != null ? provider.starsForScore(score, getQuestionsForLevel(level).length) : 0;
          return _LevelCard(
            level: level,
            unlocked: unlocked,
            stars: stars,
            completed: score != null,
            onTap: unlocked
                ? () {
                    provider.startLevel(level);
                    Navigator.pushNamed(context, '/quiz');
                  }
                : null,
          );
        },
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final int level;
  final bool unlocked;
  final int stars;
  final bool completed;
  final VoidCallback? onTap;

  const _LevelCard({
    required this.level,
    required this.unlocked,
    required this.stars,
    required this.completed,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: unlocked ? const Color(0xFF003266).withOpacity(0.2) : const Color(0xFFE0E0E0),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!unlocked)
              Image.asset('assets/images/lock.png', height: 36)
            else
              Text(
                '$level',
                style: GoogleFonts.nunito(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF003266),
                ),
              ),
            const SizedBox(height: 8),
            Text(
              'Level $level',
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: unlocked ? const Color(0xFF003266) : Colors.grey,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: Image.asset(
                    (completed && i < stars)
                        ? 'assets/images/gold star.png'
                        : 'assets/images/blank star.png',
                    height: 14,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
