/// Абстрактный репозиторий игрока
///
/// Определяет контракт для работы с данными игрока.
/// Реализация находится в data layer.
library;

import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/player_entity.dart';

/// Репозиторий для управления данными игрока
///
/// Все методы возвращают [Either] для безопасной обработки ошибок:
/// - Left([Failure]) — ошибка
/// - Right(T) — успешный результат
abstract class PlayerRepository {
  /// Получает данные текущего игрока
  ///
  /// Возвращает:
  /// - [Right]<[PlayerEntity]> — данные игрока
  /// - [Left]<[CacheFailure]> — если данные не найдены или повреждены
  Future<Either<Failure, PlayerEntity>> getPlayer();

  /// Сохраняет данные игрока
  ///
  /// Параметры:
  /// - [player] — сущность игрока для сохранения
  ///
  /// Возвращает:
  /// - [Right]<[Unit]> — успешное сохранение
  /// - [Left]<[CacheFailure]> — ошибка записи
  Future<Either<Failure, Unit>> savePlayer(PlayerEntity player);

  /// Обновляет счёт игрока
  ///
  /// Параметры:
  /// - [score] — новое значение счёта
  ///
  /// Возвращает:
  /// - [Right]<[PlayerEntity]> — обновлённый игрок
  /// - [Left]<[Failure]> — ошибка обновления
  Future<Either<Failure, PlayerEntity>> updateScore(int score);

  /// Добавляет очки к текущему счёту
  ///
  /// Параметры:
  /// - [points] — количество очков для добавления
  ///
  /// Возвращает:
  /// - [Right]<[PlayerEntity]> — обновлённый игрок
  /// - [Left]<[Failure]> — ошибка обновления
  Future<Either<Failure, PlayerEntity>> addScore(int points);

  /// Обновляет количество жизней
  ///
  /// Параметры:
  /// - [lives] — новое количество жизней
  ///
  /// Возвращает:
  /// - [Right]<[PlayerEntity]> — обновлённый игрок
  /// - [Left]<[ValidationFailure]> — если lives < 0 или > maxLives
  Future<Either<Failure, PlayerEntity>> updateLives(int lives);

  /// Уменьшает количество жизней на 1
  ///
  /// Возвращает:
  /// - [Right]<[PlayerEntity]> — обновлённый игрок
  /// - [Left]<[GameFailure]> — если жизней уже 0
  Future<Either<Failure, PlayerEntity>> loseLife();

  /// Восстанавливает одну жизнь
  ///
  /// Возвращает:
  /// - [Right]<[PlayerEntity]> — обновлённый игрок
  /// - [Left]<[Failure]> — если жизни уже полные
  Future<Either<Failure, PlayerEntity>> gainLife();

  /// Разблокирует указанный мир
  ///
  /// Параметры:
  /// - [worldId] — ID мира для разблокировки (0-9)
  ///
  /// Возвращает:
  /// - [Right]<[PlayerEntity]> — обновлённый игрок с разблокированным миром
  /// - [Left]<[ValidationFailure]> — если worldId вне диапазона
  Future<Either<Failure, PlayerEntity>> unlockWorld(int worldId);

  /// Устанавливает текущий мир
  ///
  /// Параметры:
  /// - [worldId] — ID мира
  ///
  /// Возвращает:
  /// - [Right]<[PlayerEntity]> — обновлённый игрок
  /// - [Left]<[GameFailure]> — если мир заблокирован
  Future<Either<Failure, PlayerEntity>> setCurrentWorld(int worldId);

  /// Обновляет комбо
  ///
  /// Параметры:
  /// - [combo] — новое значение комбо
  Future<Either<Failure, PlayerEntity>> updateCombo(int combo);

  /// Сбрасывает комбо до 0
  Future<Either<Failure, PlayerEntity>> resetCombo();

  /// Увеличивает комбо на 1
  Future<Either<Failure, PlayerEntity>> incrementCombo();

  /// Сбрасывает прогресс игрока до начального состояния
  ///
  /// Возвращает:
  /// - [Right]<[PlayerEntity]> — новый игрок с начальными значениями
  Future<Either<Failure, PlayerEntity>> resetProgress();

  /// Проверяет, существуют ли сохранённые данные
  Future<bool> hasExistingData();
}
