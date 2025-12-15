/// Реализация репозитория игрока
///
/// Использует [LocalDataSource] для хранения данных.
library;

import 'package:dartz/dartz.dart';

import '../../core/config/game_constants.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/player_entity.dart';
import '../../domain/repositories/player_repository.dart';
import '../datasources/local_datasource.dart';
import '../models/player_model.dart';

/// Реализация репозитория игрока
class PlayerRepositoryImpl implements PlayerRepository {
  final LocalDataSource _dataSource;

  /// Кэш текущего игрока для быстрого доступа
  PlayerModel? _cachedPlayer;

  PlayerRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, PlayerEntity>> getPlayer() async {
    try {
      // Проверяем кэш
      if (_cachedPlayer != null) {
        return Right(_cachedPlayer!);
      }

      // Загружаем из хранилища
      final player = await _dataSource.getPlayer();

      if (player != null) {
        _cachedPlayer = player;
        return Right(player);
      }

      // Если игрока нет, создаём нового
      final newPlayer = PlayerModel.empty();
      await _dataSource.savePlayer(newPlayer);
      _cachedPlayer = newPlayer;
      return Right(newPlayer);
    } catch (e, stackTrace) {
      return Left(CacheFailure(
        message: 'Не удалось загрузить данные игрока: $e',
        stackTrace: stackTrace,
        key: StorageKeys.playerData,
      ));
    }
  }

  @override
  Future<Either<Failure, Unit>> savePlayer(PlayerEntity player) async {
    try {
      final model = PlayerModel.fromEntity(player);
      final success = await _dataSource.savePlayer(model);

      if (success) {
        _cachedPlayer = model;
        return const Right(unit);
      }

      return Left(CacheFailure.writeError(StorageKeys.playerData));
    } catch (e, stackTrace) {
      return Left(CacheFailure(
        message: 'Не удалось сохранить данные игрока: $e',
        stackTrace: stackTrace,
        key: StorageKeys.playerData,
      ));
    }
  }

