/// Виджет кнопки выбора мира
///
/// Отображает кнопку мира на хабе с состояниями: locked, unlocked, completed.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/config/game_constants.dart';
import '../../domain/entities/world_entity.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Кнопка выбора мира
class WorldButton extends StatefulWidget {
  /// Данные мира
  final WorldEntity world;

  /// Callback при нажатии
  final VoidCallback? onTap;

  /// Размер кнопки
  final double size;

  /// Показывать ли название
  final bool showName;

  /// Показывать ли звёзды
  final bool showStars;

  /// Показывать ли иконку босса
  final bool showBossIcon;

  const WorldButton({
    super.key,
    required this.world,
    this.onTap,
    this.size = UIConstants.worldButtonSize,
    this.showName = true,
    this.showStars = true,
    this.showBossIcon = true,
  });

  @override
  State<WorldButton> createState() => _WorldButtonState();
}

class _WorldButtonState extends State<WorldButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Пульсация для незавершённых разблокированных миров
    if (widget.world.isUnlocked && !widget.world.isCompleted) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(WorldButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.world.isUnlocked &&
        !widget.world.isCompleted &&
        !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (widget.world.isCompleted && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.value = 0;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.world.isUnlocked ? (_) => _onTapDown() : null,
      onTapUp: widget.world.isUnlocked ? (_) => _onTapUp() : null,
      onTapCancel: widget.world.isUnlocked ? _onTapCancel : null,
      onTap: widget.world.isUnlocked ? _onTap : null,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _isPressed ? 0.95 : _pulseAnimation.value,
            child: child,
          );
        },
        child: _buildButton(),
      ),
    );
  }

  Widget _buildButton() {
    final worldColors = WorldPalettes.getWorld(widget.world.id);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Основная кнопка
        Container(
          width: widget.size,
          height: widget.size,
          decoration: _buildDecoration(worldColors),
          child: Stack(
            children: [
              // Контент кнопки
              Center(child: _buildContent(worldColors)),

              // Иконка босса
              if (widget.showBossIcon) _buildBossIcon(worldColors),

              // Оверлей для заблокированного мира
              if (!widget.world.isUnlocked) _buildLockedOverlay(),
            ],
          ),
        ),

        // Название мира
        if (widget.showName) ...[
          const SizedBox(height: UIConstants.paddingSmall),
          _buildName(),
        ],

        // Звёзды
        if (widget.showStars && widget.world.isCompleted) ...[
          const SizedBox(height: UIConstants.paddingSmall / 2),
          _buildStars(),
        ],
      ],
    );
  }

  BoxDecoration _buildDecoration(WorldColors worldColors) {
    if (!widget.world.isUnlocked) {
      // Заблокированный мир
      return BoxDecoration(
        color: AppColors.locked,
        borderRadius: BorderRadius.circular(UIConstants.borderRadiusLarge),
        border: Border.all(
          color: AppColors.border,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      );
    }

    if (widget.world.isCompleted) {
      // Пройденный мир
      return BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            worldColors.primary,
            worldColors.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(UIConstants.borderRadiusLarge),
        border: Border.all(
          color: AppColors.success,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      );
    }

    // Разблокированный, но не пройденный
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          worldColors.primary,
          worldColors.secondary,
        ],
      ),
      borderRadius: BorderRadius.circular(UIConstants.borderRadiusLarge),
      border: Border.all(
        color: worldColors.primary,
        width: 3,
      ),
      boxShadow: [
        BoxShadow(
          color: worldColors.primary.withValues(alpha: 0.4),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Widget _buildContent(WorldColors worldColors) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Номер множителя
        Text(
          '×${widget.world.multiplier}',
          style: TextStyle(
            fontSize: widget.size * 0.35,
            fontWeight: FontWeight.bold,
            color: widget.world.isUnlocked
                ? AppColors.textOnDark
                : AppColors.textTertiary,
            shadows: widget.world.isUnlocked
                ? [
                    const Shadow(
                      color: Colors.black38,
                      blurRadius: 4,
                      offset: Offset(1, 1),
                    ),
                  ]
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildBossIcon(WorldColors worldColors) {
    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        width: widget.size * 0.25,
        height: widget.size * 0.25,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.world.bossDefeated
              ? AppColors.success
              : widget.world.isUnlocked
                  ? worldColors.boss.withValues(alpha: 0.8)
                  : AppColors.locked,
          border: Border.all(
            color: AppColors.textOnDark.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Icon(
          widget.world.bossDefeated
              ? Icons.check
              : Icons.mood_bad,
          size: widget.size * 0.15,
          color: AppColors.textOnDark,
        ),
      ),
    );
  }

  Widget _buildLockedOverlay() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(UIConstants.borderRadiusLarge),
      ),
      child: Center(
        child: Icon(
          Icons.lock,
          size: widget.size * 0.3,
          color: AppColors.textTertiary,
        ),
      ),
    );
  }

  Widget _buildName() {
    return SizedBox(
      width: widget.size,
      child: Text(
        widget.world.name,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: widget.world.isUnlocked
              ? AppColors.textPrimary
              : AppColors.textTertiary,
        ),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildStars() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        final isEarned = index < widget.world.stars;
        return Icon(
          isEarned ? Icons.star : Icons.star_border,
          size: 16,
          color: isEarned ? AppColors.star : AppColors.textTertiary,
        );
      }),
    );
  }

  void _onTapDown() {
    setState(() => _isPressed = true);
    HapticFeedback.lightImpact();
  }

  void _onTapUp() {
    setState(() => _isPressed = false);
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
  }

  void _onTap() {
    HapticFeedback.mediumImpact();
    widget.onTap?.call();
  }
}

