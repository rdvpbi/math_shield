/// Реализация репозитория математических примеров
///
/// Генерирует примеры локально и сохраняет историю.
library;

import 'dart:math' as math;

import 'package:dartz/dartz.dart';

import '../../core/config/game_constants.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/example_task_entity.dart';
import '../../domain/repositories/example_repository.dart';
import '../datasources/local_datasource.dart';
import '../models/example_task_model.dart';

/// Реализация репозитория примеров
class ExampleRepositoryImpl implements ExampleRepository {
  final LocalDataSource _dataSource;
  final math.Random _random;

  ExampleRepositoryImpl(
    this._dataSource, {
    math.Random? random,
  }) : _random = random ?? math.Random();

  @override
  Future<Either<Failure, ExampleTaskEntity>> generateExample(
    int multiplier,
    int difficulty,
  ) async {
    try {
      // Валидация множителя
      if (multiplier < WorldConstants.minMultiplier ||
          multiplier > WorldConstants.maxMultiplier) {
        return Left(ValidationFailure.invalidMultiplier(multiplier));
      }

      // Валидация сложности
      if (difficulty < DifficultyConstants.minDifficulty ||
          difficulty > DifficultyConstants.maxDifficulty) {
        return Left(ValidationFailure.outOfRange(
          field: 'difficulty',
          value: difficulty,
          min: DifficultyConstants.minDifficulty,
          max: DifficultyConstants.maxDifficulty,
        ));
      }

      // Генерируем множимое в зависимости от сложности
      final multiplicand = _generateMultiplicand(difficulty);

      // Создаём пример
      final task = ExampleTaskModel.create(
        multiplicand: multiplicand,
        multiplier: multiplier,
      );

      return Right(task);
    } catch (e, stackTrace) {
      return Left(CacheFailure(
        message: 'Не удалось сгенерировать пример: $e',
        stackTrace: stackTrace,
      ));
    }
  }

  /// Генерирует множимое в зависимости от сложности
  int _generateMultiplicand(int difficulty) {
    // Базовый диапазон: 0-10
    // Сложность влияет на распределение (высокая сложность = больше крупных чисел)

    switch (difficulty) {
      case 1:
        // Простые числа: 0-5
        return _random.nextInt(6);
      case 2:
        // Лёгкие: 0-7
        return _random.nextInt(8);
      case 3:
        // Средние: 0-10
        return _random.nextInt(11);
      case 4:
        // Сложные: 2-10 (без простых 0 и 1)
        return _random.nextInt(9) + 2;
      case 5:
        // Экстра: 5-10 (только сложные)
        return _random.nextInt(6) + 5;
      default:
        return _random.nextInt(11);
    }
  }

