/// Use Case: Сохранение прогресса игрока
///
/// Сохраняет данные игрока и миров в хранилище.
library;

import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/player_entity.dart';
import '../entities/world_entity.dart';
import '../repositories/player_repository.dart';
import '../repositories/world_repository.dart';

/// Use Case для сохранения прогресса игрока
///
/// Пример использования:
/// ```dart
/// final useCase = SaveProgressUseCase(playerRepo, worldRepo);
/// final result = await useCase(player);
/// result.fold(
///   (failure) => print('Error: ${failure.message}'),
///   (_) => print('Progress saved!'),
/// );
/// ```
class SaveProgressUseCase {
  final PlayerRepository _playerRepository;
  final WorldRepository _worldRepository;

  const SaveProgressUseCase(
    this._playerRepository,
    this._worldRepository,
  );

  /// Сохраняет данные игрока
  ///
  /// Параметры:
  /// - [player] — сущность игрока для сохранения
  ///
  /// Возвращает:
  /// - [Right]<[Unit]> — успешное сохранение
  /// - [Left]<[CacheFailure]> — ошибка записи
  Future<Either<Failure, Unit>> call(PlayerEntity player) {
    return _playerRepository.savePlayer(player);
  }

  /// Сохраняет данные игрока и мира
  Future<Either<Failure, Unit>> savePlayerAndWorld(
    PlayerEntity player,
    WorldEntity world,
  ) async {
    // Сохраняем игрока
    final playerResult = await _playerRepository.savePlayer(player);

    return playerResult.fold(
      (failure) => Left(failure),
      (_) async {
        // Сохраняем мир
        return _worldRepository.saveWorld(world);
      },
    );
  }
}

/// Use Case для сохранения только данных игрока
class SavePlayerUseCase {
  final PlayerRepository _repository;

  const SavePlayerUseCase(this._repository);

  /// Сохраняет игрока
  Future<Either<Failure, Unit>> call(PlayerEntity player) {
    return _repository.savePlayer(player);
  }
}

/// Use Case для сохранения мира
class SaveWorldUseCase {
  final WorldRepository _repository;

  const SaveWorldUseCase(this._repository);

  /// Сохраняет мир
  Future<Either<Failure, Unit>> call(WorldEntity world) {
    return _repository.saveWorld(world);
  }
}

/// Use Case для обновления счёта
class UpdateScoreUseCase {
  final PlayerRepository _repository;

  const UpdateScoreUseCase(this._repository);

  /// Добавляет очки к текущему счёту
  Future<Either<Failure, PlayerEntity>> call(int points) {
    return _repository.addScore(points);
  }
}

/// Use Case для обновления жизней
class UpdateLivesUseCase {
  final PlayerRepository _repository;

  const UpdateLivesUseCase(this._repository);

  /// Уменьшает жизни на 1
  Future<Either<Failure, PlayerEntity>> loseLife() {
    return _repository.loseLife();
  }

  /// Увеличивает жизни на 1
  Future<Either<Failure, PlayerEntity>> gainLife() {
    return _repository.gainLife();
  }

  /// Устанавливает конкретное количество жизней
  Future<Either<Failure, PlayerEntity>> setLives(int lives) {
    return _repository.updateLives(lives);
  }
}

/// Use Case для сброса прогресса
class ResetProgressUseCase {
  final PlayerRepository _playerRepository;
  final WorldRepository _worldRepository;

  const ResetProgressUseCase(
    this._playerRepository,
    this._worldRepository,
  );

  /// Полностью сбрасывает прогресс игры
  ///
  /// Возвращает:
  /// - [Right]<[PlayerEntity]> — новый игрок с начальными значениями
  /// - [Left]<[Failure]> — ошибка сброса
  Future<Either<Failure, PlayerEntity>> call() async {
    // Сбрасываем миры
    final worldsResult = await _worldRepository.resetAllWorlds();

    return worldsResult.fold(
      (failure) => Left(failure),
      (_) async {
        // Сбрасываем игрока
        return _playerRepository.resetProgress();
      },
    );
  }
}
