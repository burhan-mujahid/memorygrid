class GameState {
  final int level;
  final int moves;
  final int score;
  final DateTime date;
  final int timeInSeconds;

  GameState({
    required this.level,
    required this.moves,
    required this.score,
    required this.date,
    required this.timeInSeconds,
  });

  Map<String, dynamic> toMap() {
    return {
      'level': level,
      'moves': moves,
      'score': score,
      'date': date.toIso8601String(),
      'timeInSeconds': timeInSeconds,
    };
  }

  factory GameState.fromMap(Map<String, dynamic> map) {
    return GameState(
      level: map['level'],
      moves: map['moves'],
      score: map['score'],
      date: DateTime.parse(map['date']),
      timeInSeconds: map['timeInSeconds'],
    );
  }
}
