import 'question.dart';

class MistakeEntry {
  final Question question;
  final int selectedIndex;

  const MistakeEntry({required this.question, required this.selectedIndex});

  String get selectedAnswer => question.choices[selectedIndex];
  String get correctAnswer => question.correctAnswer;
}
