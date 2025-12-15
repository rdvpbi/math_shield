/// Контроллер миров
///
/// Управляет списком миров и выбором текущего мира.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/world_entity.dart';
import '../../domain/repositories/world_repository.dart';
import '../state/world_state.dart';

/// Контроллер миров
class WorldController extends Notifier<WorldState> {
  late final WorldRepository _worldRepository;

  @override
  WorldState build() {
    _worldRepository = ref.read(worldRepositoryProvider);
    return WorldState.initial();
  }

  /// Загружает все миры
  Future<void> loadWorlds() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _worldRepository.getAllWorlds();

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (worlds) {
        state = state.copyWith(
          worlds: worlds,
          isLoading: false,
        );
      },
    );
  }

  /// Выбирает мир
  Future<void> selectWorld(int worldId) async {
    final result = await _worldRepository.getWorld(worldId);

    result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
      },
      (world) {
        state = state.copyWith(currentWorld: world);
      },
    );
  }

  /// Снимает выбор мира
  void deselectWorld() {
    state = state.copyWith(clearCurrentWorld: true);
  }

  /// Завершает мир
  Future<void> completeWorld(int worldId, int score) async {
    final result = await _worldRepository.completeWorld(worldId, score);

    result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
      },
      (world) {
        state = state.updateWorld(world);
      },
    );
  }

  /// Побеждает босса
  Future<void> defeatBoss(int worldId) async {
    final result = await _worldRepository.defeatBoss(worldId);

    result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
      },
      (world) {
        state = state.updateWorld(world);
      },
    );
  }

  /// Разблокирует мир
  Future<bool> unlockWorld(int worldId) async {
    final result = await _worldRepository.unlockWorld(worldId);

    return result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
        return false;
      },
      (world) {
        state = state.updateWorld(world);
        return true;
      },
    );
  }

  /// Разблокирует следующий мир
  Future<bool> unlockNextWorld() async {
    final nextWorld = state.nextLockedWorld;
    if (nextWorld == null) return false;

    return unlockWorld(nextWorld.id);
  }

  /// Обновляет лучший счёт
  Future<void> updateBestScore(int worldId, int score) async {
    final result = await _worldRepository.updateBestScore(worldId, score);

    result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
      },
      (world) {
        state = state.updateWorld(world);
      },
    );
  }

  /// Устанавливает звёзды для мира
  Future<void> setStars(int worldId, int stars) async {
    final result = await _worldRepository.setStars(worldId, stars);

    result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
      },
      (world) {
        state = state.updateWorld(world);
      },
    );
  }

  /// Получает мир по ID
  WorldEntity? getWorld(int worldId) {
    return state.getWorld(worldId);
  }

  /// Проверяет, разблокирован ли мир
  bool isWorldUnlocked(int worldId) {
    return state.getWorld(worldId)?.isUnlocked ?? false;
  }

  /// Проверяет, пройден ли мир
  bool isWorldCompleted(int worldId) {
    return state.getWorld(worldId)?.isCompleted ?? false;
  }

  /// Проверяет, побеждён ли босс мира
  bool isBossDefeated(int worldId) {
    return state.getWorld(worldId)?.bossDefeated ?? false;
  }

  /// Сбрасывает все миры
  Future<void> resetAllWorlds() async {
    state = state.copyWith(isLoading: true);

    final result = await _worldRepository.resetAllWorlds();

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (worlds) {
        state = WorldState(
          worlds: worlds,
          isLoading: false,
        );
      },
    );
  }

  /// Очищает ошибку
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Инициализирует миры при первом запуске
  Future<void> initializeWorlds() async {
    final result = await _worldRepository.initializeWorlds();

    result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
      },
      (worlds) {
        state = state.copyWith(worlds: worlds);
      },
    );
  }

  /// Обновляет мир в списке
  void updateWorld(WorldEntity world) {
    state = state.updateWorld(world);
  }
}

/// Provider для WorldRepository (должен быть переопределён)
final worldRepositoryProvider = Provider<WorldRepository>((ref) {
  throw UnimplementedError('worldRepositoryProvider must be overridden');
});

/// Provider для WorldController
final worldControllerProvider =
    NotifierProvider<WorldController, WorldState>(WorldController.new);