/// Сетка миров для хаба
class WorldGrid extends StatelessWidget {
  /// Список миров
  final List<WorldEntity> worlds;

  /// Callback при выборе мира
  final ValueChanged<WorldEntity>? onWorldSelected;

  /// Количество колонок
  final int crossAxisCount;

  /// Размер кнопки мира
  final double buttonSize;

  const WorldGrid({
    super.key,
    required this.worlds,
    this.onWorldSelected,
    this.crossAxisCount = 5,
    this.buttonSize = UIConstants.worldButtonSize,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: UIConstants.paddingMedium,
        crossAxisSpacing: UIConstants.paddingMedium,
        childAspectRatio: 0.75, // Учитываем название и звёзды
      ),
      itemCount: worlds.length,
      itemBuilder: (context, index) {
        final world = worlds[index];
        return WorldButton(
          world: world,
          size: buttonSize,
          onTap: world.isUnlocked
              ? () => onWorldSelected?.call(world)
              : null,
        );
      },
    );
  }
}

/// Горизонтальный список миров
class WorldHorizontalList extends StatelessWidget {
  /// Список миров
  final List<WorldEntity> worlds;

  /// Callback при выборе мира
  final ValueChanged<WorldEntity>? onWorldSelected;

  /// Размер кнопки мира
  final double buttonSize;

  /// Высота списка
  final double height;

  const WorldHorizontalList({
    super.key,
    required this.worlds,
    this.onWorldSelected,
    this.buttonSize = UIConstants.worldButtonSize,
    this.height = 160,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: UIConstants.paddingMedium,
        ),
        itemCount: worlds.length,
        separatorBuilder: (_, __) => const SizedBox(
          width: UIConstants.paddingMedium,
        ),
        itemBuilder: (context, index) {
          final world = worlds[index];
          return WorldButton(
            world: world,
            size: buttonSize,
            onTap: world.isUnlocked
                ? () => onWorldSelected?.call(world)
                : null,
          );
        },
      ),
    );
  }
}

/// Маленькая карточка мира для отображения в списках
class WorldCard extends StatelessWidget {
  final WorldEntity world;
  final VoidCallback? onTap;

  const WorldCard({
    super.key,
    required this.world,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final worldColors = WorldPalettes.getWorld(world.id);

    return Card(
      color: world.isUnlocked ? worldColors.primary : AppColors.locked,
      child: InkWell(
        onTap: world.isUnlocked ? onTap : null,
        borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(UIConstants.paddingMedium),
          child: Row(
            children: [
              // Множитель
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surface.withValues(alpha: 0.3),
                ),
                child: Center(
                  child: Text(
                    '×${world.multiplier}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textOnDark,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: UIConstants.paddingMedium),

              // Информация
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      world.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textOnDark,
                      ),
                    ),
                    if (world.isCompleted) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          ...List.generate(3, (i) {
                            return Icon(
                              i < world.stars ? Icons.star : Icons.star_border,
                              size: 14,
                              color: AppColors.star,
                            );
                          }),
                          const SizedBox(width: 8),
                          Text(
                            'Лучший: ${world.bestScore}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textOnDark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Статус
              if (!world.isUnlocked)
                const Icon(
                  Icons.lock,
                  color: AppColors.textTertiary,
                )
              else if (world.bossDefeated)
                const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                )
              else
                const Icon(
                  Icons.play_arrow,
                  color: AppColors.textOnDark,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