  @override
  Future<Either<Failure, List<ExampleTaskEntity>>> generateExampleBatch(
    int multiplier,
    int count, {
    int difficulty = 1,
  }) async {
    try {
      // Валидация
      if (multiplier < WorldConstants.minMultiplier ||
          multiplier > WorldConstants.maxMultiplier) {
        return Left(ValidationFailure.invalidMultiplier(multiplier));
      }

      if (count <= 0 || count > 100) {
        return Left(ValidationFailure.outOfRange(
          field: 'count',
          value: count,
          min: 1,
          max: 100,
        ));
      }

      final tasks = <ExampleTaskModel>[];
      final usedMultiplicands = <int>{};

      for (var i = 0; i < count; i++) {
        int multiplicand;

        // Пытаемся избежать повторов
        var attempts = 0;
        do {
          multiplicand = _generateMultiplicand(difficulty);
          attempts++;
        } while (usedMultiplicands.contains(multiplicand) && attempts < 20);

        usedMultiplicands.add(multiplicand);

        // Если использовали все числа, сбрасываем
        if (usedMultiplicands.length > 10) {
          usedMultiplicands.clear();
        }

        tasks.add(ExampleTaskModel.create(
          multiplicand: multiplicand,
          multiplier: multiplier,
        ));
      }

      return Right(tasks);
    } catch (e, stackTrace) {
      return Left(CacheFailure(
        message: 'Не удалось сгенерировать пакет примеров: $e',
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Either<Failure, ExampleTaskEntity>> generateUniqueExample(
    int multiplier,
    int difficulty,
    List<ExampleTaskEntity> exclude,
  ) async {
    try {
      // Собираем использованные множимые
      final usedMultiplicands = exclude
          .where((t) => t.multiplier == multiplier)
          .map((t) => t.multiplicand)
          .toSet();

      // Доступные множимые
      final available = List.generate(11, (i) => i)
          .where((m) => !usedMultiplicands.contains(m))
          .toList();

      if (available.isEmpty) {
        // Все числа использованы, генерируем любое
        return generateExample(multiplier, difficulty);
      }

      // Выбираем случайное из доступных
      final multiplicand = available[_random.nextInt(available.length)];

      final task = ExampleTaskModel.create(
        multiplicand: multiplicand,
        multiplier: multiplier,
      );

      return Right(task);
    } catch (e, stackTrace) {
      return Left(CacheFailure(
        message: 'Не удалось сгенерировать уникальный пример: $e',
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveResult(ExampleTaskEntity task) async {
    try {
      final model = ExampleTaskModel.fromEntity(task);
      final success = await _dataSource.saveTaskResult(model);

      if (success) {
        return const Right(unit);
      }

      return Left(CacheFailure.writeError('history'));
    } catch (e, stackTrace) {
      return Left(CacheFailure(
        message: 'Не удалось сохранить результат: $e',
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveResultBatch(
    List<ExampleTaskEntity> tasks,
  ) async {
    try {
      for (final task in tasks) {
        final model = ExampleTaskModel.fromEntity(task);
        await _dataSource.saveTaskResult(model);
      }
      return const Right(unit);
    } catch (e, stackTrace) {
      return Left(CacheFailure(
        message: 'Не удалось сохранить результаты: $e',
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Either<Failure, List<ExampleTaskEntity>>> getHistory(
    int worldId, {
    int limit = 100,
  }) async {
    try {
      final history = await _dataSource.getHistory(
        worldId: worldId,
        limit: limit,
      );
      return Right(history);
    } catch (e, stackTrace) {
      return Left(CacheFailure(
        message: 'Не удалось загрузить историю: $e',
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Either<Failure, List<ExampleTaskEntity>>> getAllHistory({
    int limit = 500,
  }) async {
    try {
      final history = await _dataSource.getHistory(limit: limit);
      return Right(history);
    } catch (e, stackTrace) {
      return Left(CacheFailure(
        message: 'Не удалось загрузить всю историю: $e',
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getStatistics(
    int worldId,
  ) async {
    try {
      final historyResult = await getHistory(worldId, limit: 1000);

      return historyResult.fold(
        (failure) => Left(failure),
        (history) {
          if (history.isEmpty) {
            return Right({
              'total': 0,
              'correct': 0,
              'wrong': 0,
              'accuracy': 0.0,
              'averageTime': 0.0,
            });
          }

          final answered = history.where((t) => t.isCorrect != null).toList();
          final correct = answered.where((t) => t.isCorrect == true).length;
          final wrong = answered.where((t) => t.isCorrect == false).length;

          final accuracy =
              answered.isNotEmpty ? correct / answered.length : 0.0;

          final timeTasks = answered.where((t) => t.timeSpent != null).toList();
          final averageTime = timeTasks.isNotEmpty
              ? timeTasks.fold<double>(
                      0, (sum, t) => sum + t.timeSpent!.inMilliseconds) /
                  timeTasks.length /
                  1000
              : 0.0;

          return Right({
            'total': history.length,
            'correct': correct,
            'wrong': wrong,
            'accuracy': accuracy,
            'averageTime': averageTime,
          });
        },
      );
    } catch (e, stackTrace) {
      return Left(CacheFailure(
        message: 'Не удалось получить статистику: $e',
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getTotalStatistics() async {
    try {
      final historyResult = await getAllHistory(limit: 5000);

      return historyResult.fold(
        (failure) => Left(failure),
        (history) {
          if (history.isEmpty) {
            return Right({
              'total': 0,
              'correct': 0,
              'wrong': 0,
              'accuracy': 0.0,
              'averageTime': 0.0,
              'byWorld': <int, Map<String, dynamic>>{},
            });
          }

          final answered = history.where((t) => t.isCorrect != null).toList();
          final correct = answered.where((t) => t.isCorrect == true).length;
          final wrong = answered.where((t) => t.isCorrect == false).length;

          final accuracy =
              answered.isNotEmpty ? correct / answered.length : 0.0;

          final timeTasks = answered.where((t) => t.timeSpent != null).toList();
          final averageTime = timeTasks.isNotEmpty
              ? timeTasks.fold<double>(
                      0, (sum, t) => sum + t.timeSpent!.inMilliseconds) /
                  timeTasks.length /
                  1000
              : 0.0;

          // Статистика по мирам
          final byWorld = <int, Map<String, dynamic>>{};
          for (var worldId = 0;
              worldId < WorldConstants.totalWorlds;
              worldId++) {
            final worldTasks =
                answered.where((t) => t.multiplier == worldId).toList();
            if (worldTasks.isNotEmpty) {
              final worldCorrect =
                  worldTasks.where((t) => t.isCorrect == true).length;
              byWorld[worldId] = {
                'total': worldTasks.length,
                'correct': worldCorrect,
                'accuracy': worldCorrect / worldTasks.length,
              };
            }
          }

          return Right({
            'total': history.length,
            'correct': correct,
            'wrong': wrong,
            'accuracy': accuracy,
            'averageTime': averageTime,
            'byWorld': byWorld,
          });
        },
      );
    } catch (e, stackTrace) {
      return Left(CacheFailure(
        message: 'Не удалось получить общую статистику: $e',
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Either<Failure, List<ExampleTaskEntity>>> getHardestExamples({
    int? worldId,
    int limit = 10,
  }) async {
    try {
      final historyResult = worldId != null
          ? await getHistory(worldId, limit: 1000)
          : await getAllHistory(limit: 5000);

      return historyResult.fold(
        (failure) => Left(failure),
        (history) {
          // Группируем по примеру (multiplicand × multiplier)
          final errorCounts = <String, int>{};
          final examples = <String, ExampleTaskEntity>{};

          for (final task in history) {
            if (task.isCorrect == false) {
              final key = '${task.multiplicand}x${task.multiplier}';
              errorCounts[key] = (errorCounts[key] ?? 0) + 1;
              examples[key] = task;
            }
          }

          // Сортируем по количеству ошибок
          final sorted = errorCounts.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          // Возвращаем топ сложных
          final hardest = sorted
              .take(limit)
              .map((e) => examples[e.key]!)
              .toList();

          return Right(hardest);
        },
      );
    } catch (e, stackTrace) {
      return Left(CacheFailure(
        message: 'Не удалось получить сложные примеры: $e',
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Either<Failure, ExampleTaskEntity> checkAnswer(
    ExampleTaskEntity task,
    int answer,
  ) {
    try {
      if (answer < 0) {
        return Left(ValidationFailure.invalidAnswer(answer));
      }

      final isCorrect = answer == task.correctAnswer;

      final updated = task.copyWith(
        userAnswer: answer,
        isCorrect: isCorrect,
      );

      return Right(updated);
    } catch (e, stackTrace) {
      return Left(ValidationFailure(
        message: 'Не удалось проверить ответ: $e',
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Either<Failure, Unit>> clearHistory({int? worldId}) async {
    try {
      final success = await _dataSource.clearHistory(worldId: worldId);

      if (success) {
        return const Right(unit);
      }

      return Left(CacheFailure.writeError('history'));
    } catch (e, stackTrace) {
      return Left(CacheFailure(
        message: 'Не удалось очистить историю: $e',
        stackTrace: stackTrace,
      ));
    }
  }
}
