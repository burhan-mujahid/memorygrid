import 'dart:async';
import 'package:get/get.dart';
import '../models/game_state.dart';
import '../services/database_service.dart';

class GameController extends GetxController {
  final DatabaseService _db = DatabaseService();
  
  final RxInt currentLevel = 1.obs;
  final RxInt moves = 0.obs;
  final RxInt score = 0.obs;
  final RxBool isPlaying = false.obs;
  final RxList<bool> flippedTiles = <bool>[].obs;
  final RxList<int> tileValues = <int>[].obs;
  final RxList<int> selectedTiles = <int>[].obs;
  final Rx<Duration> elapsedTime = Duration.zero.obs;
  final Rx<List<GameState>> progressHistory = Rx<List<GameState>>([]);
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    ever(currentLevel, (_) => _initializeGrid());
    _initializeGrid();
    refreshProgress();
  }

  void _initializeGrid() {
    final totalTiles = gridSize * gridSize;
    if (flippedTiles.length != totalTiles) {
      flippedTiles.value = List.generate(totalTiles, (_) => false);
    } else {
      for (var i = 0; i < totalTiles; i++) {
        flippedTiles[i] = false;
      }
    }
    

    List<int> values = [];
    for (int i = 0; i < totalTiles ~/ 2; i++) {
      values.add(i);
      values.add(i);
    }
    values.shuffle();
    tileValues.value = values;
    
    // Reset selected tiles
    selectedTiles.clear();
  }

  int get gridSize {
    return ((currentLevel.value + 1) ~/ 2) * 2;
  }

  int get minPossibleMoves => (gridSize * gridSize) ~/ 2 * 2;
  int get maxAllowedMoves => (gridSize * gridSize * 1.5).toInt();

  void setLevel(int level) {
    if (level != currentLevel.value) {
      currentLevel.value = level;
      _initializeGrid();
      if (isPlaying.value) {
        _timer?.cancel();
        isPlaying.value = false;
        moves.value = 0;
        score.value = 0;
        elapsedTime.value = Duration.zero;
      }
    }
  }

  void initializeGame() {
    moves.value = 0;
    score.value = 0;
    isPlaying.value = true;
    selectedTiles.clear();
    elapsedTime.value = Duration.zero;
    
    _initializeGrid();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    elapsedTime.value = Duration.zero;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      elapsedTime.value += const Duration(seconds: 1);
    });
  }

  void flipTile(int index) {
    if (!isPlaying.value || 
        flippedTiles[index] || 
        selectedTiles.length >= 2 || 
        index >= flippedTiles.length) return;

    selectedTiles.add(index);
    flippedTiles[index] = true;
    moves.value++;

    if (selectedTiles.length == 2) {
      _checkMatch();
    }
  }

  void _checkMatch() {
    final firstTile = selectedTiles[0];
    final secondTile = selectedTiles[1];

    if (tileValues[firstTile] == tileValues[secondTile]) {
      // Match found
      selectedTiles.clear();
      _checkGameEnd();
    } else {
      // No match
      Future.delayed(const Duration(milliseconds: 1000), () {
        flippedTiles[firstTile] = false;
        flippedTiles[secondTile] = false;
        selectedTiles.clear();
        update();
      });
    }
  }

  void _checkGameEnd() {
    if (flippedTiles.every((tile) => tile)) {
      _timer?.cancel();
      isPlaying.value = false;
      _calculateScore();
      _saveProgress();
    }
  }

  void _calculateScore() {
    final movesPenalty = ((moves.value - minPossibleMoves) / maxAllowedMoves) * 100;
    score.value = (100 - movesPenalty).clamp(0, 100).toInt();
  }

  Future<void> _saveProgress() async {
    final state = GameState(
      level: currentLevel.value,
      moves: moves.value,
      score: score.value,
      date: DateTime.now(),
      timeInSeconds: elapsedTime.value.inSeconds,
    );
    await _db.saveProgress(state);
    await refreshProgress();
  }

  Future<void> refreshProgress() async {
    progressHistory.value = await _db.getLastSevenDaysProgress();
  }

  Future<List<GameState>> getLastSevenDaysProgress() async {
    return await _db.getLastSevenDaysProgress();
  }

  Future<int> getBestScore() async {
    return await _db.getBestScore(currentLevel.value);
  }

  void stopGame() {
    _timer?.cancel();
    isPlaying.value = false;
    moves.value = 0;
    score.value = 0;
    elapsedTime.value = Duration.zero;
    selectedTiles.clear();
    _initializeGrid();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
