/// Контроллер математических примеров
///
/// Управляет генерацией примеров, проверкой ответов и таймером.
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/game_constants.dart';
import '../../domain/entities/example_task_entity.dart';
import '../services/combo_service.dart';
import '../services/difficulty_service.dart';
import '../services/example_generator_service.dart';
import '../services/reward_service.dart';
import '../state/math_state.dart';

/// Результат проверки ответа
class AnswerCheckResult {
  final bool isCorrect;
  final int score;
  final int damage;
  final bool isFastAnswer;
  final int combo;

  const AnswerCheckResult({
    required this.isCorrect,
    required this.score,
    required this.damage,
    required this.isFastAnswer,
    required this.combo,
  });
}

/// Контроллер математических примеров
class MathController extends Notifier<MathState> {
  Timer? _timer;
  DateTime? _taskStartTime;

  final ExampleGeneratorService _generator = ExampleGeneratorService();
  final DifficultyService _difficultyService = DifficultyService();
  final ComboService _comboService = ComboService();
  final RewardService _rewardService = RewardService();

  /// Список использованных примеров (для избежания повторов)
  final List<ExampleTaskEntity> _usedTasks = [];

  /// Текущий мир
  int _currentWorldId = 0;

  @override
  MathState build() {
    ref.onDispose(() {
      _timer?.cancel();
    });
    return MathState.initial();
  }

  /// Инициализирует контроллер для мира
  void initialize(int worldId) {
    _currentWorldId = worldId;
    _usedTasks.clear();
    _comboService.resetSession();
    _difficultyService.reset();
    state = MathState.initial();
  }

  /// Генерирует новый пример
  void generateTask() {
    final task = _generator.generateUnique(
      _currentWorldId,
      _usedTasks,
      difficulty: _difficultyService.currentDifficulty,
    );

    _usedTasks.add(task);
    _taskStartTime = DateTime.now();

    state = state.prepareForNext(task);
    startTimer();
  }

  /// Отправляет ответ
  AnswerCheckResult submitAnswer(int answer) {
    if (state.currentTask == null) {
      return const AnswerCheckResult(
        isCorrect: false,
        score: 0,
        damage: 0,
        isFastAnswer: false,
        combo: 0,
      );
    }

    stopTimer();

    final timeSpent = _taskStartTime != null
        ? DateTime.now().difference(_taskStartTime!)
        : Duration.zero;

    final isCorrect = answer == state.currentTask!.correctAnswer;
    final isFastAnswer =
        timeSpent.inSeconds < ScoreConstants.fastAnswerThresholdSeconds;

    int score = 0;
    int damage = 0;
    int combo = 0;

    if (isCorrect) {
      // Обновляем комбо
      _comboService.onCorrectAnswer();
      combo = _comboService.currentCombo;

      // Обновляем сложность
      _difficultyService.onCorrectAnswer();

      // Рассчитываем очки
      score = _rewardService.calculateScore(
        combo: combo,
        timeSpentSeconds: timeSpent.inSeconds,
        difficulty: _difficultyService.currentDifficulty,
      );

      // Рассчитываем урон
      damage = _rewardService.calculateBossDamage(
        combo: combo,
        isFastAnswer: isFastAnswer,
      );

      state = state.onCorrectAnswer(score);
    } else {
      // Сбрасываем комбо
      _comboService.onWrongAnswer();

      // Обновляем сложность
      _difficultyService.onWrongAnswer();

      state = state.onWrongAnswer();
    }

    // Обновляем задачу с ответом
    final answeredTask = state.currentTask!.answer(answer, timeSpent);
    state = state.copyWith(currentTask: answeredTask);

    return AnswerCheckResult(
      isCorrect: isCorrect,
      score: score,
      damage: damage,
      isFastAnswer: isFastAnswer,
      combo: combo,
    );
  }

  /// Добавляет цифру к вводу
  void addDigit(String digit) {
    if (digit.length != 1 || !RegExp(r'[0-9]').hasMatch(digit)) return;
    state = state.addDigit(digit);
  }

  /// Удаляет последнюю цифру
  void removeDigit() {
    state = state.removeDigit();
  }

  /// Очищает ввод
  void clearInput() {
    state = state.clearInput();
  }

  /// Подтверждает введённый ответ
  AnswerCheckResult? confirmAnswer() {
    final answer = state.inputAsInt;
    if (answer == null) return null;

    return submitAnswer(answer);
  }

  /// Запускает таймер
  void startTimer() {
    _timer?.cancel();

    state = state.copyWith(
      timeRemaining: TimeConstants.answerTimeSeconds,
      isTimerRunning: true,
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.timeRemaining > 0) {
        state = state.tick();
      } else {
        onTimeUp();
      }
    });
  }

  /// Останавливает таймер
  void stopTimer() {
    _timer?.cancel();
    state = state.copyWith(isTimerRunning: false);
  }

  /// Ставит таймер на паузу
  void pauseTimer() {
    _timer?.cancel();
    state = state.copyWith(isTimerRunning: false);
  }

  /// Возобновляет таймер
  void resumeTimer() {
    if (state.timeRemaining <= 0) return;

    state = state.copyWith(isTimerRunning: true);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.timeRemaining > 0) {
        state = state.tick();
      } else {
        onTimeUp();
      }
    });
  }

  /// Обработка истечения времени
  void onTimeUp() {
    stopTimer();

    // Сбрасываем комбо
    _comboService.onWrongAnswer();
    _difficultyService.onWrongAnswer();

    state = state.onTimeout();

    // Отмечаем задачу как пропущенную
    if (state.currentTask != null) {
      final timeSpent = _taskStartTime != null
          ? DateTime.now().difference(_taskStartTime!)
          : Duration(seconds: TimeConstants.answerTimeSeconds);

      final skippedTask = state.currentTask!.markAsSkipped(timeSpent);
      state = state.copyWith(currentTask: skippedTask);
    }
  }

  /// Скрывает результат
  void hideResult() {
    state = state.copyWith(showResult: false);
  }

  /// Проверяет, нужно ли завершить сессию
  bool shouldEndSession(int maxTasks) {
    return state.tasksCompleted >= maxTasks;
  }

  /// Получает подсказку для текущего примера
  String? getHint() {
    if (state.currentTask == null) return null;
    return _generator.generateHint(state.currentTask!);
  }

  /// Использует Math Shield (автокоррекция)
  bool useMathShield() {
    return _comboService.useMathShield();
  }

  /// Сбрасывает состояние
  void reset() {
    _timer?.cancel();
    _usedTasks.clear();
    _comboService.resetSession();
    _difficultyService.reset();
    state = MathState.initial();
  }

  /// Получает текущую сложность
  int get currentDifficulty => _difficultyService.currentDifficulty;

  /// Получает текущее комбо
  int get currentCombo => _comboService.currentCombo;

  /// Получает максимальное комбо
  int get maxCombo => _comboService.maxCombo;

  /// Получает множитель комбо
  double get comboMultiplier => _comboService.multiplier;

  /// Получает уровень комбо
  ComboLevel get comboLevel => _comboService.comboLevel;

  /// Получает точность за сессию
  double get accuracy => state.accuracy;

  /// Устанавливает мир
  void setWorld(int worldId) {
    _currentWorldId = worldId;
  }
}

/// Provider для MathController
final mathControllerProvider =
    NotifierProvider<MathController, MathState>(MathController.new);
