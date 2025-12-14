/// Абстрактный репозиторий математических примеров
///
/// Определяет контракт для генерации и хранения примеров.
/// Реализация находится в data layer.
library;

import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/example_task_entity.dart';

/// Репозиторий для управления математическими примерами
///
/// Все методы возвращают [Either] для безопасной обработки ошибок:
/// - Left([Failure]) — ошибка
/// - Right(T) — успешный результат
abstract class ExampleRepository {
  /// Генерирует один пример для указанного множителя
  ///
  /// Параметры:
  /// - [multiplier] — множитель (номер мира, 0-9)
  /// - [difficulty] — уровень сложности (1-5)
  ///
  /// Возвращает:
  /// - [Right]<[ExampleTaskEntity]> — сгенерированный пример
  /// - [Left]<[ValidationFailure]> — если multiplier вне диапазона
  Future<Either<Failure, ExampleTaskEntity>> generateExample(
    int multiplier,
    int difficulty,
  );

  /// Генерирует пакет примеров
  ///
  /// Параметры:
  /// - [multiplier] — множитель (номер мира)
  /// - [count] — количество примеров
  /// - [difficulty] — уровень сложности
  ///
  /// Возвращает:
  /// - [Right]<[List]<[ExampleTaskEntity]>> — список примеров
  /// - [Left]<[ValidationFailure]> — если параметры некорректны
  Future<Either<Failure, List<ExampleTaskEntity>>> generateExampleBatch(
    int multiplier,
    int count, {
    int difficulty = 1,
  });

  /// Генерирует пример без повторений из указанного списка
  ///
  /// Параметры:
  /// - [multiplier] — множитель
  /// - [difficulty] — сложность
  /// - [exclude] — список примеров, которые нужно исключить
  ///
  /// Возвращает уникальный пример, не входящий в exclude.
  Future<Either<Failure, ExampleTaskEntity>> generateUniqueExample(
    int multiplier,
    int difficulty,
    List<ExampleTaskEntity> exclude,
  );

  /// Сохраняет результат выполнения примера
  ///
  /// Параметры:
  /// - [task] — выполненный пример с ответом пользователя
  ///
  /// Возвращает:
  /// - [Right]<[Unit]> — успешное сохранение
  /// - [Left]<[CacheFailure]> — ошибка записи
  Future<Either<Failure, Unit>> saveResult(ExampleTaskEntity task);

  /// Сохраняет результаты пакета примеров
  ///
  /// Параметры:
  /// - [tasks] — список выполненных примеров
  Future<Either<Failure, Unit>> saveResultBatch(List<ExampleTaskEntity> tasks);

  /// Получает историю примеров для указанного мира
  ///
  /// Параметры:
  /// - [worldId] — ID мира (0-9)
  /// - [limit] — максимальное количество записей (по умолчанию 100)
  ///
  /// Возвращает:
  /// - [Right]<[List]<[ExampleTaskEntity]>> — история примеров
  /// - [Left]<[CacheFailure]> — ошибка чтения
  Future<Either<Failure, List<ExampleTaskEntity>>> getHistory(
    int worldId, {
    int limit = 100,
  });

  /// Получает всю историю примеров
  ///
  /// Параметры:
  /// - [limit] — максимальное количество записей
  Future<Either<Failure, List<ExampleTaskEntity>>> getAllHistory({
    int limit = 500,
  });

  /// Получает статистику по примерам для мира
  ///
  /// Возвращает Map с ключами:
  /// - 'total' — всего примеров
  /// - 'correct' — правильных ответов
  /// - 'wrong' — неправильных ответов
  /// - 'accuracy' — процент правильных (double)
  /// - 'averageTime' — среднее время ответа в секундах (double)
  Future<Either<Failure, Map<String, dynamic>>> getStatistics(int worldId);

  /// Получает общую статистику по всем мирам
  Future<Either<Failure, Map<String, dynamic>>> getTotalStatistics();

  /// Получает самые сложные примеры (с наибольшим количеством ошибок)
  ///
  /// Параметры:
  /// - [worldId] — ID мира (null для всех миров)
  /// - [limit] — количество примеров
  Future<Either<Failure, List<ExampleTaskEntity>>> getHardestExamples({
    int? worldId,
    int limit = 10,
  });

  /// Проверяет ответ на пример
  ///
  /// Параметры:
  /// - [task] — пример
  /// - [answer] — ответ пользователя
  ///
  /// Возвращает обновлённый пример с установленным isCorrect.
  Either<Failure, ExampleTaskEntity> checkAnswer(
    ExampleTaskEntity task,
    int answer,
  );

  /// Очищает историю примеров
  ///
  /// Параметры:
  /// - [worldId] — ID мира (null для очистки всей истории)
  Future<Either<Failure, Unit>> clearHistory({int? worldId});
}
