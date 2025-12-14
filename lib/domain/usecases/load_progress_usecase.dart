/// Use Case: Загрузка прогресса игрока
///
/// Загружает данные игрока и миров из хранилища.
library;

import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/player_entity.dart';
import '../entities/world_entity.dart';
import '../repositories/player_repository.dart';
import '../repositories/world_repository.dart';

/// Полный прогресс игрока
class GameProgress {
  /// Данные игрока
  final PlayerEntity player;

  /// Список всех миров
  final List<WorldEntity> worlds;

  /// Общий прогресс (0.0 - 1.0)
  final double totalProgress;

  /// Общее количество звёзд
  final int totalStars;

  const GameProgress({
    required this.player,
    required this.worlds,
    required this.totalProgress,
    required this.totalStars,
  });

  /// Текущий мир игрока
  WorldEntity? get currentWorld {
    try {
      return worlds.firstWhere((w) => w.id == player.currentWorld);
    } catch (_) {
      return null;
    }
  }

  /// Следующий заблокированный мир
  WorldEntity? get nextLockedWorld {
    try {
      return worlds.firstWhere((w) => !w.isUnlocked);
    } catch (_) {
      return null;
    }
  }

  /// Количество пройденных миров
  int get completedWorldsCount => worlds.where((w) => w.isCompleted).length;

  /// Количество побеждённых боссов
  int get defeatedBossesCount => worlds.where((w) => w.bossDefeated).length;
}

/// Use Case для загрузки прогресса игрока
///
/// Пример использования:
/// ```dart
/// final useCase = LoadProgressUseCase(playerRepo, worldRepo);
/// final result = await useCase();
/// result.fold(
///   (failure) => print('Error: ${failure.message}'),
///   (progress) => print('Score: ${progress.player.score}'),
/// );
/// ```
class LoadProgressUseCase {
  final PlayerRepository _playerRepository;
  final WorldRepository _worldRepository;

  const LoadProgressUseCase(
    this._playerRepository,
    this._worldRepository,
  );

  /// Загружает полный прогресс игры
  ///
  /// Возвращает:
  /// - [Right]<[GameProgress]> — полные данные прогресса
  /// - [Left]<[CacheFailure]> — ошибка чтения данных
  Future<Either<Failure, GameProgress>> call() async {
    // Загружаем игрока
    final playerResult = await _playerRepository.getPlayer();

    return playerResult.fold(
      (failure) => Left(failure),
      (player) async {
        // Загружаем миры
        final worldsResult = await _worldRepository.getAllWorlds();

        return worldsResult.fold(
          (failure) => Left(failure),
          (worlds) async {
            // Получаем общий прогресс
            final progressResult = await _worldRepository.getTotalProgress();
            final totalProgress = progressResult.fold(
              (_) => 0.0,
              (progress) => progress,
            );

            // Получаем общее количество звёзд
            final starsResult = await _worldRepository.getTotalStars();
            final totalStars = starsResult.fold(
              (_) => 0,
              (stars) => stars,
            );

            return Right(GameProgress(
              player: player,
              worlds: worlds,
              totalProgress: totalProgress,
              totalStars: totalStars,
            ));
          },
        );
      },
    );
  }
}

/// Use Case для загрузки только данных игрока
class LoadPlayerUseCase {
  final PlayerRepository _repository;

  const LoadPlayerUseCase(this._repository);

  /// Загружает данные игрока
  Future<Either<Failure, PlayerEntity>> call() {
    return _repository.getPlayer();
  }
}

/// Use Case для загрузки только данных миров
class LoadWorldsUseCase {
  final WorldRepository _repository;

  const LoadWorldsUseCase(this._repository);

  /// Загружает список всех миров
  Future<Either<Failure, List<WorldEntity>>> call() {
    return _repository.getAllWorlds();
  }
}

/// Use Case для проверки наличия сохранённых данных
class HasSavedProgressUseCase {
  final PlayerRepository _repository;

  const HasSavedProgressUseCase(this._repository);

  /// Проверяет, есть ли сохранённый прогресс
  Future<bool> call() {
    return _repository.hasExistingData();
  }
}
