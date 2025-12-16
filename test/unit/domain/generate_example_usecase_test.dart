/// Тесты для GenerateExampleUseCase
///
/// Проверяет генерацию математических примеров.
library;

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:math_shield/core/errors/failures.dart';
import 'package:math_shield/domain/entities/example_task_entity.dart';
import 'package:math_shield/domain/repositories/example_repository.dart';
import 'package:math_shield/domain/usecases/generate_example_usecase.dart';

/// Mock репозиторий для тестов
class MockExampleRepository implements ExampleRepository {
  int generateCallCount = 0;
  int? lastMultiplier;
  int? lastDifficulty;

  @override
  Future<Either<Failure, ExampleTaskEntity>> generateExample(
    int multiplier,
    int difficulty,
  ) async {
    generateCallCount++;
    lastMultiplier = multiplier;
    lastDifficulty = difficulty;

    // Возвращаем тестовый пример
    return Right(ExampleTaskEntity(
      firstOperand: 5,
      secondOperand: multiplier,
      operation: MathOperation.multiplication,
      correctAnswer: 5 * multiplier,
      difficulty: difficulty,
    ));
  }

  @override
  Future<Either<Failure, ExampleTaskEntity>> generateUniqueExample(
    int multiplier,
    int difficulty,
    List<ExampleTaskEntity> exclude,
  ) async {
    generateCallCount++;
    lastMultiplier = multiplier;
    lastDifficulty = difficulty;

    return Right(ExampleTaskEntity(
      firstOperand: 7,
      secondOperand: multiplier,
      operation: MathOperation.multiplication,
      correctAnswer: 7 * multiplier,
      difficulty: difficulty,
    ));
  }

  @override
  Future<Either<Failure, List<ExampleTaskEntity>>> generateExampleBatch(
    int multiplier,
    int count, {
    int difficulty = 1,
  }) async {
    final examples = List.generate(
      count,
      (i) => ExampleTaskEntity(
        firstOperand: i + 1,
        secondOperand: multiplier,
        operation: MathOperation.multiplication,
        correctAnswer: (i + 1) * multiplier,
        difficulty: difficulty,
      ),
    );
    return Right(examples);
  }

  @override
  Future<Either<Failure, ExampleTaskEntity>> getExampleById(String id) async {
    return Left(CacheFailure('Not found'));
  }

  @override
  Future<Either<Failure, void>> saveExample(ExampleTaskEntity example) async {
    return const Right(null);
  }
}

void main() {
  late GenerateExampleUseCase useCase;
  late MockExampleRepository mockRepository;

  setUp(() {
    mockRepository = MockExampleRepository();
    useCase = GenerateExampleUseCase(mockRepository);
  });

  group('GenerateExampleUseCase', () {
    test('должен генерировать пример для валидного множителя', () async {
      // Arrange
      const params = GenerateExampleParams(multiplier: 3, difficulty: 1);

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Не должно быть ошибки'),
        (task) {
          expect(task.secondOperand, 3);
          expect(task.correctAnswer, 15); // 5 * 3
        },
      );
      expect(mockRepository.generateCallCount, 1);
      expect(mockRepository.lastMultiplier, 3);
    });

    test('должен возвращать ошибку для multiplier < 0', () async {
      // Arrange
      const params = GenerateExampleParams(multiplier: -1);

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('-1'));
        },
        (task) => fail('Должна быть ошибка'),
      );
      expect(mockRepository.generateCallCount, 0);
    });

    test('должен возвращать ошибку для multiplier > 9', () async {
      // Arrange
      const params = GenerateExampleParams(multiplier: 10);

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (task) => fail('Должна быть ошибка'),
      );
    });

    test('должен возвращать ошибку для difficulty < 1', () async {
      // Arrange
      const params = GenerateExampleParams(multiplier: 3, difficulty: 0);

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
    });

    test('должен возвращать ошибку для difficulty > 5', () async {
      // Arrange
      const params = GenerateExampleParams(multiplier: 3, difficulty: 6);

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isLeft(), true);
    });

    test('должен вызывать generateUniqueExample при наличии exclude', () async {
      // Arrange
      final excludeList = [
        ExampleTaskEntity(
          firstOperand: 5,
          secondOperand: 3,
          operation: MathOperation.multiplication,
          correctAnswer: 15,
          difficulty: 1,
        ),
      ];
      final params = GenerateExampleParams(
        multiplier: 3,
        difficulty: 1,
        exclude: excludeList,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Не должно быть ошибки'),
        (task) {
          // generateUniqueExample возвращает firstOperand = 7
          expect(task.firstOperand, 7);
        },
      );
    });

    test('должен работать со всеми валидными множителями 0-9', () async {
      for (var multiplier = 0; multiplier <= 9; multiplier++) {
        final params = GenerateExampleParams(multiplier: multiplier);
        final result = await useCase(params);

        expect(result.isRight(), true, reason: 'Множитель $multiplier должен быть валидным');
      }
    });
  });

  group('GenerateExampleBatchUseCase', () {
    late GenerateExampleBatchUseCase batchUseCase;

    setUp(() {
      batchUseCase = GenerateExampleBatchUseCase(mockRepository);
    });

    test('должен генерировать пакет примеров', () async {
      // Act
      final result = await batchUseCase(multiplier: 5, count: 10);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Не должно быть ошибки'),
        (tasks) {
          expect(tasks.length, 10);
          for (final task in tasks) {
            expect(task.secondOperand, 5);
          }
        },
      );
    });

    test('должен возвращать ошибку для count <= 0', () async {
      // Act
      final result = await batchUseCase(multiplier: 5, count: 0);

      // Assert
      expect(result.isLeft(), true);
    });

    test('должен возвращать ошибку для невалидного множителя', () async {
      // Act
      final result = await batchUseCase(multiplier: 15, count: 10);

      // Assert
      expect(result.isLeft(), true);
    });
  });
}
