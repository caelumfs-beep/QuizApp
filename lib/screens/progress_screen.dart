import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final totalLvls = provider.totalLevelsForTrack;
    final completedLevels = provider.levelScores.length;
    final accuracy = provider.totalAccuracy;

    return Scaffold(
      backgroundColor: const Color(0xFF003266),
      appBar: AppBar(
        backgroundColor: const Color(0xFF003266),
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
        ),
        title: Text('Progress', style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Reset Progress?'),
                  content: const Text('This will reset ALL tracks (TRAD, VUL Set A, VUL Set B). All progress, scores, and mistakes will be deleted.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Reset', style: TextStyle(color: Colors.red))),
                  ],
                ),
              );
              if (confirm == true) provider.resetAllProgress();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            color: const Color(0xFF003266),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatCard(label: 'Completed', value: '$completedLevels / $totalLvls'),
                _StatCard(label: 'Unlocked', value: '${provider.unlockedLevels > totalLvls ? totalLvls : provider.unlockedLevels} / $totalLvls'),
                _StatCard(label: 'Accuracy', value: '${(accuracy * 100).toStringAsFixed(0)}%'),
              ],
            ),
          ),
          // White bottom section
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF5F7FA),
              ),
              child: Column(
                children: [
                  // Accuracy bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Overall Accuracy', style: GoogleFonts.nunito(fontWeight: FontWeight.w700, color: const Color(0xFF003266))),
                            Text('${(accuracy * 100).toStringAsFixed(1)}%', style: GoogleFonts.nunito(color: const Color(0xFF003266), fontWeight: FontWeight.w800)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: accuracy,
                            backgroundColor: const Color(0xFFDDE3ED),
                            color: const Color(0xFF003266),
                            minHeight: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: totalLvls,
                      itemBuilder: (context, i) {
                        final level = i + 1;
                        final unlocked = level <= provider.unlockedLevels;
                        final score = provider.levelScores[level];
                        final total = provider.getQuestionsForLevelInTrack(level).length;
                        final stars = score != null ? provider.starsForScore(score, total) : 0;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2)),
                            ],
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                unlocked ? 'assets/images/key_icon.png' : 'assets/images/level_lock.png',
                                height: 36,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Level $level', style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 15, color: const Color(0xFF003266))),
                                    Text(
                                      score != null ? 'Best: $score/$total' : (unlocked ? 'Not attempted' : 'Locked'),
                                      style: GoogleFonts.nunito(color: Colors.grey, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                              if (score != null)
                                Row(
                                  children: List.generate(3, (i) => Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 1),
                                    child: Image.asset(
                                      i < stars ? 'assets/images/gold star.png' : 'assets/images/blank star.png',
                                      height: 16,
                                    ),
                                  )),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.nunito(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.nunito(color: Colors.white60, fontSize: 13)),
      ],
    );
  }
}
