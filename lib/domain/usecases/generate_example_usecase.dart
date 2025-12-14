/// Use Case: Генерация математического примера
///
/// Генерирует пример умножения для указанного мира и сложности.
library;

import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/example_task_entity.dart';
import '../repositories/example_repository.dart';

/// Параметры для генерации примера
class GenerateExampleParams {
  /// Множитель (номер мира, 0-9)
  final int multiplier;

  /// Уровень сложности (1-5)
  final int difficulty;

  /// Примеры для исключения (чтобы избежать повторов)
  final List<ExampleTaskEntity> exclude;

  const GenerateExampleParams({
    required this.multiplier,
    this.difficulty = 1,
    this.exclude = const [],
  });
}

/// Use Case для генерации математического примера
///
/// Пример использования:
/// ```dart
/// final useCase = GenerateExampleUseCase(repository);
/// final result = await useCase(GenerateExampleParams(multiplier: 3));
/// result.fold(
///   (failure) => print('Error: ${failure.message}'),
///   (task) => print('Task: ${task.formattedQuestion}'),
/// );
/// ```
class GenerateExampleUseCase {
  final ExampleRepository _repository;

  const GenerateExampleUseCase(this._repository);

  /// Генерирует пример умножения
  ///
  /// Параметры:
  /// - [params] — параметры генерации
  ///
  /// Возвращает:
  /// - [Right]<[ExampleTaskEntity]> — сгенерированный пример
  /// - [Left]<[ValidationFailure]> — если multiplier вне диапазона 0-9
  Future<Either<Failure, ExampleTaskEntity>> call(
    GenerateExampleParams params,
  ) async {
    // Валидация множителя
    if (params.multiplier < 0 || params.multiplier > 9) {
      return Left(ValidationFailure.invalidMultiplier(params.multiplier));
    }

    // Валидация сложности
    if (params.difficulty < 1 || params.difficulty > 5) {
      return Left(ValidationFailure.outOfRange(
        field: 'difficulty',
        value: params.difficulty,
        min: 1,
        max: 5,
      ));
    }

    // Генерация уникального примера, если есть исключения
    if (params.exclude.isNotEmpty) {
      return _repository.generateUniqueExample(
        params.multiplier,
        params.difficulty,
        params.exclude,
      );
    }

    // Обычная генерация
    return _repository.generateExample(
      params.multiplier,
      params.difficulty,
    );
  }
}

/// Use Case для генерации пакета примеров
class GenerateExampleBatchUseCase {
  final ExampleRepository _repository;

  const GenerateExampleBatchUseCase(this._repository);

  /// Генерирует пакет примеров
  ///
  /// Параметры:
  /// - [multiplier] — множитель (0-9)
  /// - [count] — количество примеров
  /// - [difficulty] — уровень сложности
  Future<Either<Failure, List<ExampleTaskEntity>>> call({
    required int multiplier,
    required int count,
    int difficulty = 1,
  }) async {
    if (multiplier < 0 || multiplier > 9) {
      return Left(ValidationFailure.invalidMultiplier(multiplier));
    }

    if (count <= 0) {
      return Left(ValidationFailure.outOfRange(
        field: 'count',
        value: count,
        min: 1,
        max: 100,
      ));
    }

    return _repository.generateExampleBatch(
      multiplier,
      count,
      difficulty: difficulty,
    );
  }
}
