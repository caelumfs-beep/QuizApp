import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/question.dart';
import '../models/mistake_entry.dart';
import '../data/questions_data.dart';
import '../data/set_a_data.dart';
import '../data/set_b_data.dart';

enum QuizTrack { trad, vulSetA, vulSetB }

class TrackProgress {
  int unlockedLevels;
  Map<int, int> levelScores;
  List<MistakeEntry> mistakes;

  TrackProgress({
    this.unlockedLevels = 1,
    Map<int, int>? levelScores,
    List<MistakeEntry>? mistakes,
  })  : levelScores = levelScores ?? {},
        mistakes = mistakes ?? [];
}

class AppProvider extends ChangeNotifier {
  // --- Track Progress ---
  final Map<QuizTrack, TrackProgress> _trackProgress = {
    QuizTrack.trad: TrackProgress(),
    QuizTrack.vulSetA: TrackProgress(),
    QuizTrack.vulSetB: TrackProgress(),
  };

  // --- Quiz Session State ---
  QuizTrack _currentTrack = QuizTrack.trad;
  int _currentLevel = 1;
  List<Question> _sessionQuestions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  int? _selectedAnswerIndex;
  bool _answered = false;
  List<MistakeEntry> _sessionMistakes = [];
  bool _isReviewMode = false;
  bool _isRetryMistakes = false;

  // --- Getters ---
  QuizTrack get currentTrack => _currentTrack;
  TrackProgress get _tp => _trackProgress[_currentTrack]!;

  int get unlockedLevels => _tp.unlockedLevels;
  Map<int, int> get levelScores => _tp.levelScores;
  List<MistakeEntry> get mistakes => _tp.mistakes;

  int get currentLevel => _currentLevel;
  List<Question> get sessionQuestions => _sessionQuestions;
  int get currentQuestionIndex => _currentQuestionIndex;
  int get score => _score;
  int? get selectedAnswerIndex => _selectedAnswerIndex;
  bool get answered => _answered;
  bool get isReviewMode => _isReviewMode;
  bool get isRetryMistakes => _isRetryMistakes;
  List<MistakeEntry> get sessionMistakes => _sessionMistakes;

  Question get currentQuestion => _sessionQuestions[_currentQuestionIndex];
  bool get isLastQuestion => _currentQuestionIndex >= _sessionQuestions.length - 1;
  int get totalQuestions => _sessionQuestions.length;

  int get totalLevelsForTrack {
    switch (_currentTrack) {
      case QuizTrack.trad: return totalLevels;
      case QuizTrack.vulSetA: return setATotalLevels;
      case QuizTrack.vulSetB: return setBTotalLevels;
    }
  }

  int get passingScoreForTrack {
    switch (_currentTrack) {
      case QuizTrack.trad: return passingScore;
      case QuizTrack.vulSetA: return setAPassingScore;
      case QuizTrack.vulSetB: return setBPassingScore;
    }
  }

  List<Question> get allQuestionsForTrack {
    switch (_currentTrack) {
      case QuizTrack.trad: return allQuestions;
      case QuizTrack.vulSetA: return setAQuestions;
      case QuizTrack.vulSetB: return setBQuestions;
    }
  }

  double get totalAccuracy {
    if (_tp.levelScores.isEmpty) return 0;
    final total = _tp.levelScores.values.fold(0, (a, b) => a + b);
    final maxPossible = _tp.levelScores.length * 10;
    return maxPossible == 0 ? 0 : total / maxPossible;
  }

  AppProvider() {
    _loadProgress();
  }

  void setTrack(QuizTrack track) {
    _currentTrack = track;
    notifyListeners();
  }

  int getTrackUnlocked(QuizTrack track) {
    return _trackProgress[track]!.unlockedLevels;
  }

  List<Question> _getQuestionsForLevel(int level) {
    return getQuestionsForLevelInTrack(level);
  }

