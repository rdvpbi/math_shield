/// Виджет босса
///
/// Отображает босса с анимациями по фазам (idle, attack, hurt, rage, defeat).
library;

import 'package:flutter/material.dart';

import '../../core/config/game_constants.dart';
import '../../domain/entities/boss_entity.dart';
import '../theme/app_colors.dart';
import 'health_bar.dart';

/// Виджет босса
class BossWidget extends StatefulWidget {
  /// Данные босса
  final BossEntity boss;

  /// Показывать ли health bar
  final bool showHealthBar;

  /// Показывать ли имя босса
  final bool showName;

  /// Показывать ли сообщение босса
  final String? message;

  /// Callback при завершении анимации поражения
  final VoidCallback? onDefeatAnimationComplete;

  /// Размер виджета
  final double size;

  const BossWidget({
    super.key,
    required this.boss,
    this.showHealthBar = true,
    this.showName = true,
    this.message,
    this.onDefeatAnimationComplete,
    this.size = 200,
  });

  @override
  State<BossWidget> createState() => _BossWidgetState();
}

class _BossWidgetState extends State<BossWidget>
    with TickerProviderStateMixin {
  late AnimationController _idleController;
  late AnimationController _attackController;
  late AnimationController _hurtController;
  late AnimationController _rageController;
  late AnimationController _defeatController;

  late Animation<double> _idleAnimation;
  late Animation<double> _attackAnimation;
  late Animation<double> _hurtAnimation;
  late Animation<double> _rageAnimation;
  late Animation<double> _defeatAnimation;

  BossPhase _previousPhase = BossPhase.idle;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startIdleAnimation();
  }

  void _initAnimations() {
    // Idle - плавное покачивание
    _idleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _idleAnimation = Tween<double>(begin: -5, end: 5).animate(
      CurvedAnimation(parent: _idleController, curve: Curves.easeInOut),
    );

    // Attack - рывок вперёд
    _attackController = AnimationController(
      duration: Duration(milliseconds: AnimationConstants.bossAttackMs),
      vsync: this,
    );
    _attackAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 30), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 30, end: 0), weight: 70),
    ]).animate(CurvedAnimation(
      parent: _attackController,
      curve: Curves.easeOut,
    ));

    // Hurt - отскок назад и тряска
    _hurtController = AnimationController(
      duration: Duration(milliseconds: AnimationConstants.bossDamageMs),
      vsync: this,
    );
    _hurtAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -20), weight: 20),
      TweenSequenceItem(tween: Tween(begin: -20, end: 10), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 10, end: -5), weight: 20),
      TweenSequenceItem(tween: Tween(begin: -5, end: 0), weight: 40),
    ]).animate(CurvedAnimation(
      parent: _hurtController,
      curve: Curves.easeOut,
    ));

    // Rage - пульсация и тряска
    _rageController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _rageAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _rageController, curve: Curves.easeInOut),
    );

    // Defeat - падение и исчезновение
    _defeatController = AnimationController(
      duration: Duration(milliseconds: AnimationConstants.bossDefeatMs),
      vsync: this,
    );
    _defeatAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _defeatController, curve: Curves.easeIn),
    );

    _defeatController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onDefeatAnimationComplete?.call();
      }
    });
  }

  void _startIdleAnimation() {
    _idleController.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(BossWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.boss.phase != _previousPhase) {
      _handlePhaseChange(widget.boss.phase);
      _previousPhase = widget.boss.phase;
    }
  }

  void _handlePhaseChange(BossPhase newPhase) {
    // Останавливаем все анимации кроме idle
    _attackController.reset();
    _hurtController.reset();

    switch (newPhase) {
      case BossPhase.idle:
        _rageController.reset();
        if (!_idleController.isAnimating) {
          _startIdleAnimation();
        }
        break;

      case BossPhase.attack:
        _attackController.forward(from: 0);
        break;

      case BossPhase.hurt:
        _hurtController.forward(from: 0);
        break;

      case BossPhase.rage:
        _rageController.repeat(reverse: true);
        break;

      case BossPhase.defeat:
        _idleController.stop();
        _rageController.stop();
        _defeatController.forward(from: 0);
        break;
    }
  }

  @override
  void dispose() {
    _idleController.dispose();
    _attackController.dispose();
    _hurtController.dispose();
    _rageController.dispose();
    _defeatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Имя босса
        if (widget.showName) ...[
          _buildBossName(),
          const SizedBox(height: UIConstants.paddingSmall),
        ],

        // Health bar
        if (widget.showHealthBar) ...[
          SizedBox(
            width: widget.size,
            child: HealthBar.boss(
              currentHealth: widget.boss.currentHp,
              maxHealth: widget.boss.maxHp,
            ),
          ),
          const SizedBox(height: UIConstants.paddingMedium),
        ],

        // Босс
        _buildBossSprite(),

        // Сообщение босса
        if (widget.message != null) ...[
          const SizedBox(height: UIConstants.paddingMedium),
          _buildBossMessage(),
        ],
      ],
    );
  }

  Widget _buildBossName() {
    final isRage = widget.boss.phase == BossPhase.rage;

    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 200),
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: isRage ? AppColors.error : AppColors.textPrimary,
      ),
      child: Text(widget.boss.name),
    );
  }

  Widget _buildBossSprite() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _idleController,
        _attackController,
        _hurtController,
        _rageController,
        _defeatController,
      ]),
      builder: (context, child) {
        double translateY = 0;
        double translateX = 0;
        double scale = 1.0;
        double opacity = 1.0;
        double rotation = 0;

        // Применяем анимации в зависимости от фазы
        switch (widget.boss.phase) {
          case BossPhase.idle:
            translateY = _idleAnimation.value;
            break;

          case BossPhase.attack:
            translateX = _attackAnimation.value;
            break;

          case BossPhase.hurt:
            translateX = _hurtAnimation.value;
            break;

          case BossPhase.rage:
            scale = _rageAnimation.value;
            // Добавляем тряску
            translateX = (_rageController.value * 10 - 5) *
                ((_rageController.value * 100).toInt() % 2 == 0 ? 1 : -1);
            break;

          case BossPhase.defeat:
            opacity = 1 - _defeatAnimation.value;
            translateY = _defeatAnimation.value * 100;
            rotation = _defeatAnimation.value * 0.5;
            scale = 1 - _defeatAnimation.value * 0.3;
            break;
        }

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..translate(translateX, translateY)
            ..scale(scale)
            ..rotateZ(rotation),
          child: Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: _BossAvatar(
        boss: widget.boss,
        size: widget.size,
      ),
    );
  }

  Widget _buildBossMessage() {
    return Container(
      constraints: BoxConstraints(maxWidth: widget.size * 1.5),
      padding: const EdgeInsets.all(UIConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
        border: Border.all(
          color: widget.boss.phase == BossPhase.rage
              ? AppColors.error
              : AppColors.border,
          width: 2,
        ),
      ),
      child: Text(
        widget.message!,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: widget.boss.phase == BossPhase.rage
              ? AppColors.error
              : AppColors.textPrimary,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// Аватар босса (заглушка для спрайта)
class _BossAvatar extends StatelessWidget {
  final BossEntity boss;
  final double size;

  const _BossAvatar({
    required this.boss,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final worldColor = WorldPalettes.getBossColor(boss.worldId);
    final isRage = boss.phase == BossPhase.rage;
    final isHurt = boss.phase == BossPhase.hurt;
    final isDefeat = boss.phase == BossPhase.defeat;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            isRage
                ? AppColors.error
                : isHurt
                    ? AppColors.warning
                    : worldColor,
            isRage
                ? AppColors.errorDark
                : isHurt
                    ? AppColors.warningDark
                    : worldColor.withValues(alpha: 0.7),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: (isRage ? AppColors.error : worldColor)
                .withValues(alpha: 0.5),
            blurRadius: isRage ? 24 : 16,
            spreadRadius: isRage ? 4 : 0,
          ),
        ],
        border: Border.all(
          color: isRage
              ? AppColors.error
              : isHurt
                  ? AppColors.warning
                  : worldColor,
          width: 4,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Иконка босса
            Icon(
              _getBossIcon(),
              size: size * 0.4,
              color: isDefeat
                  ? AppColors.textTertiary
                  : AppColors.textOnDark,
            ),

            const SizedBox(height: 4),

            // Номер мира (множитель)
            Text(
              '×${boss.worldId}',
              style: TextStyle(
                fontSize: size * 0.15,
                fontWeight: FontWeight.bold,
                color: AppColors.textOnDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getBossIcon() {
    switch (boss.phase) {
      case BossPhase.idle:
        return Icons.mood_bad;
      case BossPhase.attack:
        return Icons.flash_on;
      case BossPhase.hurt:
        return Icons.sentiment_very_dissatisfied;
      case BossPhase.rage:
        return Icons.whatshot;
      case BossPhase.defeat:
        return Icons.sentiment_very_dissatisfied;
    }
  }
}

/// Компактный виджет босса для списков
class BossListTile extends StatelessWidget {
  final BossEntity boss;
  final VoidCallback? onTap;
  final bool isDefeated;

  const BossListTile({
    super.key,
    required this.boss,
    this.onTap,
    this.isDefeated = false,
  });

  @override
  Widget build(BuildContext context) {
    final worldColor = WorldPalettes.getBossColor(boss.worldId);

    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDefeated ? AppColors.success : worldColor,
        ),
        child: Icon(
          isDefeated ? Icons.check : Icons.mood_bad,
          color: AppColors.textOnDark,
        ),
      ),
      title: Text(
        boss.name,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isDefeated ? AppColors.textSecondary : AppColors.textPrimary,
          decoration: isDefeated ? TextDecoration.lineThrough : null,
        ),
      ),
      subtitle: Text(
        'HP: ${boss.maxHp}',
        style: const TextStyle(color: AppColors.textTertiary),
      ),
      trailing: isDefeated
          ? const Icon(Icons.check_circle, color: AppColors.success)
          : Icon(Icons.chevron_right, color: worldColor),
    );
  }
}

/// Индикатор фазы босса
class BossPhaseIndicator extends StatelessWidget {
  final BossPhase phase;
  final double size;

  const BossPhaseIndicator({
    super.key,
    required this.phase,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getPhaseColor(),
      ),
      child: Icon(
        _getPhaseIcon(),
        size: size * 0.6,
        color: AppColors.textOnDark,
      ),
    );
  }

  Color _getPhaseColor() {
    switch (phase) {
      case BossPhase.idle:
        return AppColors.info;
      case BossPhase.attack:
        return AppColors.warning;
      case BossPhase.hurt:
        return AppColors.success;
      case BossPhase.rage:
        return AppColors.error;
      case BossPhase.defeat:
        return AppColors.textTertiary;
    }
  }

  IconData _getPhaseIcon() {
    switch (phase) {
      case BossPhase.idle:
        return Icons.remove;
      case BossPhase.attack:
        return Icons.flash_on;
      case BossPhase.hurt:
        return Icons.heart_broken;
      case BossPhase.rage:
        return Icons.whatshot;
      case BossPhase.defeat:
        return Icons.close;
    }
  }
}
