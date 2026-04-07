import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/track_home_screen.dart';
import 'screens/vul_set_select_screen.dart';
import 'screens/level_select_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/result_screen.dart';
import 'screens/mistakes_screen.dart';
import 'screens/progress_screen.dart';
import 'widgets/app_theme.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: const CFSQuizApp(),
    ),
  );
}

class CFSQuizApp extends StatelessWidget {
  const CFSQuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CFS Quiz App Reviewer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashScreen(),
        '/home': (_) => const HomeScreen(),
        '/vul_sets': (_) => const VulSetSelectScreen(),
        '/track_home': (_) => const TrackHomeScreen(),
        '/levels': (_) => const LevelSelectScreen(),
        '/quiz': (_) => const QuizScreen(),
        '/result': (_) => const ResultScreen(),
        '/mistakes': (_) => const MistakesScreen(),
        '/progress': (_) => const ProgressScreen(),
      },
    );
  }
}
