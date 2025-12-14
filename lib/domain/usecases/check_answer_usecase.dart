/// Use Case: Проверка ответа на пример
///
/// Проверяет ответ пользователя и обновляет состояние примера.
library;

import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/example_task_entity.dart';
import '../repositories/example_repository.dart';

/// Параметры для проверки ответа
class CheckAnswerParams {
  /// Пример для проверки
  final ExampleTaskEntity task;

  /// Ответ пользователя
  final int userAnswer;

  /// Время, потраченное на ответ
  final Duration timeSpent;

  const CheckAnswerParams({
    required this.task,
    required this.userAnswer,
    required this.timeSpent,
  });
}

/// Результат проверки ответа
class CheckAnswerResult {
  /// Обновлённый пример с ответом
  final ExampleTaskEntity task;

  /// Правильный ли ответ
  final bool isCorrect;

  /// Было ли это быстрым ответом (< 5 сек)
  final bool isFastAnswer;

  const CheckAnswerResult({
    required this.task,
    required this.isCorrect,
    required this.isFastAnswer,
  });
}

/// Use Case для проверки ответа на математический пример
///
/// Пример использования:
/// ```dart
/// final useCase = CheckAnswerUseCase(repository);
/// final result = await useCase(CheckAnswerParams(
///   task: currentTask,
///   userAnswer: 12,
///   timeSpent: Duration(seconds: 3),
/// ));
/// result.fold(
///   (failure) => print('Error: ${failure.message}'),
///   (result) => print('Correct: ${result.isCorrect}'),
/// );
/// ```
class CheckAnswerUseCase {
  final ExampleRepository _repository;

  /// Порог быстрого ответа в секундах
  static const int fastAnswerThreshold = 5;

  const CheckAnswerUseCase(this._repository);

  /// Проверяет ответ пользователя
  ///
  /// Параметры:
  /// - [params] — параметры проверки
  ///
  /// Возвращает:
  /// - [Right]<[CheckAnswerResult]> — результат проверки
  /// - [Left]<[ValidationFailure]> — если ответ отрицательный
  Future<Either<Failure, CheckAnswerResult>> call(
    CheckAnswerParams params,
  ) async {
    // Валидация ответа
    if (params.userAnswer < 0) {
      return Left(ValidationFailure.invalidAnswer(params.userAnswer));
    }

    // Проверяем ответ
    final checkResult = _repository.checkAnswer(
      params.task,
      params.userAnswer,
    );

    return checkResult.fold(
      (failure) => Left(failure),
      (checkedTask) async {
        // Обновляем задачу с временем
        final updatedTask = checkedTask.copyWith(
          timeSpent: params.timeSpent,
        );

        // Сохраняем результат в историю
        await _repository.saveResult(updatedTask);

        // Определяем, был ли ответ быстрым
        final isFastAnswer =
            params.timeSpent.inSeconds < fastAnswerThreshold;

        return Right(CheckAnswerResult(
          task: updatedTask,
          isCorrect: updatedTask.isCorrect ?? false,
          isFastAnswer: isFastAnswer && (updatedTask.isCorrect ?? false),
        ));
      },
    );
  }
}

/// Use Case для проверки ответа без сохранения (для тренировки)
class CheckAnswerQuickUseCase {
  const CheckAnswerQuickUseCase();

  /// Быстрая проверка ответа без сохранения в историю
  ///
  /// Чистая функция, не взаимодействует с репозиторием.
  Either<Failure, bool> call({
    required ExampleTaskEntity task,
    required int userAnswer,
  }) {
    if (userAnswer < 0) {
      return Left(ValidationFailure.invalidAnswer(userAnswer));
    }

    return Right(userAnswer == task.correctAnswer);
  }
}
