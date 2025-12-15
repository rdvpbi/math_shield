/// Состояние математических примеров
///
/// Управляет текущим примером, статистикой и таймером.
library;

import '../../core/config/game_constants.dart';
import '../../domain/entities/example_task_entity.dart';

/// Результат ответа
enum AnswerResult {
  /// Ещё не отвечено
  none,

  /// Правильный ответ
  correct,

  /// Неправильный ответ
  wrong,

  /// Время истекло
  timeout,
}

/// Состояние математических примеров
///
/// Immutable класс, изменения через [copyWith].
class MathState {
  /// Текущий пример
  final ExampleTaskEntity? currentTask;

  /// Количество выполненных примеров
  final int tasksCompleted;

  /// Количество правильных ответов
  final int correctAnswers;

  /// Количество неправильных ответов
  final int wrongAnswers;

  /// Текущее комбо
  final int combo;

  /// Максимальное достигнутое комбо
  final int maxCombo;

  /// Оставшееся время (секунды)
  final int timeRemaining;

  /// Текущий счёт сессии
  final int sessionScore;

  /// Результат последнего ответа
  final AnswerResult lastResult;

  /// Введённый ответ (для отображения)
  final String inputValue;

  /// Активен ли таймер
  final bool isTimerRunning;

  /// Показывать ли результат
  final bool showResult;

  /// Создаёт состояние примеров
  const MathState({
    this.currentTask,
    this.tasksCompleted = 0,
    this.correctAnswers = 0,
    this.wrongAnswers = 0,
    this.combo = 0,
    this.maxCombo = 0,
    this.timeRemaining = TimeConstants.answerTimeSeconds,
    this.sessionScore = 0,
    this.lastResult = AnswerResult.none,
    this.inputValue = '',
    this.isTimerRunning = false,
    this.showResult = false,
  });

  /// Начальное состояние
  factory MathState.initial() {
    return const MathState();
  }

  /// Состояние с новым примером
  factory MathState.withTask(ExampleTaskEntity task) {
    return MathState(
      currentTask: task,
      timeRemaining: TimeConstants.answerTimeSeconds,
      isTimerRunning: true,
    );
  }

  /// Проверяет, есть ли текущий пример
  bool get hasTask => currentTask != null;

  /// Проверяет, введён ли ответ
  bool get hasInput => inputValue.isNotEmpty;

  /// Получает введённое число
  int? get inputAsInt => int.tryParse(inputValue);

  /// Процент правильных ответов
  double get accuracy {
    if (tasksCompleted == 0) return 0.0;
    return correctAnswers / tasksCompleted;
  }

  /// Процент правильных в целых числах
  int get accuracyPercent => (accuracy * 100).round();

  /// Множитель комбо
  double get comboMultiplier => ComboConstants.calculateMultiplier(combo);

  /// Проверяет, истекло ли время
  bool get isTimeUp => timeRemaining <= 0;

  /// Проверяет, мало ли времени (< 5 сек)
  bool get isTimeLow => timeRemaining <= 5 && timeRemaining > 0;

