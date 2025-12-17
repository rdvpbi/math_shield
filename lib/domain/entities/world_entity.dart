/// Сущность игрового мира
///
/// Каждый мир соответствует одной таблице умножения (×0 ... ×9).
library;

/// Игровой мир — уровень с определённым множителем
///
/// Immutable класс, изменения через [copyWith].
class WorldEntity {
  /// Идентификатор мира (0-9)
  final int id;

  /// Название мира
  final String name;

  /// Множитель таблицы умножения (совпадает с id)
  final int multiplier;

  /// Название босса этого мира
  final String bossName;

  /// Разблокирован ли мир
  final bool isUnlocked;

  /// Пройден ли мир
  final bool isCompleted;

  /// Лучший счёт в этом мире
  final int bestScore;

  /// Побеждён ли босс
  final bool bossDefeated;

  /// Количество заработанных звёзд (0-3)
  final int stars;

  /// Создаёт сущность мира
  const WorldEntity({
    required this.id,
    required this.name,
    required this.multiplier,
    required this.bossName,
    this.isUnlocked = false,
    this.isCompleted = false,
    this.bestScore = 0,
    this.bossDefeated = false,
    this.stars = 0,
  });

  /// Создаёт заблокированный мир
  factory WorldEntity.locked({
    required int id,
    required String name,
    required String bossName,
  }) {
    return WorldEntity(
      id: id,
      name: name,
      multiplier: id,
      bossName: bossName,
      isUnlocked: false,
    );
  }

  /// Создаёт разблокированный мир
  factory WorldEntity.unlocked({
    required int id,
    required String name,
    required String bossName,
  }) {
    return WorldEntity(
      id: id,
      name: name,
      multiplier: id,
      bossName: bossName,
      isUnlocked: true,
    );
  }

  /// Создаёт пустой мир (для fallback)
  factory WorldEntity.empty() {
    return const WorldEntity(
      id: 0,
      name: 'Unknown',
      multiplier: 0,
      bossName: 'Unknown',
    );
  }

  /// Проверяет, доступен ли мир для игры
  bool get isPlayable => isUnlocked;

  /// Проверяет, полностью ли пройден мир (босс побеждён)
  bool get isFullyCompleted => isCompleted && bossDefeated;

  /// Проверяет, есть ли у мира максимальный рейтинг
  bool get hasPerfectScore => stars == 3;

  /// Процент завершения мира (0.0 - 1.0)
  double get completionPercentage {
    if (!isUnlocked) return 0.0;
    if (!isCompleted) return 0.25;
    if (!bossDefeated) return 0.75;
    return 1.0;
  }

  /// Создаёт копию с изменёнными полями
  WorldEntity copyWith({
    int? id,
    String? name,
    int? multiplier,
    String? bossName,
    bool? isUnlocked,
    bool? isCompleted,
    int? bestScore,
    bool? bossDefeated,
    int? stars,
  }) {
    return WorldEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      multiplier: multiplier ?? this.multiplier,
      bossName: bossName ?? this.bossName,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      isCompleted: isCompleted ?? this.isCompleted,
      bestScore: bestScore ?? this.bestScore,
      bossDefeated: bossDefeated ?? this.bossDefeated,
      stars: stars ?? this.stars,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorldEntity &&
        other.id == id &&
        other.name == name &&
        other.multiplier == multiplier &&
        other.bossName == bossName &&
        other.isUnlocked == isUnlocked &&
        other.isCompleted == isCompleted &&
        other.bestScore == bestScore &&
        other.bossDefeated == bossDefeated &&
        other.stars == stars;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      multiplier,
      bossName,
      isUnlocked,
      isCompleted,
      bestScore,
      bossDefeated,
      stars,
    );
  }

  @override
  String toString() {
    return 'WorldEntity(id: $id, name: $name, ×$multiplier, '
        'unlocked: $isUnlocked, completed: $isCompleted, stars: $stars)';
  }
}
