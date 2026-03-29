import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const SizedBox(height: 4),
              Text(
                "Let's play!",
                style: GoogleFonts.nunito(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF003266),
                ),
              ),
              const SizedBox(height: 20),
              // Top banner card
              Container(
                width: double.infinity,
                height: 130,
                decoration: BoxDecoration(
                  color: const Color(0xFF003266),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Level ${provider.unlockedLevels > 13 ? 13 : provider.unlockedLevels} unlocked',
                            style: GoogleFonts.nunito(
                              fontSize: 13,
                              color: Colors.white60,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Trad Reviewer',
                            style: GoogleFonts.nunito(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: (provider.unlockedLevels - 1) / 13,
                              backgroundColor: Colors.white24,
                              color: const Color(0xFF38BDF8),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Image.asset('assets/images/bbook.png', height: 90),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Start Review card
              _MenuCard(
                image: 'assets/images/start_review.png',
                title: 'Start Review',
                subtitle: 'Pick a level and start!',
                buttonLabel: 'Play now!',
                onTap: () => Navigator.pushNamed(context, '/levels'),
              ),
              const SizedBox(height: 16),
              // Bottom two cards
              Row(
                children: [
                  Expanded(
                    child: _SmallCard(
                      image: 'assets/images/progress.png',
                      label: 'Progress',
                      onTap: () => Navigator.pushNamed(context, '/progress'),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _SmallCard(
                      image: 'assets/images/review_mistakes.png',
                      label: 'Mistakes',
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
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Review All Questions
              _MenuCard(
                image: 'assets/images/review_allquestions.png',
                title: 'Review All Questions',
                subtitle: 'Go through all 122 questions',
                buttonLabel: 'Review now!',
                onTap: () {
                  provider.startReviewMode();
                  Navigator.pushNamed(context, '/quiz');
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback onTap;

  const _MenuCard({
    required this.image,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8ECF0)),
      ),
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.nunito(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF003266),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: onTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF003266),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      buttonLabel,
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Image.asset(image, height: 80, fit: BoxFit.contain),
        ],
      ),
    );
  }
}

class _SmallCard extends StatelessWidget {
  final String image;
  final String label;
  final VoidCallback onTap;

  const _SmallCard({required this.image, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE8ECF0)),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(image, height: 55, fit: BoxFit.contain),
            const SizedBox(height: 10),
            Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF003266),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
