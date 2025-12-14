/// Сущность игрока
///
/// Содержит все данные о текущем состоянии игрока:
/// жизни, счёт, прогресс по мирам, комбо.
library;

import '../../core/config/game_constants.dart';

/// Игрок — главный герой Math Shield
///
/// Immutable класс, изменения через [copyWith].
class PlayerEntity {
  /// Уникальный идентификатор игрока
  final String id;

  /// Текущее количество жизней
  final int lives;

  /// Максимальное количество жизней
  final int maxLives;

  /// Текущий счёт
  final int score;

  /// Текущий выбранный мир (0-9)
  final int currentWorld;

  /// Список разблокированных миров
  final List<int> unlockedWorlds;

  /// Текущее значение комбо
  final int combo;

  /// Создаёт сущность игрока
  const PlayerEntity({
    required this.id,
    required this.lives,
    required this.maxLives,
    required this.score,
    required this.currentWorld,
    required this.unlockedWorlds,
    required this.combo,
  });

  /// Создаёт пустого игрока с начальными значениями
  factory PlayerEntity.empty() {
    return PlayerEntity(
      id: 'player_1',
      lives: PlayerConstants.initialLives,
      maxLives: PlayerConstants.maxLives,
      score: PlayerConstants.initialScore,
      currentWorld: PlayerConstants.startingWorld,
      unlockedWorlds: const [0], // Первый мир разблокирован
      combo: ComboConstants.initialCombo,
    );
  }

  /// Создаёт нового игрока с указанным ID
  factory PlayerEntity.create(String id) {
    return PlayerEntity(
      id: id,
      lives: PlayerConstants.initialLives,
      maxLives: PlayerConstants.maxLives,
      score: PlayerConstants.initialScore,
      currentWorld: PlayerConstants.startingWorld,
      unlockedWorlds: const [0],
      combo: ComboConstants.initialCombo,
    );
  }

  /// Проверяет, жив ли игрок
  bool get isAlive => lives > 0;

  /// Проверяет, полные ли жизни
  bool get hasFullLives => lives >= maxLives;

  /// Процент здоровья (0.0 - 1.0)
  double get healthPercentage => lives / maxLives;

  /// Проверяет, разблокирован ли указанный мир
  bool isWorldUnlocked(int worldId) => unlockedWorlds.contains(worldId);

  /// Количество разблокированных миров
  int get unlockedWorldsCount => unlockedWorlds.length;

  /// Текущий множитель комбо
  double get comboMultiplier => ComboConstants.calculateMultiplier(combo);

  /// Создаёт копию с изменёнными полями
  PlayerEntity copyWith({
    String? id,
    int? lives,
    int? maxLives,
    int? score,
    int? currentWorld,
    List<int>? unlockedWorlds,
    int? combo,
  }) {
    return PlayerEntity(
      id: id ?? this.id,
      lives: lives ?? this.lives,
      maxLives: maxLives ?? this.maxLives,
      score: score ?? this.score,
      currentWorld: currentWorld ?? this.currentWorld,
      unlockedWorlds: unlockedWorlds ?? this.unlockedWorlds,
      combo: combo ?? this.combo,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlayerEntity &&
        other.id == id &&
        other.lives == lives &&
        other.maxLives == maxLives &&
        other.score == score &&
        other.currentWorld == currentWorld &&
        _listEquals(other.unlockedWorlds, unlockedWorlds) &&
        other.combo == combo;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      lives,
      maxLives,
      score,
      currentWorld,
      Object.hashAll(unlockedWorlds),
      combo,
    );
  }

  @override
  String toString() {
    return 'PlayerEntity(id: $id, lives: $lives/$maxLives, '
        'score: $score, world: $currentWorld, combo: $combo)';
  }
}

/// Сравнивает два списка на равенство
bool _listEquals<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
