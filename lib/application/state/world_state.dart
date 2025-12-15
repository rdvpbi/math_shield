/// Состояние миров
///
/// Управляет списком миров и текущим выбранным миром.
library;

import '../../domain/entities/world_entity.dart';

/// Состояние миров
///
/// Immutable класс, изменения через [copyWith].
class WorldState {
  /// Список всех миров
  final List<WorldEntity> worlds;

  /// Текущий выбранный мир
  final WorldEntity? currentWorld;

  /// Флаг загрузки
  final bool isLoading;

  /// Сообщение об ошибке
  final String? error;

  /// Создаёт состояние миров
  const WorldState({
    required this.worlds,
    this.currentWorld,
    this.isLoading = false,
    this.error,
  });

  /// Начальное состояние
  factory WorldState.initial() {
    return const WorldState(
      worlds: [],
      isLoading: true,
    );
  }

  /// Состояние загрузки
  factory WorldState.loading() {
    return const WorldState(
      worlds: [],
      isLoading: true,
    );
  }

  /// Проверяет, есть ли ошибка
  bool get hasError => error != null;

  /// Проверяет, загружены ли миры
  bool get isLoaded => !isLoading && worlds.isNotEmpty;

  /// Проверяет, выбран ли мир
  bool get hasCurrentWorld => currentWorld != null;

  /// Получает разблокированные миры
  List<WorldEntity> get unlockedWorlds =>
      worlds.where((w) => w.isUnlocked).toList();

  /// Получает пройденные миры
  List<WorldEntity> get completedWorlds =>
      worlds.where((w) => w.isCompleted).toList();

  /// Получает количество разблокированных миров
  int get unlockedCount => unlockedWorlds.length;

  /// Получает количество пройденных миров
  int get completedCount => completedWorlds.length;

  /// Получает общее количество звёзд
  int get totalStars => worlds.fold(0, (sum, w) => sum + w.stars);

  /// Получает максимальное количество звёзд
  int get maxStars => worlds.length * 3;

  /// Получает общий прогресс (0.0 - 1.0)
  double get totalProgress {
    if (worlds.isEmpty) return 0.0;
    return worlds.fold<double>(0.0, (sum, w) => sum + w.completionPercentage) /
        worlds.length;
  }

  /// Получает мир по ID
  WorldEntity? getWorld(int id) {
    try {
      return worlds.firstWhere((w) => w.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Получает следующий заблокированный мир
  WorldEntity? get nextLockedWorld {
    try {
      return worlds.firstWhere((w) => !w.isUnlocked);
    } catch (_) {
      return null;
    }
  }

  /// Создаёт копию с изменёнными полями
  WorldState copyWith({
    List<WorldEntity>? worlds,
    WorldEntity? currentWorld,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool clearCurrentWorld = false,
  }) {
    return WorldState(
      worlds: worlds ?? this.worlds,
      currentWorld:
          clearCurrentWorld ? null : (currentWorld ?? this.currentWorld),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  /// Обновляет мир в списке
  WorldState updateWorld(WorldEntity updatedWorld) {
    final newWorlds = worlds.map((w) {
      return w.id == updatedWorld.id ? updatedWorld : w;
    }).toList();

    return copyWith(
      worlds: newWorlds,
      currentWorld:
          currentWorld?.id == updatedWorld.id ? updatedWorld : currentWorld,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorldState &&
        _listEquals(other.worlds, worlds) &&
        other.currentWorld == currentWorld &&
        other.isLoading == isLoading &&
        other.error == error;
  }

  @override
  int get hashCode {
    return Object.hash(
      Object.hashAll(worlds),
      currentWorld,
      isLoading,
      error,
    );
  }

  @override
  String toString() {
    return 'WorldState(worlds: ${worlds.length}, current: ${currentWorld?.id}, '
        'loading: $isLoading)';
  }
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
