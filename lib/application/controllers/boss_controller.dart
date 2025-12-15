/// Контроллер босса
///
/// Управляет состоянием битвы с боссом.
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/game_constants.dart';
import '../../data/models/boss_model.dart';
import '../../domain/entities/boss_entity.dart';
import '../services/combo_service.dart';
import '../services/reward_service.dart';
import '../state/boss_state.dart';

/// Контроллер босса
class BossController extends Notifier<BossState> {
  Timer? _attackTimer;
  final ComboService _comboService = ComboService();
  final RewardService _rewardService = RewardService();

  @override
  BossState build() {
    ref.onDispose(() {
      _attackTimer?.cancel();
    });
    return BossState.initial();
  }

  /// Инициализирует босса для мира
  void initBoss(int worldId) {
    final boss = BossModel.createForWorld(worldId);
    state = BossState.withBoss(boss);
    _comboService.resetSession();
  }

  /// Инициализирует босса напрямую
  void setBoss(BossEntity boss) {
    state = BossState.withBoss(boss);
    _comboService.resetSession();
  }

  /// Наносит урон боссу
  ///
  /// [baseDamage] - базовый урон (по умолчанию из констант)
  /// [combo] - текущее комбо для расчёта множителя
  /// [isFastAnswer] - был ли ответ быстрым
  void dealDamage({
    int? baseDamage,
    int combo = 0,
    bool isFastAnswer = false,
  }) {
    if (state.boss == null || state.isBossDefeated) return;

    // Рассчитываем урон
    final damage = _rewardService.calculateBossDamage(
      combo: combo,
      isFastAnswer: isFastAnswer,
    );

    final actualDamage = baseDamage ?? damage;

    // Применяем урон
    state = state.dealDamage(actualDamage);

    // Проверяем победу
    if (state.isBossDefeated) {
      _onBossDefeated();
    }
    // Проверяем переход в ярость
    else if (state.boss!.shouldEnterRage && !state.isBossInRage) {
      _enterRageMode();
    }
  }

  /// Запускает атаку босса
  void triggerAttack() {
    if (state.boss == null || state.isBossDefeated) return;

    state = state.copyWith(
      isAttacking: true,
      showBossAttackAnimation: true,
      boss: state.boss!.copyWith(phase: BossPhase.attack),
    );

    // Сбрасываем состояние атаки через время
    Future.delayed(
      Duration(milliseconds: AnimationConstants.bossAttackMs),
      () {
        if (state.isAttacking) {
          _endAttack();
        }
      },
    );
  }

  /// Завершает атаку
  void _endAttack() {
    if (state.boss == null) return;

    final newPhase = state.isBossInRage ? BossPhase.rage : BossPhase.idle;

    state = state.copyWith(
      isAttacking: false,
      showBossAttackAnimation: false,
      boss: state.boss!.copyWith(phase: newPhase),
    );
  }

  /// Переводит босса в режим ярости
  void _enterRageMode() {
    if (state.boss == null) return;

    state = state.copyWith(
      boss: state.boss!.copyWith(phase: BossPhase.rage),
      bossMessage: 'Босс в ярости!',
    );
  }

  /// Обработка победы над боссом
  void _onBossDefeated() {
    _attackTimer?.cancel();

    state = state.copyWith(
      isVictory: true,
      boss: state.boss?.copyWith(phase: BossPhase.defeat),
    );
  }

  /// Обработка поражения игрока
  void onPlayerDefeated() {
    _attackTimer?.cancel();

    state = state.copyWith(
      isDefeat: true,
    );
  }

  /// Запускает автоматические атаки босса
  void startAutoAttack() {
    _attackTimer?.cancel();

    // Интервал атак уменьшается в режиме ярости
    final interval = state.isBossInRage
        ? BossConstants.attackIntervalMs ~/ 2
        : BossConstants.attackIntervalMs;

    _attackTimer = Timer.periodic(
      Duration(milliseconds: interval),
      (_) {
        if (!state.isVictory && !state.isDefeat) {
          triggerAttack();
        }
      },
    );
  }

  /// Останавливает автоматические атаки
  void stopAutoAttack() {
    _attackTimer?.cancel();
    _attackTimer = null;
  }

  /// Регистрирует правильный ответ
  void onCorrectAnswer({int combo = 0, bool isFastAnswer = false}) {
    dealDamage(combo: combo, isFastAnswer: isFastAnswer);
    clearAnimations();
  }

  /// Регистрирует неправильный ответ
  void onWrongAnswer() {
    // Босс атакует при ошибке
    triggerAttack();
  }

  /// Очищает анимации
  void clearAnimations() {
    state = state.clearAnimations();
  }

  /// Устанавливает сообщение босса
  void setBossMessage(String message) {
    state = state.copyWith(bossMessage: message);
  }

  /// Очищает сообщение босса
  void clearBossMessage() {
    state = state.copyWith(clearMessage: true);
  }

  /// Переводит босса в состояние получения урона
  void showHurt() {
    if (state.boss == null) return;

    state = state.copyWith(
      boss: state.boss!.copyWith(phase: BossPhase.hurt),
      showDamageAnimation: true,
    );

    // Возвращаем в нормальное состояние
    Future.delayed(
      Duration(milliseconds: AnimationConstants.bossDamageMs),
      () {
        if (state.boss != null && state.boss!.phase == BossPhase.hurt) {
          final newPhase = state.isBossInRage ? BossPhase.rage : BossPhase.idle;
          state = state.copyWith(
            boss: state.boss!.copyWith(phase: newPhase),
            showDamageAnimation: false,
          );
        }
      },
    );
  }

  /// Побеждает босса (принудительно)
  void defeatBoss() {
    if (state.boss == null) return;

    state = state.copyWith(
      boss: state.boss!.copyWith(currentHp: 0, phase: BossPhase.defeat),
      isVictory: true,
    );

    _attackTimer?.cancel();
  }

  /// Сбрасывает состояние для нового боя
  void reset() {
    _attackTimer?.cancel();
    _comboService.resetSession();
    state = BossState.initial();
  }

  /// Восстанавливает босса (для повторной попытки)
  void restoreBoss() {
    if (state.boss == null) return;

    state = BossState.withBoss(state.boss!.reset());
    _comboService.resetSession();
  }

  /// Получает фразу насмешки босса
  String? getTauntPhrase() {
    if (state.boss is BossModel) {
      return (state.boss as BossModel).tauntPhrase;
    }
    return null;
  }

  /// Получает фразу поражения босса
  String? getDefeatPhrase() {
    if (state.boss is BossModel) {
      return (state.boss as BossModel).defeatPhrase;
    }
    return null;
  }
}

/// Provider для BossController
final bossControllerProvider =
    NotifierProvider<BossController, BossState>(BossController.new);
