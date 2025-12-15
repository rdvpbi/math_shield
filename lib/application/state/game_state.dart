/// Состояние игры
///
/// Глобальное состояние игрового процесса.
library;

import '../../domain/entities/player_entity.dart';

/// Состояние игры
///
/// Immutable класс, изменения через [copyWith].
class GameState {
  /// Данные игрока
  final PlayerEntity player;

  /// Флаг загрузки
  final bool isLoading;

  /// Сообщение об ошибке
  final String? error;

  /// Первый ли это запуск
  final bool isFirstLaunch;

  /// Приостановлена ли игра
  final bool isPaused;

  /// Создаёт состояние игры
  const GameState({
    required this.player,
    this.isLoading = false,
    this.error,
    this.isFirstLaunch = false,
    this.isPaused = false,
  });

  /// Начальное состояние
  factory GameState.initial() {
    return GameState(
      player: PlayerEntity.empty(),
      isLoading: true,
      isFirstLaunch: true,
    );
  }

  /// Состояние загрузки
  factory GameState.loading() {
    return GameState(
      player: PlayerEntity.empty(),
      isLoading: true,
    );
  }

  /// Состояние с ошибкой
  factory GameState.error(String message) {
    return GameState(
      player: PlayerEntity.empty(),
      error: message,
    );
  }

  /// Проверяет, есть ли ошибка
  bool get hasError => error != null;

  /// Проверяет, загружены ли данные
  bool get isLoaded => !isLoading && !hasError;

  /// Проверяет, жив ли игрок
  bool get isPlayerAlive => player.isAlive;

  /// Создаёт копию с изменёнными полями
  GameState copyWith({
    PlayerEntity? player,
    bool? isLoading,
    String? error,
    bool? isFirstLaunch,
    bool? isPaused,
    bool clearError = false,
  }) {
    return GameState(
      player: player ?? this.player,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
      isPaused: isPaused ?? this.isPaused,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GameState &&
        other.player == player &&
        other.isLoading == isLoading &&
        other.error == error &&
        other.isFirstLaunch == isFirstLaunch &&
        other.isPaused == isPaused;
  }

  @override
  int get hashCode {
    return Object.hash(
      player,
      isLoading,
      error,
      isFirstLaunch,
      isPaused,
    );
  }

  @override
  String toString() {
    return 'GameState(player: ${player.id}, loading: $isLoading, '
        'error: $error, paused: $isPaused)';
  }
}
