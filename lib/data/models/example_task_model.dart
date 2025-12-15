/// Модель математического примера для сериализации
///
/// Расширяет [ExampleTaskEntity] и добавляет JSON-сериализацию.
library;

import '../../domain/entities/example_task_entity.dart';

/// Модель примера с поддержкой JSON
class ExampleTaskModel extends ExampleTaskEntity {
  const ExampleTaskModel({
    required super.id,
    required super.multiplicand,
    required super.multiplier,
    required super.correctAnswer,
    super.userAnswer,
    super.isCorrect,
    super.timeSpent,
    required super.createdAt,
  });

  /// Создаёт модель из JSON
  factory ExampleTaskModel.fromJson(Map<String, dynamic> json) {
    return ExampleTaskModel(
      id: json['id'] as String,
      multiplicand: json['multiplicand'] as int,
      multiplier: json['multiplier'] as int,
      correctAnswer: json['correctAnswer'] as int,
      userAnswer: json['userAnswer'] as int?,
      isCorrect: json['isCorrect'] as bool?,
      timeSpent: json['timeSpentMs'] != null
          ? Duration(milliseconds: json['timeSpentMs'] as int)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  /// Создаёт модель из Entity
  factory ExampleTaskModel.fromEntity(ExampleTaskEntity entity) {
    return ExampleTaskModel(
      id: entity.id,
      multiplicand: entity.multiplicand,
      multiplier: entity.multiplier,
      correctAnswer: entity.correctAnswer,
      userAnswer: entity.userAnswer,
      isCorrect: entity.isCorrect,
      timeSpent: entity.timeSpent,
      createdAt: entity.createdAt,
    );
  }

  /// Создаёт новый пример
  factory ExampleTaskModel.create({
    required int multiplicand,
    required int multiplier,
    String? id,
  }) {
    final taskId = id ??
        'task_${multiplicand}x${multiplier}_${DateTime.now().millisecondsSinceEpoch}';
    return ExampleTaskModel(
      id: taskId,
      multiplicand: multiplicand,
      multiplier: multiplier,
      correctAnswer: multiplicand * multiplier,
      createdAt: DateTime.now(),
    );
  }

  /// Создаёт пустую модель
  factory ExampleTaskModel.empty() {
    return ExampleTaskModel(
      id: 'empty',
      multiplicand: 0,
      multiplier: 0,
      correctAnswer: 0,
      createdAt: DateTime.now(),
    );
  }

  /// Конвертирует в JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'multiplicand': multiplicand,
      'multiplier': multiplier,
      'correctAnswer': correctAnswer,
      'userAnswer': userAnswer,
      'isCorrect': isCorrect,
      'timeSpentMs': timeSpent?.inMilliseconds,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Создаёт копию модели с изменёнными полями
  @override
  ExampleTaskModel copyWith({
    String? id,
    int? multiplicand,
    int? multiplier,
    int? correctAnswer,
    int? userAnswer,
    bool? isCorrect,
    Duration? timeSpent,
    DateTime? createdAt,
  }) {
    return ExampleTaskModel(
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

  /// Устанавливает ответ и проверяет его
  @override
  ExampleTaskModel answer(int answer, Duration timeTaken) {
    return copyWith(
      userAnswer: answer,
      isCorrect: answer == correctAnswer,
      timeSpent: timeTaken,
    );
  }

  /// Отмечает как пропущенный
  @override
  ExampleTaskModel markAsSkipped(Duration timeTaken) {
    return copyWith(
      isCorrect: false,
      timeSpent: timeTaken,
    );
  }
}

/// Расширение для конвертации списка моделей
extension ExampleTaskModelListExtension on List<ExampleTaskModel> {
  /// Конвертирует список в JSON
  List<Map<String, dynamic>> toJsonList() {
    return map((model) => model.toJson()).toList();
  }

  /// Создаёт список из JSON
  static List<ExampleTaskModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => ExampleTaskModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
