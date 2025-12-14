/// Абстрактный репозиторий миров
///
/// Определяет контракт для работы с данными миров.
/// Реализация находится в data layer.
library;

import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/world_entity.dart';

/// Репозиторий для управления данными миров
///
/// Все методы возвращают [Either] для безопасной обработки ошибок:
/// - Left([Failure]) — ошибка
/// - Right(T) — успешный результат
abstract class WorldRepository {
  /// Получает список всех миров
  ///
  /// Возвращает:
  /// - [Right]<[List]<[WorldEntity]>> — список из 10 миров
  /// - [Left]<[CacheFailure]> — ошибка чтения данных
  Future<Either<Failure, List<WorldEntity>>> getAllWorlds();

  /// Получает данные конкретного мира
  ///
  /// Параметры:
  /// - [id] — ID мира (0-9)
  ///
  /// Возвращает:
  /// - [Right]<[WorldEntity]> — данные мира
  /// - [Left]<[ValidationFailure]> — если id вне диапазона
  /// - [Left]<[CacheFailure]> — ошибка чтения
  Future<Either<Failure, WorldEntity>> getWorld(int id);

  /// Отмечает мир как пройденный
  ///
  /// Параметры:
  /// - [worldId] — ID мира
  /// - [score] — набранный счёт
  ///
  /// Возвращает:
  /// - [Right]<[WorldEntity]> — обновлённый мир
  /// - [Left]<[Failure]> — ошибка обновления
  Future<Either<Failure, WorldEntity>> completeWorld(int worldId, int score);

  /// Отмечает босса как побеждённого
  ///
  /// Параметры:
  /// - [worldId] — ID мира с боссом
  ///
  /// Возвращает:
  /// - [Right]<[WorldEntity]> — обновлённый мир
  /// - [Left]<[Failure]> — ошибка обновления
  Future<Either<Failure, WorldEntity>> defeatBoss(int worldId);

  /// Разблокирует мир
  ///
  /// Параметры:
  /// - [worldId] — ID мира для разблокировки
  ///
  /// Возвращает:
  /// - [Right]<[WorldEntity]> — разблокированный мир
  /// - [Left]<[ValidationFailure]> — если worldId вне диапазона
  Future<Either<Failure, WorldEntity>> unlockWorld(int worldId);

  /// Обновляет лучший счёт мира
  ///
  /// Обновляет только если новый счёт выше текущего лучшего.
  ///
  /// Параметры:
  /// - [worldId] — ID мира
  /// - [score] — новый счёт
  ///
  /// Возвращает:
  /// - [Right]<[WorldEntity]> — обновлённый мир
  /// - [Left]<[Failure]> — ошибка обновления
  Future<Either<Failure, WorldEntity>> updateBestScore(int worldId, int score);

  /// Устанавливает количество звёзд для мира
  ///
  /// Параметры:
  /// - [worldId] — ID мира
  /// - [stars] — количество звёзд (0-3)
  ///
  /// Возвращает:
  /// - [Right]<[WorldEntity]> — обновлённый мир
  /// - [Left]<[ValidationFailure]> — если stars вне диапазона
  Future<Either<Failure, WorldEntity>> setStars(int worldId, int stars);

  /// Получает следующий заблокированный мир
  ///
  /// Возвращает:
  /// - [Right]<[WorldEntity]> — первый заблокированный мир
  /// - [Left]<[GameFailure]> — если все миры разблокированы
  Future<Either<Failure, WorldEntity>> getNextLockedWorld();

  /// Получает список разблокированных миров
  Future<Either<Failure, List<WorldEntity>>> getUnlockedWorlds();

  /// Получает список пройденных миров
  Future<Either<Failure, List<WorldEntity>>> getCompletedWorlds();

  /// Получает общий прогресс по всем мирам (0.0 - 1.0)
  Future<Either<Failure, double>> getTotalProgress();

  /// Получает общее количество звёзд
  Future<Either<Failure, int>> getTotalStars();

  /// Сбрасывает прогресс всех миров
  ///
  /// Оставляет только первый мир разблокированным.
  Future<Either<Failure, List<WorldEntity>>> resetAllWorlds();

  /// Сохраняет мир
  ///
  /// Параметры:
  /// - [world] — сущность мира для сохранения
  Future<Either<Failure, Unit>> saveWorld(WorldEntity world);

  /// Инициализирует миры при первом запуске
  ///
  /// Создаёт все 10 миров с начальными данными.
  Future<Either<Failure, List<WorldEntity>>> initializeWorlds();
}
