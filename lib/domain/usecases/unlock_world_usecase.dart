/// Use Case: Разблокировка мира
///
/// Проверяет условия и разблокирует следующий мир.
library;

import 'package:dartz/dartz.dart';

import '../../core/config/game_constants.dart';
import '../../core/errors/failures.dart';
import '../entities/player_entity.dart';
import '../entities/world_entity.dart';
import '../repositories/player_repository.dart';
import '../repositories/world_repository.dart';

/// Результат разблокировки мира
class UnlockWorldResult {
  /// Разблокированный мир
  final WorldEntity unlockedWorld;

  /// Обновлённый игрок
  final PlayerEntity player;

  /// Был ли это последний мир
  final bool isLastWorld;

  const UnlockWorldResult({
    required this.unlockedWorld,
    required this.player,
    required this.isLastWorld,
  });
}

/// Use Case для разблокировки мира
///
/// Пример использования:
/// ```dart
/// final useCase = UnlockWorldUseCase(playerRepo, worldRepo);
/// final result = await useCase(worldId: 2);
/// result.fold(
///   (failure) => print('Error: ${failure.message}'),
///   (result) => print('Unlocked: ${result.unlockedWorld.name}'),
/// );
/// ```
class UnlockWorldUseCase {
  final PlayerRepository _playerRepository;
  final WorldRepository _worldRepository;

  const UnlockWorldUseCase(
    this._playerRepository,
    this._worldRepository,
  );

  /// Разблокирует указанный мир
  ///
  /// Параметры:
  /// - [worldId] — ID мира для разблокировки (0-9)
  ///
  /// Возвращает:
  /// - [Right]<[UnlockWorldResult]> — результат разблокировки
  /// - [Left]<[ValidationFailure]> — если worldId вне диапазона
  /// - [Left]<[GameFailure]> — если мир уже разблокирован
  Future<Either<Failure, UnlockWorldResult>> call({
    required int worldId,
  }) async {
    // Валидация worldId
    if (worldId < 0 || worldId >= WorldConstants.totalWorlds) {
      return Left(ValidationFailure.outOfRange(
        field: 'worldId',
        value: worldId,
        min: 0,
        max: WorldConstants.totalWorlds - 1,
      ));
    }

    // Получаем текущее состояние мира
    final worldResult = await _worldRepository.getWorld(worldId);

    return worldResult.fold(
      (failure) => Left(failure),
      (world) async {
        // Проверяем, не разблокирован ли уже
        if (world.isUnlocked) {
          return Left(GameFailure(
            message: 'Мир "${world.name}" уже разблокирован',
          ));
        }

        // Разблокируем мир в репозитории миров
        final unlockWorldResult = await _worldRepository.unlockWorld(worldId);

        return unlockWorldResult.fold(
          (failure) => Left(failure),
          (unlockedWorld) async {
            // Разблокируем мир для игрока
            final playerResult =
                await _playerRepository.unlockWorld(worldId);

            return playerResult.fold(
              (failure) => Left(failure),
              (player) => Right(UnlockWorldResult(
                unlockedWorld: unlockedWorld,
                player: player,
                isLastWorld: worldId == WorldConstants.totalWorlds - 1,
              )),
            );
          },
        );
      },
    );
  }

  /// Разблокирует следующий мир после указанного
  ///
  /// Параметры:
  /// - [currentWorldId] — ID текущего мира
  Future<Either<Failure, UnlockWorldResult>> unlockNext({
    required int currentWorldId,
  }) async {
    final nextWorldId = currentWorldId + 1;

    // Проверяем, есть ли следующий мир
    if (nextWorldId >= WorldConstants.totalWorlds) {
      return Left(GameFailure(
        message: 'Все миры уже разблокированы',
      ));
    }

    return call(worldId: nextWorldId);
  }
}

/// Use Case для проверки условий разблокировки
class CanUnlockWorldUseCase {
  final WorldRepository _worldRepository;

  const CanUnlockWorldUseCase(this._worldRepository);

  /// Проверяет, можно ли разблокировать мир
  ///
  /// Условия разблокировки:
  /// - Предыдущий мир пройден
  /// - Босс предыдущего мира побеждён
  Future<Either<Failure, bool>> call({
    required int worldId,
  }) async {
    // Первый мир всегда разблокирован
    if (worldId == 0) {
      return const Right(true);
    }

    // Проверяем предыдущий мир
    final prevWorldResult = await _worldRepository.getWorld(worldId - 1);

    return prevWorldResult.fold(
      (failure) => Left(failure),
      (prevWorld) {
        // Для разблокировки нужно победить босса предыдущего мира
        return Right(prevWorld.bossDefeated);
      },
    );
  }
}

/// Use Case для завершения мира и разблокировки следующего
class CompleteWorldUseCase {
  final WorldRepository _worldRepository;
  final PlayerRepository _playerRepository;
  final UnlockWorldUseCase _unlockWorldUseCase;

  const CompleteWorldUseCase(
    this._worldRepository,
    this._playerRepository,
    this._unlockWorldUseCase,
  );

  /// Завершает мир и разблокирует следующий
  ///
  /// Параметры:
  /// - [worldId] — ID завершённого мира
  /// - [score] — набранный счёт
  /// - [bossDefeated] — был ли побеждён босс
  Future<Either<Failure, CompleteWorldResult>> call({
    required int worldId,
    required int score,
    required bool bossDefeated,
  }) async {
    // Завершаем мир
    final completeResult = await _worldRepository.completeWorld(worldId, score);

    return completeResult.fold(
      (failure) => Left(failure),
      (completedWorld) async {
        WorldEntity finalWorld = completedWorld;

        // Если босс побеждён, отмечаем это
        if (bossDefeated) {
          final bossResult = await _worldRepository.defeatBoss(worldId);
          finalWorld = bossResult.fold(
            (_) => completedWorld,
            (world) => world,
          );
        }

        // Добавляем очки игроку
        await _playerRepository.addScore(score);

        // Пытаемся разблокировать следующий мир
        UnlockWorldResult? unlockResult;
        if (bossDefeated && worldId < WorldConstants.totalWorlds - 1) {
          final unlockEither = await _unlockWorldUseCase.unlockNext(
            currentWorldId: worldId,
          );
          unlockResult = unlockEither.fold(
            (_) => null,
            (result) => result,
          );
        }

        return Right(CompleteWorldResult(
          completedWorld: finalWorld,
          unlockedWorld: unlockResult?.unlockedWorld,
          newScore: score,
        ));
      },
    );
  }
}

/// Результат завершения мира
class CompleteWorldResult {
  /// Завершённый мир
  final WorldEntity completedWorld;

  /// Разблокированный мир (если есть)
  final WorldEntity? unlockedWorld;

  /// Набранный счёт
  final int newScore;

  const CompleteWorldResult({
    required this.completedWorld,
    this.unlockedWorld,
    required this.newScore,
  });

  /// Был ли разблокирован новый мир
  bool get hasUnlockedNewWorld => unlockedWorld != null;
}
