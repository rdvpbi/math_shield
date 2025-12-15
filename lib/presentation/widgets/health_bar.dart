/// Виджет полосы здоровья
///
/// Отображает HP игрока или босса с анимацией и изменением цвета.
library;

import 'package:flutter/material.dart';

import '../../core/config/game_constants.dart';
import '../theme/app_colors.dart';

/// Виджет полосы здоровья
///
/// Отображает текущее здоровье относительно максимального.
/// Цвет меняется от зелёного к красному по мере уменьшения HP.
class HealthBar extends StatelessWidget {
  /// Текущее значение здоровья
  final int currentHealth;

  /// Максимальное значение здоровья
  final int maxHealth;

  /// Ширина полосы
  final double width;

  /// Высота полосы
  final double height;

  /// Показывать ли текст с числовым значением
  final bool showText;

  /// Размер шрифта для текста
  final double? fontSize;

  /// Длительность анимации в миллисекундах
  final int animationDurationMs;

  /// Радиус скругления
  final double borderRadius;

  /// Цвет фона
  final Color? backgroundColor;

  /// Цвет границы
  final Color? borderColor;

  /// Толщина границы
  final double borderWidth;

  const HealthBar({
    super.key,
    required this.currentHealth,
    required this.maxHealth,
    this.width = 200,
    this.height = 24,
    this.showText = true,
    this.fontSize,
    this.animationDurationMs = AnimationConstants.healthBarUpdateMs,
    this.borderRadius = UIConstants.borderRadiusSmall,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 2,
  });

  /// Создаёт маленькую полосу здоровья
  factory HealthBar.small({
    Key? key,
    required int currentHealth,
    required int maxHealth,
    bool showText = false,
  }) {
    return HealthBar(
      key: key,
      currentHealth: currentHealth,
      maxHealth: maxHealth,
      width: 100,
      height: 12,
      showText: showText,
      fontSize: 10,
      borderWidth: 1,
    );
  }

  /// Создаёт большую полосу здоровья
  factory HealthBar.large({
    Key? key,
    required int currentHealth,
    required int maxHealth,
    bool showText = true,
  }) {
    return HealthBar(
      key: key,
      currentHealth: currentHealth,
      maxHealth: maxHealth,
      width: 300,
      height: 32,
      showText: showText,
      fontSize: 16,
      borderWidth: 3,
    );
  }

  /// Создаёт полосу здоровья для босса
  factory HealthBar.boss({
    Key? key,
    required int currentHealth,
    required int maxHealth,
  }) {
    return HealthBar(
      key: key,
      currentHealth: currentHealth,
      maxHealth: maxHealth,
      width: double.infinity,
      height: 28,
      showText: true,
      fontSize: 14,
      borderWidth: 2,
      borderRadius: 8,
    );
  }

  @override
  Widget build(BuildContext context) {
    final percentage = maxHealth > 0 ? currentHealth / maxHealth : 0.0;
    final healthColor = AppColors.getHealthColor(percentage);
    final effectiveFontSize = fontSize ?? (height * 0.5);

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          // Фон
          Container(
            decoration: BoxDecoration(
              color: backgroundColor ?? AppColors.surface,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: borderColor ?? AppColors.border,
                width: borderWidth,
              ),
            ),
          ),

