/// Реализация репозитория миров
///
/// Использует [LocalDataSource] для хранения данных.
library;

import 'package:dartz/dartz.dart';

import '../../core/config/game_constants.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/world_entity.dart';
import '../../domain/repositories/world_repository.dart';
import '../datasources/local_datasource.dart';
import '../models/world_model.dart';

/// Реализация репозитория миров
class WorldRepositoryImpl implements WorldRepository {
  final LocalDataSource _dataSource;

  /// Кэш миров для быстрого доступа
  List<WorldModel>? _cachedWorlds;

  WorldRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<WorldEntity>>> getAllWorlds() async {
    try {
      // Проверяем кэш
      if (_cachedWorlds != null) {
        return Right(_cachedWorlds!);
      }

      // Загружаем из хранилища
      var worlds = await _dataSource.getWorlds();

      if (worlds == null || worlds.isEmpty) {
        // Инициализируем миры при первом запуске
        worlds = WorldModel.createAllWorlds();
        await _dataSource.saveWorlds(worlds);
      }

      _cachedWorlds = worlds;
      return Right(worlds);
    } catch (e, stackTrace) {
      return Left(CacheFailure(
        message: 'Не удалось загрузить миры: $e',
        stackTrace: stackTrace,
        key: StorageKeys.worldsData,
      ));
    }
  }

