/// Контроллер игры
///
/// Управляет глобальным состоянием игры и игроком.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/game_constants.dart';
import '../../domain/entities/player_entity.dart';
import '../../domain/repositories/player_repository.dart';
import '../providers/providers.dart';
import '../state/game_state.dart';

/// Контроллер игры
class GameController extends Notifier<GameState> {
  late final PlayerRepository _playerRepository;

  @override
  GameState build() {
    _playerRepository = ref.read(playerRepoProvider);
    return GameState.initial();
  }

  /// Загружает игру
  Future<void> loadGame() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _playerRepository.getPlayer();

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (player) {
        final isFirst = player.score == 0 && player.unlockedWorlds.length == 1;
        state = state.copyWith(
          player: player,
          isLoading: false,
          isFirstLaunch: isFirst,
        );
      },
    );
  }

  /// Сохраняет игру
  Future<bool> saveGame() async {
    final result = await _playerRepository.savePlayer(state.player);

    return result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
        return false;
      },
      (_) => true,
    );
  }

  /// Теряет жизнь
  Future<void> loseLife() async {
    if (state.player.lives <= 0) return;

    final result = await _playerRepository.loseLife();

    result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
      },
      (player) {
        state = state.copyWith(player: player);
      },
    );
  }

  /// Восстанавливает жизнь
  Future<void> gainLife() async {
    if (state.player.lives >= state.player.maxLives) return;

    final result = await _playerRepository.gainLife();

    result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
      },
      (player) {
        state = state.copyWith(player: player);
      },
    );
  }

  /// Добавляет очки
  Future<void> addScore(int points) async {
    final result = await _playerRepository.addScore(points);

    result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
      },
      (player) {
        state = state.copyWith(player: player);
      },
    );
  }

  /// Устанавливает счёт
  Future<void> setScore(int score) async {
    final result = await _playerRepository.updateScore(score);

    result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
      },
      (player) {
        state = state.copyWith(player: player);
      },
    );
  }

  /// Обновляет комбо
  Future<void> updateCombo(int combo) async {
    final result = await _playerRepository.updateCombo(combo);

    result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
      },
      (player) {
        state = state.copyWith(player: player);
      },
    );
  }

  /// Сбрасывает комбо
  Future<void> resetCombo() async {
    final result = await _playerRepository.resetCombo();

    result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
      },
      (player) {
        state = state.copyWith(player: player);
      },
    );
  }

  /// Увеличивает комбо
  Future<void> incrementCombo() async {
    final result = await _playerRepository.incrementCombo();

    result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
      },
      (player) {
        state = state.copyWith(player: player);
      },
    );
  }

  /// Разблокирует мир
  Future<void> unlockWorld(int worldId) async {
    final result = await _playerRepository.unlockWorld(worldId);

    result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
      },
      (player) {
        state = state.copyWith(player: player);
      },
    );
  }

  /// Устанавливает текущий мир
  Future<void> setCurrentWorld(int worldId) async {
    final result = await _playerRepository.setCurrentWorld(worldId);

    result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
      },
      (player) {
        state = state.copyWith(player: player);
      },
    );
  }

  /// Ставит игру на паузу
  void pause() {
    state = state.copyWith(isPaused: true);
  }

  /// Снимает игру с паузы
  void resume() {
    state = state.copyWith(isPaused: false);
  }

  /// Переключает паузу
  void togglePause() {
    state = state.copyWith(isPaused: !state.isPaused);
  }

  /// Сбрасывает игру
  Future<void> resetGame() async {
    state = state.copyWith(isLoading: true);

    final result = await _playerRepository.resetProgress();

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (player) {
        state = GameState(
          player: player,
          isLoading: false,
          isFirstLaunch: true,
        );
      },
    );
  }

  /// Очищает ошибку
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Обновляет игрока напрямую (для синхронизации)
  void updatePlayer(PlayerEntity player) {
    state = state.copyWith(player: player);
  }

  /// Отмечает первый запуск как завершённый
  void markFirstLaunchComplete() {
    state = state.copyWith(isFirstLaunch: false);
  }

  /// Восстанавливает жизни до максимума
  Future<void> restoreAllLives() async {
    final result = await _playerRepository.updateLives(PlayerConstants.maxLives);

    result.fold(
      (failure) {
        state = state.copyWith(error: failure.message);
      },
      (player) {
        state = state.copyWith(player: player);
      },
    );
  }
}

/// Provider для GameController
final gameControllerProvider =
    NotifierProvider<GameController, GameState>(GameController.new);