          // Заполнение
          ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius - borderWidth),
            child: Padding(
              padding: EdgeInsets.all(borderWidth),
              child: AnimatedContainer(
                duration: Duration(milliseconds: animationDurationMs),
                curve: Curves.easeOutCubic,
                width: (width - borderWidth * 2) * percentage.clamp(0.0, 1.0),
                height: height - borderWidth * 2,
                decoration: BoxDecoration(
                  gradient: _buildGradient(healthColor),
                  borderRadius: BorderRadius.circular(
                    borderRadius - borderWidth,
                  ),
                ),
              ),
            ),
          ),

          // Блики (декоративный элемент)
          Positioned(
            top: borderWidth + 2,
            left: borderWidth + 4,
            right: borderWidth + 4,
            child: Container(
              height: (height - borderWidth * 2) * 0.3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.3),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
                borderRadius: BorderRadius.circular(
                  borderRadius - borderWidth,
                ),
              ),
            ),
          ),

          // Текст
          if (showText)
            Center(
              child: Text(
                '$currentHealth / $maxHealth',
                style: TextStyle(
                  fontSize: effectiveFontSize,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textOnDark,
                  shadows: const [
                    Shadow(
                      color: Colors.black54,
                      blurRadius: 2,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  LinearGradient _buildGradient(Color color) {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        color.withValues(alpha: 1.0),
        color.withValues(alpha: 0.8),
      ],
    );
  }
}

/// Анимированный виджет полосы здоровья
///
/// Показывает анимацию при получении урона.
class AnimatedHealthBar extends StatefulWidget {
  /// Текущее значение здоровья
  final int currentHealth;

  /// Максимальное значение здоровья
  final int maxHealth;

  /// Ширина полосы
  final double width;

  /// Высота полосы
  final double height;

  /// Показывать ли текст
  final bool showText;

  /// Callback при достижении 0 HP
  final VoidCallback? onDepleted;

  const AnimatedHealthBar({
    super.key,
    required this.currentHealth,
    required this.maxHealth,
    this.width = 200,
    this.height = 24,
    this.showText = true,
    this.onDepleted,
  });

  @override
  State<AnimatedHealthBar> createState() => _AnimatedHealthBarState();
}

class _AnimatedHealthBarState extends State<AnimatedHealthBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  int _previousHealth = 0;

  @override
  void initState() {
    super.initState();
    _previousHealth = widget.currentHealth;

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _shakeAnimation = Tween<double>(
      begin: 0,
      end: 8,
    ).chain(CurveTween(curve: Curves.elasticOut)).animate(_shakeController);
  }

  @override
  void didUpdateWidget(AnimatedHealthBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Анимация при получении урона
    if (widget.currentHealth < _previousHealth) {
      _shakeController.forward(from: 0);
    }

    // Callback при достижении 0
    if (widget.currentHealth <= 0 && _previousHealth > 0) {
      widget.onDepleted?.call();
    }

    _previousHealth = widget.currentHealth;
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value * _shakeDirection, 0),
          child: child,
        );
      },
      child: HealthBar(
        currentHealth: widget.currentHealth,
        maxHealth: widget.maxHealth,
        width: widget.width,
        height: widget.height,
        showText: widget.showText,
      ),
    );
  }

  double get _shakeDirection {
    // Чередуем направление
    return (_shakeController.value * 10).floor().isEven ? 1 : -1;
  }
}

/// Вертикальная полоса здоровья
class VerticalHealthBar extends StatelessWidget {
  /// Текущее значение здоровья
  final int currentHealth;

  /// Максимальное значение здоровья
  final int maxHealth;

  /// Ширина полосы
  final double width;

  /// Высота полосы
  final double height;

  /// Показывать ли текст
  final bool showText;

  const VerticalHealthBar({
    super.key,
    required this.currentHealth,
    required this.maxHealth,
    this.width = 24,
    this.height = 200,
    this.showText = false,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = maxHealth > 0 ? currentHealth / maxHealth : 0.0;
    final healthColor = AppColors.getHealthColor(percentage);

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          // Фон
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(UIConstants.borderRadiusSmall),
              border: Border.all(
                color: AppColors.border,
                width: 2,
              ),
            ),
          ),

          // Заполнение (снизу вверх)
          Positioned(
            bottom: 2,
            left: 2,
            right: 2,
            child: AnimatedContainer(
              duration: const Duration(
                milliseconds: AnimationConstants.healthBarUpdateMs,
              ),
              curve: Curves.easeOutCubic,
              height: (height - 4) * percentage.clamp(0.0, 1.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    healthColor,
                    healthColor.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(
                  UIConstants.borderRadiusSmall - 2,
                ),
              ),
            ),
          ),

          // Текст
          if (showText)
            RotatedBox(
              quarterTurns: 3,
              child: Center(
                child: Text(
                  '$currentHealth',
                  style: TextStyle(
                    fontSize: width * 0.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textOnDark,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
