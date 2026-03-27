class Question {
  final int id;
  final String question;
  final List<String> choices;
  final int correctIndex;

  const Question({
    required this.id,
    required this.question,
    required this.choices,
    required this.correctIndex,
  });

  String get correctAnswer => choices[correctIndex];
}
