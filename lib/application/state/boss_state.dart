/// Состояние босса
///
/// Управляет состоянием битвы с боссом.
library;

import '../../domain/entities/boss_entity.dart';

/// Состояние битвы с боссом
///
/// Immutable класс, изменения через [copyWith].
class BossState {
  /// Текущий босс
  final BossEntity? boss;

  /// Атакует ли босс
  final bool isAttacking;

  /// Последний нанесённый урон
  final int lastDamage;

  /// Показывать ли анимацию урона
  final bool showDamageAnimation;

  /// Показывать ли анимацию атаки босса
  final bool showBossAttackAnimation;

  /// Флаг победы
  final bool isVictory;

  /// Флаг поражения
  final bool isDefeat;

  /// Сообщение босса (для диалогов)
  final String? bossMessage;

  /// Создаёт состояние босса
  const BossState({
    this.boss,
    this.isAttacking = false,
    this.lastDamage = 0,
    this.showDamageAnimation = false,
    this.showBossAttackAnimation = false,
    this.isVictory = false,
    this.isDefeat = false,
    this.bossMessage,
  });

  /// Начальное состояние
  factory BossState.initial() {
    return const BossState();
  }

  /// Состояние с боссом
  factory BossState.withBoss(BossEntity boss) {
    return BossState(boss: boss);
  }

  /// Проверяет, есть ли босс
  bool get hasBoss => boss != null;

  /// Проверяет, жив ли босс
  bool get isBossAlive => boss?.isAlive ?? false;

  /// Проверяет, побеждён ли босс
  bool get isBossDefeated => boss?.isDefeated ?? false;

  /// Проверяет, в ярости ли босс
  bool get isBossInRage => boss?.isInRage ?? false;

  /// Проверяет, идёт ли бой
  bool get isBattleActive => hasBoss && !isVictory && !isDefeat;

  /// Процент здоровья босса
  double get bossHpPercentage => boss?.hpPercentage ?? 0.0;

  /// Текущее здоровье босса
  int get bossCurrentHp => boss?.currentHp ?? 0;

  /// Максимальное здоровье босса
  int get bossMaxHp => boss?.maxHp ?? 0;

  /// Фаза босса
  BossPhase get bossPhase => boss?.phase ?? BossPhase.idle;

  /// Создаёт копию с изменёнными полями
  BossState copyWith({
    BossEntity? boss,
    bool? isAttacking,
    int? lastDamage,
    bool? showDamageAnimation,
    bool? showBossAttackAnimation,
    bool? isVictory,
    bool? isDefeat,
    String? bossMessage,
    bool clearBoss = false,
    bool clearMessage = false,
  }) {
    return BossState(
      boss: clearBoss ? null : (boss ?? this.boss),
      isAttacking: isAttacking ?? this.isAttacking,
      lastDamage: lastDamage ?? this.lastDamage,
      showDamageAnimation: showDamageAnimation ?? this.showDamageAnimation,
      showBossAttackAnimation:
          showBossAttackAnimation ?? this.showBossAttackAnimation,
      isVictory: isVictory ?? this.isVictory,
      isDefeat: isDefeat ?? this.isDefeat,
      bossMessage: clearMessage ? null : (bossMessage ?? this.bossMessage),
    );
  }

  /// Применяет урон к боссу
  BossState dealDamage(int damage) {
    if (boss == null) return this;

    final damagedBoss = boss!.takeDamage(damage);

    return copyWith(
      boss: damagedBoss,
      lastDamage: damage,
      showDamageAnimation: true,
      isVictory: damagedBoss.isDefeated,
    );
  }

  /// Сбрасывает анимации
  BossState clearAnimations() {
    return copyWith(
      showDamageAnimation: false,
      showBossAttackAnimation: false,
    );
  }

  /// Сбрасывает состояние для нового боя
  BossState reset() {
    return const BossState();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BossState &&
        other.boss == boss &&
        other.isAttacking == isAttacking &&
        other.lastDamage == lastDamage &&
        other.showDamageAnimation == showDamageAnimation &&
        other.showBossAttackAnimation == showBossAttackAnimation &&
        other.isVictory == isVictory &&
        other.isDefeat == isDefeat &&
        other.bossMessage == bossMessage;
  }

  @override
  int get hashCode {
    return Object.hash(
      boss,
      isAttacking,
      lastDamage,
      showDamageAnimation,
      showBossAttackAnimation,
      isVictory,
      isDefeat,
      bossMessage,
    );
  }

  @override
  String toString() {
    return 'BossState(boss: ${boss?.name}, hp: $bossCurrentHp/$bossMaxHp, '
        'attacking: $isAttacking, victory: $isVictory)';
  }
}