  @override
  Future<Either<Failure, PlayerEntity>> updateScore(int score) async {
    try {
      final playerResult = await getPlayer();

      return playerResult.fold(
        (failure) => Left(failure),
        (player) async {
          final updated = player.copyWith(score: score);
          final saveResult = await savePlayer(updated);

          return saveResult.fold(
            (failure) => Left(failure),
            (_) => Right(updated),
          );
        },
      );
    } catch (e, stackTrace) {
      return Left(CacheFailure(
        message: 'Не удалось обновить счёт: $e',
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Either<Failure, PlayerEntity>> addScore(int points) async {
    try {
      final playerResult = await getPlayer();

      return playerResult.fold(
        (failure) => Left(failure),
        (player) async {
          final newScore = player.score + points;
          final updated = player.copyWith(score: newScore);
          final saveResult = await savePlayer(updated);

          return saveResult.fold(
            (failure) => Left(failure),
            (_) => Right(updated),
          );
        },
      );
    } catch (e, stackTrace) {
      return Left(CacheFailure(
        message: 'Не удалось добавить очки: $e',
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Either<Failure, PlayerEntity>> updateLives(int lives) async {
    try {
      // Валидация
      if (lives < 0 || lives > PlayerConstants.maxLives) {
        return Left(ValidationFailure.outOfRange(
          field: 'lives',
          value: lives,
          min: 0,
          max: PlayerConstants.maxLives,
        ));
      }

      final playerResult = await getPlayer();

      return playerResult.fold(
        (failure) => Left(failure),
        (player) async {
          final updated = player.copyWith(lives: lives);
          final saveResult = await savePlayer(updated);

          return saveResult.fold(
            (failure) => Left(failure),
            (_) => Right(updated),
          );
        },
      );
    } catch (e, stackTrace) {
      return Left(CacheFailure(
        message: 'Не удалось обновить жизни: $e',
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Either<Failure, PlayerEntity>> loseLife() async {
    try {
      final playerResult = await getPlayer();

      return playerResult.fold(
        (failure) => Left(failure),
        (player) async {
          if (player.lives <= 0) {
            return Left(GameFailure.noLivesLeft());
          }

          final updated = player.copyWith(lives: player.lives - 1);
          final saveResult = await savePlayer(updated);

          return saveResult.fold(
            (failure) => Left(failure),
            (_) => Right(updated),
          );
        },
      );
    } catch (e, stackTrace) {
      return Left(CacheFailure(
        message: 'Не удалось уменьшить жизни: $e',
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Either<Failure, PlayerEntity>> gainLife() async {
    try {
      final playerResult = await getPlayer();

      return playerResult.fold(
        (failure) => Left(failure),
        (player) async {
          if (player.lives >= player.maxLives) {
            // Жизни уже полные, просто возвращаем игрока
            return Right(player);
          }

          final updated = player.copyWith(lives: player.lives + 1);
          final saveResult = await savePlayer(updated);

          return saveResult.fold(
            (failure) => Left(failure),
            (_) => Right(updated),
          );
        },
      );
    } catch (e, stackTrace) {
      return Left(CacheFailure(
        message: 'Не удалось восстановить жизнь: $e',
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Either<Failure, PlayerEntity>> unlockWorld(int worldId) async {
    try {
      // Валидация
      if (worldId < 0 || worldId >= WorldConstants.totalWorlds) {
        return Left(ValidationFailure.outOfRange(
          field: 'worldId',
          value: worldId,
          min: 0,
          max: WorldConstants.totalWorlds - 1,
        ));
      }

      final playerResult = await getPlayer();

      return playerResult.fold(
        (failure) => Left(failure),
        (player) async {
          // Проверяем, не разблокирован ли уже
          if (player.unlockedWorlds.contains(worldId)) {
            return Right(player);
          }

          final newUnlocked = [...player.unlockedWorlds, worldId]..sort();
          final updated = player.copyWith(unlockedWorlds: newUnlocked);
          final saveResult = await savePlayer(updated);

          return saveResult.fold(
            (failure) => Left(failure),
            (_) => Right(updated),
          );
        },
      );
    } catch (e, stackTrace) {
      return Left(CacheFailure(
        message: 'Не удалось разблокировать мир: $e',
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Either<Failure, PlayerEntity>> setCurrentWorld(int worldId) async {
    try {
      // Валидация
      if (worldId < 0 || worldId >= WorldConstants.totalWorlds) {
        return Left(ValidationFailure.outOfRange(
          field: 'worldId',
          value: worldId,
          min: 0,
          max: WorldConstants.totalWorlds - 1,
        ));
      }

      final playerResult = await getPlayer();

      return playerResult.fold(
        (failure) => Left(failure),
        (player) async {
          // Проверяем, разблокирован ли мир
          if (!player.unlockedWorlds.contains(worldId)) {
            return Left(GameFailure.worldLocked(worldId));
          }

          final updated = player.copyWith(currentWorld: worldId);
          final saveResult = await savePlayer(updated);

          return saveResult.fold(
            (failure) => Left(failure),
            (_) => Right(updated),
          );
        },
      );
    } catch (e, stackTrace) {
      return Left(CacheFailure(
        message: 'Не удалось установить текущий мир: $e',
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Either<Failure, PlayerEntity>> updateCombo(int combo) async {
    try {
      final playerResult = await getPlayer();

      return playerResult.fold(
        (failure) => Left(failure),
        (player) async {
          final updated = player.copyWith(combo: combo.clamp(0, 100));
          final saveResult = await savePlayer(updated);

          return saveResult.fold(
            (failure) => Left(failure),
            (_) => Right(updated),
          );
        },
      );
    } catch (e, stackTrace) {
      return Left(CacheFailure(
        message: 'Не удалось обновить комбо: $e',
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Either<Failure, PlayerEntity>> resetCombo() async {
    return updateCombo(0);
  }

  @override
  Future<Either<Failure, PlayerEntity>> incrementCombo() async {
    try {
      final playerResult = await getPlayer();

      return playerResult.fold(
        (failure) => Left(failure),
        (player) async {
          final updated = player.copyWith(combo: player.combo + 1);
          final saveResult = await savePlayer(updated);

          return saveResult.fold(
            (failure) => Left(failure),
            (_) => Right(updated),
          );
        },
      );
    } catch (e, stackTrace) {
      return Left(CacheFailure(
        message: 'Не удалось увеличить комбо: $e',
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Either<Failure, PlayerEntity>> resetProgress() async {
    try {
      final newPlayer = PlayerModel.empty();
      final success = await _dataSource.savePlayer(newPlayer);

      if (success) {
        _cachedPlayer = newPlayer;
        return Right(newPlayer);
      }

      return Left(CacheFailure.writeError(StorageKeys.playerData));
    } catch (e, stackTrace) {
      return Left(CacheFailure(
        message: 'Не удалось сбросить прогресс: $e',
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<bool> hasExistingData() async {
    return _dataSource.hasPlayer();
  }

  /// Очищает кэш (для тестирования)
  void clearCache() {
    _cachedPlayer = null;
  }
}
