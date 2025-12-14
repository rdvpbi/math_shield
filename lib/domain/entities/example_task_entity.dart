/// Сущность математического примера
///
/// Представляет один пример на умножение,
/// который игрок должен решить.
library;

/// Математический пример (задача)
///
/// Immutable класс, изменения через [copyWith].
class ExampleTaskEntity {
  /// Уникальный идентификатор задачи
  final String id;

  /// Первое число (множимое) — случайное от 0 до 10
  final int multiplicand;

  /// Второе число (множитель) — номер мира (0-9)
  final int multiplier;

  /// Правильный ответ (multiplicand × multiplier)
  final int correctAnswer;

  /// Ответ пользователя (null если не отвечено)
  final int? userAnswer;

  /// Правильно ли ответил пользователь (null если не проверено)
  final bool? isCorrect;

  /// Время, потраченное на ответ
  final Duration? timeSpent;

  /// Время создания задачи
  final DateTime createdAt;

  /// Создаёт сущность примера
  const ExampleTaskEntity({
    required this.id,
    required this.multiplicand,
    required this.multiplier,
    required this.correctAnswer,
    this.userAnswer,
    this.isCorrect,
    this.timeSpent,
    required this.createdAt,
  });

  /// Создаёт новый пример для указанного множителя
  factory ExampleTaskEntity.create({
    required int multiplicand,
    required int multiplier,
    String? id,
  }) {
    final taskId = id ??
        'task_${multiplicand}x$multiplier\_${DateTime.now().millisecondsSinceEpoch}';

    return ExampleTaskEntity(
      id: taskId,
      multiplicand: multiplicand,
      multiplier: multiplier,
      correctAnswer: multiplicand * multiplier,
      createdAt: DateTime.now(),
    );
  }

  /// Создаёт пустой пример (placeholder)
  factory ExampleTaskEntity.empty() {
    return ExampleTaskEntity(
      id: 'empty',
      multiplicand: 0,
      multiplier: 0,
      correctAnswer: 0,
      createdAt: DateTime.now(),
    );
  }

  /// Проверяет, был ли дан ответ
  bool get isAnswered => userAnswer != null;

  /// Проверяет, правильный ли ответ
  bool get isAnswerCorrect => userAnswer == correctAnswer;

  /// Проверяет, пропущен ли пример (время истекло без ответа)
  bool get isSkipped => !isAnswered && timeSpent != null;

  /// Форматированное представление примера: "5 × 3 = ?"
  String get formattedQuestion => '$multiplicand × $multiplier = ?';

  /// Форматированное представление с ответом: "5 × 3 = 15"
  String get formattedWithAnswer => '$multiplicand × $multiplier = $correctAnswer';

  /// Форматированное представление с ответом пользователя
  String get formattedWithUserAnswer {
    if (userAnswer == null) return formattedQuestion;
    return '$multiplicand × $multiplier = $userAnswer';
  }

  /// Время ответа в секундах (или null)
  int? get timeSpentSeconds => timeSpent?.inSeconds;

  /// Создаёт копию с изменёнными полями
  ExampleTaskEntity copyWith({
    String? id,
    int? multiplicand,
    int? multiplier,
    int? correctAnswer,
    int? userAnswer,
    bool? isCorrect,
    Duration? timeSpent,
    DateTime? createdAt,
  }) {
    return ExampleTaskEntity(
      id: id ?? this.id,
      multiplicand: multiplicand ?? this.multiplicand,
      multiplier: multiplier ?? this.multiplier,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      userAnswer: userAnswer ?? this.userAnswer,
      isCorrect: isCorrect ?? this.isCorrect,
      timeSpent: timeSpent ?? this.timeSpent,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Устанавливает ответ пользователя и проверяет его
  ExampleTaskEntity answer(int answer, Duration timeTaken) {
    return copyWith(
      userAnswer: answer,
      isCorrect: answer == correctAnswer,
      timeSpent: timeTaken,
    );
  }

  /// Отмечает пример как пропущенный (время истекло)
  ExampleTaskEntity markAsSkipped(Duration timeTaken) {
    return copyWith(
      isCorrect: false,
      timeSpent: timeTaken,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExampleTaskEntity &&
        other.id == id &&
        other.multiplicand == multiplicand &&
        other.multiplier == multiplier &&
        other.correctAnswer == correctAnswer &&
        other.userAnswer == userAnswer &&
        other.isCorrect == isCorrect &&
        other.timeSpent == timeSpent;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      multiplicand,
      multiplier,
      correctAnswer,
      userAnswer,
      isCorrect,
      timeSpent,
    );
  }

  @override
  String toString() {
    final status = isCorrect == null
        ? 'pending'
        : (isCorrect! ? 'correct' : 'wrong');
    return 'ExampleTaskEntity($formattedQuestion, status: $status)';
  }
}
