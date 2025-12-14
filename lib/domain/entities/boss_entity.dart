/// Сущность босса
///
/// Каждый мир имеет своего уникального босса.
/// Босс управляется конечным автоматом (FSM).
library;

import '../../core/config/game_constants.dart';

/// Фазы состояния босса (FSM)
enum BossPhase {
  /// Ожидание — босс стоит на месте
  idle,

  /// Атака — босс атакует игрока
  attack,

  /// Получение урона — босс получил урон
  hurt,

  /// Ярость — босс в режиме ярости (HP < 30%)
  rage,

  /// Поражение — босс побеждён
  defeat,
}

/// Босс — враг в конце каждого мира
///
/// Immutable класс, изменения через [copyWith].
class BossEntity {
  /// Уникальный идентификатор босса
  final int id;

  /// Имя босса
  final String name;

  /// ID мира, которому принадлежит босс
  final int worldId;

  /// Максимальное здоровье
  final int maxHp;

  /// Текущее здоровье
  final int currentHp;

  /// Текущая фаза состояния
  final BossPhase phase;

  /// Описание босса (для диалогов)
  final String description;

  /// Создаёт сущность босса
  const BossEntity({
    required this.id,
    required this.name,
    required this.worldId,
    required this.maxHp,
    required this.currentHp,
    this.phase = BossPhase.idle,
    this.description = '',
  });

  /// Создаёт босса для указанного мира с расчётом HP
  factory BossEntity.forWorld({
    required int worldId,
    required String name,
    String description = '',
  }) {
    final hp = BossConstants.calculateBossHp(worldId);
    return BossEntity(
      id: worldId,
      name: name,
      worldId: worldId,
      maxHp: hp,
      currentHp: hp,
      description: description,
    );
  }

  /// Создаёт босса в начальном состоянии
  factory BossEntity.initial({
    required int id,
    required String name,
    required int worldId,
  }) {
    final hp = BossConstants.calculateBossHp(worldId);
    return BossEntity(
      id: id,
      name: name,
      worldId: worldId,
      maxHp: hp,
      currentHp: hp,
      phase: BossPhase.idle,
    );
  }

  /// Процент здоровья (0.0 - 1.0)
  double get hpPercentage {
    if (maxHp <= 0) return 0.0;
    return currentHp / maxHp;
  }

  /// Процент здоровья в целых числах (0 - 100)
  int get hpPercent => (hpPercentage * 100).round();

  /// Проверяет, жив ли босс
  bool get isAlive => currentHp > 0;

  /// Проверяет, побеждён ли босс
  bool get isDefeated => currentHp <= 0 || phase == BossPhase.defeat;

  /// Проверяет, должен ли босс перейти в режим ярости
  bool get shouldEnterRage {
    return BossConstants.shouldEnterRage(currentHp, maxHp) &&
        phase != BossPhase.rage &&
        phase != BossPhase.defeat;
  }

  /// Проверяет, находится ли босс в режиме ярости
  bool get isInRage => phase == BossPhase.rage;

  /// Проверяет, атакует ли босс
  bool get isAttacking => phase == BossPhase.attack;

  /// Проверяет, получает ли босс урон
  bool get isHurt => phase == BossPhase.hurt;

  /// Проверяет, находится ли босс в состоянии ожидания
  bool get isIdle => phase == BossPhase.idle;

  /// Создаёт копию с изменёнными полями
  BossEntity copyWith({
    int? id,
    String? name,
    int? worldId,
    int? maxHp,
    int? currentHp,
    BossPhase? phase,
    String? description,
  }) {
    return BossEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      worldId: worldId ?? this.worldId,
      maxHp: maxHp ?? this.maxHp,
      currentHp: currentHp ?? this.currentHp,
      phase: phase ?? this.phase,
      description: description ?? this.description,
    );
  }

  /// Применяет урон к боссу
  ///
  /// Возвращает нового босса с уменьшенным HP.
  /// Автоматически переключает фазу на hurt или defeat.
  BossEntity takeDamage(int damage) {
    final newHp = (currentHp - damage).clamp(0, maxHp);

    BossPhase newPhase;
    if (newHp <= 0) {
      newPhase = BossPhase.defeat;
    } else if (BossConstants.shouldEnterRage(newHp, maxHp) &&
        phase != BossPhase.rage) {
      newPhase = BossPhase.rage;
    } else {
      newPhase = BossPhase.hurt;
    }

    return copyWith(
      currentHp: newHp,
      phase: newPhase,
    );
  }

  /// Восстанавливает босса до начального состояния
  BossEntity reset() {
    return copyWith(
      currentHp: maxHp,
      phase: BossPhase.idle,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BossEntity &&
        other.id == id &&
        other.name == name &&
        other.worldId == worldId &&
        other.maxHp == maxHp &&
        other.currentHp == currentHp &&
        other.phase == phase &&
        other.description == description;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      worldId,
      maxHp,
      currentHp,
      phase,
      description,
    );
  }

  @override
  String toString() {
    return 'BossEntity(id: $id, name: $name, hp: $currentHp/$maxHp, '
        'phase: ${phase.name})';
  }
}
