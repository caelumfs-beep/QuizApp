import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/question.dart';
import '../models/mistake_entry.dart';
import '../data/questions_data.dart';

class AppProvider extends ChangeNotifier {
  // --- Persistent State ---
  int _unlockedLevels = 1;
  Map<int, int> _levelScores = {}; // level -> best score
  List<MistakeEntry> _mistakes = [];

  // --- Quiz Session State ---
  int _currentLevel = 1;
  List<Question> _sessionQuestions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  int? _selectedAnswerIndex;
  bool _answered = false;
  List<MistakeEntry> _sessionMistakes = [];

  // --- Review Mode ---
  bool _isReviewMode = false;
  bool _isRetryMistakes = false;

  // Getters
  int get unlockedLevels => _unlockedLevels;
  Map<int, int> get levelScores => _levelScores;
  List<MistakeEntry> get mistakes => _mistakes;
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

  double get totalAccuracy {
    if (_levelScores.isEmpty) return 0;
    final total = _levelScores.values.fold(0, (a, b) => a + b);
    final maxPossible = _levelScores.length * 10;
    return maxPossible == 0 ? 0 : total / maxPossible;
  }

  AppProvider() {
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    _unlockedLevels = prefs.getInt('unlockedLevels') ?? 1;
    final scoresJson = prefs.getString('levelScores');
    if (scoresJson != null) {
      final decoded = jsonDecode(scoresJson) as Map<String, dynamic>;
      _levelScores = decoded.map((k, v) => MapEntry(int.parse(k), v as int));
    }
    final mistakesJson = prefs.getString('mistakes');
    if (mistakesJson != null) {
      final list = jsonDecode(mistakesJson) as List;
      _mistakes = list.map((e) {
        final q = allQuestions.firstWhere((q) => q.id == e['questionId']);
        return MistakeEntry(question: q, selectedIndex: e['selectedIndex']);
      }).toList();
    }
    notifyListeners();
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('unlockedLevels', _unlockedLevels);
    final scoresJson = jsonEncode(_levelScores.map((k, v) => MapEntry(k.toString(), v)));
    await prefs.setString('levelScores', scoresJson);
    final mistakesJson = jsonEncode(_mistakes.map((m) => {
      'questionId': m.question.id,
      'selectedIndex': m.selectedIndex,
    }).toList());
    await prefs.setString('mistakes', mistakesJson);
  }

  void startLevel(int level) {
    _currentLevel = level;
    _sessionQuestions = getQuestionsForLevel(level);
    _isReviewMode = false;
    _isRetryMistakes = false;
    _resetSession();
  }

  void startReviewMode() {
    _isReviewMode = true;
    _isRetryMistakes = false;
    _sessionQuestions = List.from(allQuestions)..shuffle();
    _resetSession();
  }

  void startRetryMistakes() {
    _isRetryMistakes = true;
    _isReviewMode = false;
    _sessionQuestions = _mistakes.map((m) => m.question).toList();
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
      // Update global mistakes list (replace if already exists)
      _mistakes.removeWhere((m) => m.question.id == q.id);
      _mistakes.add(entry);
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
      // Save best score
      final prev = _levelScores[_currentLevel] ?? 0;
      if (_score > prev) _levelScores[_currentLevel] = _score;

      // Unlock next level if passed
      if (_score >= passingScore && _currentLevel >= _unlockedLevels && _currentLevel < totalLevels) {
        _unlockedLevels = _currentLevel + 1;
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
    _mistakes.clear();
    await _saveProgress();
    notifyListeners();
  }

  Future<void> resetAllProgress() async {
    _unlockedLevels = 1;
    _levelScores = {};
    _mistakes = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }
}