  /// Форматированное время (MM:SS)
  String get formattedTime {
    final minutes = timeRemaining ~/ 60;
    final seconds = timeRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Форматированное время (только секунды)
  String get formattedSeconds => timeRemaining.toString();

  /// Создаёт копию с изменёнными полями
  MathState copyWith({
    ExampleTaskEntity? currentTask,
    int? tasksCompleted,
    int? correctAnswers,
    int? wrongAnswers,
    int? combo,
    int? maxCombo,
    int? timeRemaining,
    int? sessionScore,
    AnswerResult? lastResult,
    String? inputValue,
    bool? isTimerRunning,
    bool? showResult,
    bool clearTask = false,
    bool clearInput = false,
  }) {
    return MathState(
      currentTask: clearTask ? null : (currentTask ?? this.currentTask),
      tasksCompleted: tasksCompleted ?? this.tasksCompleted,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      wrongAnswers: wrongAnswers ?? this.wrongAnswers,
      combo: combo ?? this.combo,
      maxCombo: maxCombo ?? this.maxCombo,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      sessionScore: sessionScore ?? this.sessionScore,
      lastResult: lastResult ?? this.lastResult,
      inputValue: clearInput ? '' : (inputValue ?? this.inputValue),
      isTimerRunning: isTimerRunning ?? this.isTimerRunning,
      showResult: showResult ?? this.showResult,
    );
  }

  /// Добавляет цифру к вводу
  MathState addDigit(String digit) {
    if (inputValue.length >= 3) return this; // Максимум 3 цифры (0-100)
    final newValue = inputValue + digit;
    return copyWith(inputValue: newValue);
  }

  /// Удаляет последнюю цифру
  MathState removeDigit() {
    if (inputValue.isEmpty) return this;
    return copyWith(inputValue: inputValue.substring(0, inputValue.length - 1));
  }

  /// Очищает ввод
  MathState clearInput() {
    return copyWith(clearInput: true);
  }

  /// Уменьшает время на 1 секунду
  MathState tick() {
    if (timeRemaining <= 0) return this;
    return copyWith(timeRemaining: timeRemaining - 1);
  }

  /// Регистрирует правильный ответ
  MathState onCorrectAnswer(int points) {
    final newCombo = combo + 1;
    return copyWith(
      tasksCompleted: tasksCompleted + 1,
      correctAnswers: correctAnswers + 1,
      combo: newCombo,
      maxCombo: newCombo > maxCombo ? newCombo : maxCombo,
      sessionScore: sessionScore + points,
      lastResult: AnswerResult.correct,
      showResult: true,
      isTimerRunning: false,
    );
  }

  /// Регистрирует неправильный ответ
  MathState onWrongAnswer() {
    return copyWith(
      tasksCompleted: tasksCompleted + 1,
      wrongAnswers: wrongAnswers + 1,
      combo: 0,
      lastResult: AnswerResult.wrong,
      showResult: true,
      isTimerRunning: false,
    );
  }

  /// Регистрирует таймаут
  MathState onTimeout() {
    return copyWith(
      tasksCompleted: tasksCompleted + 1,
      wrongAnswers: wrongAnswers + 1,
      combo: 0,
      lastResult: AnswerResult.timeout,
      showResult: true,
      isTimerRunning: false,
    );
  }

  /// Подготавливает к следующему примеру
  MathState prepareForNext(ExampleTaskEntity newTask) {
    return copyWith(
      currentTask: newTask,
      timeRemaining: TimeConstants.answerTimeSeconds,
      lastResult: AnswerResult.none,
      showResult: false,
      isTimerRunning: true,
      clearInput: true,
    );
  }

  /// Сбрасывает состояние для новой сессии
  MathState reset() {
    return const MathState();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MathState &&
        other.currentTask == currentTask &&
        other.tasksCompleted == tasksCompleted &&
        other.correctAnswers == correctAnswers &&
        other.wrongAnswers == wrongAnswers &&
        other.combo == combo &&
        other.maxCombo == maxCombo &&
        other.timeRemaining == timeRemaining &&
        other.sessionScore == sessionScore &&
        other.lastResult == lastResult &&
        other.inputValue == inputValue &&
        other.isTimerRunning == isTimerRunning &&
        other.showResult == showResult;
  }

  @override
  int get hashCode {
    return Object.hash(
      currentTask,
      tasksCompleted,
      correctAnswers,
      wrongAnswers,
      combo,
      maxCombo,
      timeRemaining,
      sessionScore,
      lastResult,
      inputValue,
      isTimerRunning,
      showResult,
    );
  }

  @override
  String toString() {
    return 'MathState(task: ${currentTask?.formattedQuestion}, '
        'completed: $tasksCompleted, correct: $correctAnswers, '
        'combo: $combo, time: $timeRemaining)';
  }
}