  @override
  Future<Either<Failure, WorldEntity>> getWorld(int id) async {
    try {
      // Валидация
      if (id < 0 || id >= WorldConstants.totalWorlds) {
        return Left(ValidationFailure.outOfRange(
          field: 'worldId',
          value: id,
          min: 0,
          max: WorldConstants.totalWorlds - 1,
        ));
      }

      final worldsResult = await getAllWorlds();

      return worldsResult.fold(
        (failure) => Left(failure),
        (worlds) {
          final world = worlds.firstWhere(
            (w) => w.id == id,
            orElse: () => WorldModel.fromWorldData(id),
          );
          return Right(world);
        },
      );
    } catch (e, stackTrace) {
      return Left(CacheFailure(
        message: 'Не удалось загрузить мир $id: $e',
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Either<Failure, WorldEntity>> completeWorld(
    int worldId,
    int score,
  ) async {
    try {
      final worldResult = await getWorld(worldId);

      return worldResult.fold(
        (failure) => Left(failure),
        (world) async {
          // Обновляем лучший счёт, если новый выше
          final newBestScore =
              score > world.bestScore ? score : world.bestScore;

          // Рассчитываем звёзды
          final stars = _calculateStars(score, worldId);

          final updated = WorldModel.fromEntity(world).copyWith(
            isCompleted: true,
            bestScore: newBestScore,
            stars: stars > world.stars ? stars : world.stars,
          );

          final saveResult = await saveWorld(updated);

          return saveResult.fold(
            (failure) => Left(failure),
            (_) => Right(updated),
          );
        },
      );
    } catch (e, stackTrace) {
      return Left(CacheFailure(
        message: 'Не удалось завершить мир: $e',
        stackTrace: stackTrace,
      ));
    }
  }

  int _calculateStars(int score, int worldId) {
    // Максимальный счёт зависит от количества примеров и базовых очков
    final maxScore = WorldConstants.examplesPerLevel *
        ScoreConstants.correctAnswerBase *
        2; // с учётом бонусов

    final percentage = (score / maxScore * 100).round();

    if (percentage >= ScoreConstants.threeStarThreshold) return 3;
    if (percentage >= ScoreConstants.twoStarThreshold) return 2;
    if (percentage >= ScoreConstants.oneStarThreshold) return 1;
    return 0;
  }

  @override
  Future<Either<Failure, WorldEntity>> defeatBoss(int worldId) async {
    try {
      final worldResult = await getWorld(worldId);

      return worldResult.fold(
        (failure) => Left(failure),
        (world) async {
          final updated = WorldModel.fromEntity(world).copyWith(
            bossDefeated: true,
            isCompleted: true,
          );

          final saveResult = await saveWorld(updated);

          return saveResult.fold(
            (failure) => Left(failure),
            (_) => Right(updated),
          );
        },
      );
    } catch (e, stackTrace) {
      return Left(CacheFailure(
        message: 'Не удалось отметить победу над боссом: $e',
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Either<Failure, WorldEntity>> unlockWorld(int worldId) async {
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

      final worldResult = await getWorld(worldId);

      return worldResult.fold(
        (failure) => Left(failure),
        (world) async {
          if (world.isUnlocked) {
            return Right(world);
          }

          final updated = WorldModel.fromEntity(world).copyWith(
            isUnlocked: true,
          );

          final saveResult = await saveWorld(updated);

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
  Future<Either<Failure, WorldEntity>> updateBestScore(
    int worldId,
    int score,
  ) async {
    try {
      final worldResult = await getWorld(worldId);

      return worldResult.fold(
        (failure) => Left(failure),
        (world) async {
          if (score <= world.bestScore) {
            return Right(world);
          }

          final updated = WorldModel.fromEntity(world).copyWith(
            bestScore: score,
          );

          final saveResult = await saveWorld(updated);

          return saveResult.fold(
            (failure) => Left(failure),
            (_) => Right(updated),
          );
        },
      );
    } catch (e, stackTrace) {
      return Left(CacheFailure(
        message: 'Не удалось обновить лучший счёт: $e',
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Either<Failure, WorldEntity>> setStars(int worldId, int stars) async {
    try {
      // Валидация
      if (stars < 0 || stars > 3) {
        return Left(ValidationFailure.outOfRange(
          field: 'stars',
          value: stars,
          min: 0,
          max: 3,
        ));
      }

      final worldResult = await getWorld(worldId);

      return worldResult.fold(
        (failure) => Left(failure),
        (world) async {
          final updated = WorldModel.fromEntity(world).copyWith(
            stars: stars,
          );

          final saveResult = await saveWorld(updated);

          return saveResult.fold(
            (failure) => Left(failure),
            (_) => Right(updated),
          );
        },
      );
    } catch (e, stackTrace) {
      return Left(CacheFailure(
        message: 'Не удалось установить звёзды: $e',
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Either<Failure, WorldEntity>> getNextLockedWorld() async {
    try {
      final worldsResult = await getAllWorlds();

      return worldsResult.fold(
        (failure) => Left(failure),
        (worlds) {
          final lockedWorld = worlds.cast<WorldEntity?>().firstWhere(
                (w) => w != null && !w.isUnlocked,
                orElse: () => null,
              );

          if (lockedWorld == null) {
            return Left(GameFailure(
              message: 'Все миры уже разблокированы',
            ));
          }

          return Right(lockedWorld);
        },
      );
    } catch (e, stackTrace) {
      return Left(CacheFailure(
        message: 'Не удалось получить следующий мир: $e',
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Either<Failure, List<WorldEntity>>> getUnlockedWorlds() async {
    try {
      final worldsResult = await getAllWorlds();

      return worldsResult.fold(
        (failure) => Left(failure),
        (worlds) => Right(worlds.where((w) => w.isUnlocked).toList()),
      );
    } catch (e, stackTrace) {
      return Left(CacheFailure(
        message: 'Не удалось получить разблокированные миры: $e',
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Either<Failure, List<WorldEntity>>> getCompletedWorlds() async {
    try {
      final worldsResult = await getAllWorlds();

      return worldsResult.fold(
        (failure) => Left(failure),
        (worlds) => Right(worlds.where((w) => w.isCompleted).toList()),
      );
    } catch (e, stackTrace) {
      return Left(CacheFailure(
        message: 'Не удалось получить пройденные миры: $e',
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Either<Failure, double>> getTotalProgress() async {
    try {
      final worldsResult = await getAllWorlds();

      return worldsResult.fold(
        (failure) => Left(failure),
        (worlds) {
          if (worlds.isEmpty) return const Right(0.0);

          final totalCompletion = worlds.fold<double>(
            0.0,
            (sum, world) => sum + world.completionPercentage,
          );

          return Right(totalCompletion / worlds.length);
        },
      );
    } catch (e, stackTrace) {
      return Left(CacheFailure(
        message: 'Не удалось рассчитать прогресс: $e',
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Either<Failure, int>> getTotalStars() async {
    try {
      final worldsResult = await getAllWorlds();

      return worldsResult.fold(
        (failure) => Left(failure),
        (worlds) {
          final totalStars = worlds.fold<int>(
            0,
            (sum, world) => sum + world.stars,
          );
          return Right(totalStars);
        },
      );
    } catch (e, stackTrace) {
      return Left(CacheFailure(
        message: 'Не удалось подсчитать звёзды: $e',
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Either<Failure, List<WorldEntity>>> resetAllWorlds() async {
    try {
      final worlds = WorldModel.createAllWorlds();
      final success = await _dataSource.saveWorlds(worlds);

      if (success) {
        _cachedWorlds = worlds;
        return Right(worlds);
      }

      return Left(CacheFailure.writeError(StorageKeys.worldsData));
    } catch (e, stackTrace) {
      return Left(CacheFailure(
        message: 'Не удалось сбросить миры: $e',
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveWorld(WorldEntity world) async {
    try {
      final model = WorldModel.fromEntity(world);
      final success = await _dataSource.saveWorld(model);

      if (success) {
        // Обновляем кэш
        if (_cachedWorlds != null) {
          final index = _cachedWorlds!.indexWhere((w) => w.id == world.id);
          if (index >= 0) {
            _cachedWorlds![index] = model;
          }
        }
        return const Right(unit);
      }

      return Left(CacheFailure.writeError(StorageKeys.worldsData));
    } catch (e, stackTrace) {
      return Left(CacheFailure(
        message: 'Не удалось сохранить мир: $e',
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Either<Failure, List<WorldEntity>>> initializeWorlds() async {
    try {
      final worlds = WorldModel.createAllWorlds();
      final success = await _dataSource.saveWorlds(worlds);

      if (success) {
        _cachedWorlds = worlds;
        return Right(worlds);
      }

      return Left(CacheFailure.writeError(StorageKeys.worldsData));
    } catch (e, stackTrace) {
      return Left(CacheFailure(
        message: 'Не удалось инициализировать миры: $e',
        stackTrace: stackTrace,
      ));
    }
  }

  /// Очищает кэш (для тестирования)
  void clearCache() {
    _cachedWorlds = null;
  }
}