  List<Question> getQuestionsForLevelInTrack(int level) {
    switch (_currentTrack) {
      case QuizTrack.trad: return getQuestionsForLevel(level);
      case QuizTrack.vulSetA: return getSetAQuestionsForLevel(level);
      case QuizTrack.vulSetB: return getSetBQuestionsForLevel(level);
    }
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    for (final track in QuizTrack.values) {
      final key = track.name;
      final tp = _trackProgress[track]!;

      tp.unlockedLevels = prefs.getInt('${key}_unlockedLevels') ?? 1;

      final scoresJson = prefs.getString('${key}_levelScores');
      if (scoresJson != null) {
        final decoded = jsonDecode(scoresJson) as Map<String, dynamic>;
        tp.levelScores = decoded.map((k, v) => MapEntry(int.parse(k), v as int));
      }

      final mistakesJson = prefs.getString('${key}_mistakes');
      if (mistakesJson != null) {
        final list = jsonDecode(mistakesJson) as List;
        final sourceList = track == QuizTrack.trad
            ? allQuestions
            : track == QuizTrack.vulSetA
                ? setAQuestions
                : setBQuestions;
        tp.mistakes = list.map((e) {
          final q = sourceList.firstWhere((q) => q.id == e['questionId'],
              orElse: () => sourceList.first);
          return MistakeEntry(question: q, selectedIndex: e['selectedIndex']);
        }).toList();
      }
    }
    notifyListeners();
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final key = _currentTrack.name;
    final tp = _tp;

    await prefs.setInt('${key}_unlockedLevels', tp.unlockedLevels);
    await prefs.setString('${key}_levelScores',
        jsonEncode(tp.levelScores.map((k, v) => MapEntry(k.toString(), v))));
    await prefs.setString(
        '${key}_mistakes',
        jsonEncode(tp.mistakes
            .map((m) => {'questionId': m.question.id, 'selectedIndex': m.selectedIndex})
            .toList()));
  }

  void startLevel(int level) {
    _currentLevel = level;
    _sessionQuestions = _getQuestionsForLevel(level);
    _isReviewMode = false;
    _isRetryMistakes = false;
    _resetSession();
  }

  void startReviewMode() {
    _isReviewMode = true;
    _isRetryMistakes = false;
    _sessionQuestions = List.from(allQuestionsForTrack)..shuffle();
    _resetSession();
  }

  void startRetryMistakes() {
    _isRetryMistakes = true;
    _isReviewMode = false;
    _sessionQuestions = _tp.mistakes.map((m) => m.question).toList();
    _resetSession();
  }

  void _resetSession() {
    _currentQuestionIndex = 0;
    _score = 0;
    _selectedAnswerIndex = null;
    _answered = false;
    _sessionMistakes = [];
    notifyListeners();
  }

  void selectAnswer(int index) {
    if (_answered) return;
    _selectedAnswerIndex = index;
    _answered = true;

    final q = currentQuestion;
    if (index == q.correctIndex) {
      _score++;
    } else {
      final entry = MistakeEntry(question: q, selectedIndex: index);
      _sessionMistakes.add(entry);
      _tp.mistakes.removeWhere((m) => m.question.id == q.id);
      _tp.mistakes.add(entry);
    }
    notifyListeners();
  }

  void nextQuestion() {
    if (!isLastQuestion) {
      _currentQuestionIndex++;
      _selectedAnswerIndex = null;
      _answered = false;
      notifyListeners();
    }
  }

  Future<void> finishLevel() async {
    if (!_isReviewMode && !_isRetryMistakes) {
      final prev = _tp.levelScores[_currentLevel] ?? 0;
      if (_score > prev) _tp.levelScores[_currentLevel] = _score;

      if (_score >= passingScoreForTrack &&
          _currentLevel >= _tp.unlockedLevels &&
          _currentLevel < totalLevelsForTrack) {
        _tp.unlockedLevels = _currentLevel + 1;
      }
      await _saveProgress();
    }
    notifyListeners();
  }

  int starsForScore(int score, int total) {
    final ratio = score / total;
    if (ratio >= 0.9) return 3;
    if (ratio >= 0.7) return 2;
    return 1;
  }

  Future<void> clearMistakes() async {
    _tp.mistakes.clear();
    await _saveProgress();
    notifyListeners();
  }

  Future<void> resetAllProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    for (final track in QuizTrack.values) {
      _trackProgress[track] = TrackProgress();
    }
    notifyListeners();
  }
}
