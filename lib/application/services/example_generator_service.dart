/// Сервис генерации математических примеров
///
/// Генерирует примеры умножения для указанного мира.
library;

import 'dart:math' as math;

import '../../core/config/game_constants.dart';
import '../../domain/entities/example_task_entity.dart';
import '../state/math_state.dart';

/// Сервис генерации примеров
class ExampleGeneratorService {
  final math.Random _random;

  /// Создаёт сервис с опциональным генератором случайных чисел
  ExampleGeneratorService({math.Random? random})
      : _random = random ?? math.Random();

  /// Генерирует пример для указанного мира
  ///
  /// [worldId] - номер мира (0-9), определяет множитель
  /// [difficulty] - уровень сложности (1-5)
  ExampleTaskEntity generateForWorld(int worldId, {int difficulty = 1}) {
    // Множитель = номер мира
    final multiplier = worldId.clamp(0, 9);

    // Генерируем множимое в зависимости от сложности
    final multiplicand = _generateMultiplicand(difficulty);

    return ExampleTaskEntity.create(
      multiplicand: multiplicand,
      multiplier: multiplier,
    );
  }

  /// Генерирует пакет примеров для мира
  ///
  /// [worldId] - номер мира
  /// [count] - количество примеров
  /// [difficulty] - уровень сложности
  /// [avoidDuplicates] - избегать повторов множимых
  List<ExampleTaskEntity> generateBatch(
    int worldId,
    int count, {
    int difficulty = 1,
    bool avoidDuplicates = true,
  }) {
    final multiplier = worldId.clamp(0, 9);
    final tasks = <ExampleTaskEntity>[];
    final usedMultiplicands = <int>{};

    for (var i = 0; i < count; i++) {
      int multiplicand;

      if (avoidDuplicates && usedMultiplicands.length < 11) {
        // Пытаемся найти неиспользованное число
        var attempts = 0;
        do {
          multiplicand = _generateMultiplicand(difficulty);
          attempts++;
        } while (usedMultiplicands.contains(multiplicand) && attempts < 20);

        usedMultiplicands.add(multiplicand);

        // Сбрасываем, если использовали все
        if (usedMultiplicands.length >= 11) {
          usedMultiplicands.clear();
        }
      } else {
        multiplicand = _generateMultiplicand(difficulty);
      }

      tasks.add(ExampleTaskEntity.create(
        multiplicand: multiplicand,
        multiplier: multiplier,
      ));
    }

    return tasks;
  }

  /// Генерирует уникальный пример, не входящий в список исключений
  ExampleTaskEntity generateUnique(
    int worldId,
    List<ExampleTaskEntity> exclude, {
    int difficulty = 1,
  }) {
    final multiplier = worldId.clamp(0, 9);

    // Собираем использованные множимые
    final usedMultiplicands = exclude
        .where((t) => t.multiplier == multiplier)
        .map((t) => t.multiplicand)
        .toSet();

    // Доступные множимые
    final available = List.generate(11, (i) => i)
        .where((m) => !usedMultiplicands.contains(m))
        .toList();

    int multiplicand;
    if (available.isNotEmpty) {
      multiplicand = available[_random.nextInt(available.length)];
    } else {
      // Все использованы, генерируем любое
      multiplicand = _generateMultiplicand(difficulty);
    }

    return ExampleTaskEntity.create(
      multiplicand: multiplicand,
      multiplier: multiplier,
    );
  }

  /// Генерирует примеры для битвы с боссом
  List<ExampleTaskEntity> generateForBoss(int worldId, {int difficulty = 3}) {
    return generateBatch(
      worldId,
      WorldConstants.examplesPerBoss,
      difficulty: difficulty,
      avoidDuplicates: true,
    );
  }

  /// Генерирует примеры для уровня
  List<ExampleTaskEntity> generateForLevel(int worldId, {int difficulty = 1}) {
    return generateBatch(
      worldId,
      WorldConstants.examplesPerLevel,
      difficulty: difficulty,
      avoidDuplicates: true,
    );
  }

  /// Генерирует множимое в зависимости от сложности
  int _generateMultiplicand(int difficulty) {
    switch (difficulty.clamp(1, 5)) {
      case 1:
        // Простые: 0-5
        return _random.nextInt(6);
      case 2:
        // Лёгкие: 0-7
        return _random.nextInt(8);
      case 3:
        // Средние: 0-10
        return _random.nextInt(11);
      case 4:
        // Сложные: 2-10
        return _random.nextInt(9) + 2;
      case 5:
        // Экстра: 5-10
        return _random.nextInt(6) + 5;
      default:
        return _random.nextInt(11);
    }
  }

  /// Проверяет ответ на пример
  AnswerResult checkAnswer(ExampleTaskEntity task, int answer) {
    if (answer == task.correctAnswer) {
      return AnswerResult.correct;
    }
    return AnswerResult.wrong;
  }

  /// Генерирует подсказку для примера
  String generateHint(ExampleTaskEntity task) {
    final a = task.multiplicand;
    final b = task.multiplier;

    // Разные типы подсказок
    final hints = [
      'Подумай: $a группы по $b = ?',
      'Сложи $b $a раз(а)',
      '$a × $b — это $a, сложенное $b раз',
      'Вспомни: ${b - 1} × $a = ${(b - 1) * a}, прибавь ещё $a',
    ];

    return hints[_random.nextInt(hints.length)];
  }
}
