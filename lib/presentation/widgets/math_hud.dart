/// HUD для отображения математического примера
///
/// Включает текущий пример, таймер, комбо и счёт.
library;

import 'package:flutter/material.dart';

import '../../core/config/game_constants.dart';
import '../../domain/entities/example_task_entity.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// HUD для математической игры
class MathHud extends StatelessWidget {
  /// Текущий пример
  final ExampleTaskEntity? currentTask;

  /// Оставшееся время в секундах
  final int timeRemaining;

  /// Текущий счёт
  final int score;

  /// Текущее комбо
  final int combo;

  /// Множитель комбо
  final double comboMultiplier;

  /// Количество завершённых примеров
  final int tasksCompleted;

  /// Общее количество примеров
  final int totalTasks;

  /// Показывать ли прогресс
  final bool showProgress;

  /// Показывать ли счёт
  final bool showScore;

  /// Показывать ли комбо
  final bool showCombo;

  /// Показывать ли таймер
  final bool showTimer;

  const MathHud({
    super.key,
    this.currentTask,
    required this.timeRemaining,
    this.score = 0,
    this.combo = 0,
    this.comboMultiplier = 1.0,
    this.tasksCompleted = 0,
    this.totalTasks = WorldConstants.examplesPerLevel,
    this.showProgress = true,
    this.showScore = true,
    this.showCombo = true,
    this.showTimer = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(UIConstants.paddingMedium),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Верхняя панель: прогресс, счёт, комбо
          _buildTopBar(),

          const SizedBox(height: UIConstants.paddingLarge),

          // Пример
          _buildMathExpression(),

          if (showTimer) ...[
            const SizedBox(height: UIConstants.paddingMedium),

            // Таймер
            _buildTimer(),
          ],
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Прогресс
        if (showProgress)
          _ProgressIndicator(
            current: tasksCompleted,
            total: totalTasks,
          )
        else
          const SizedBox.shrink(),

        // Счёт
        if (showScore)
          _ScoreDisplay(score: score)
        else
          const SizedBox.shrink(),

        // Комбо
        if (showCombo)
          _ComboDisplay(
            combo: combo,
            multiplier: comboMultiplier,
          )
        else
          const SizedBox.shrink(),
      ],
    );
  }

  Widget _buildMathExpression() {
    if (currentTask == null) {
      return Container(
        padding: const EdgeInsets.all(UIConstants.paddingLarge),
        decoration: GameDecorations.mathCardDecoration,
        child: const Text(
          '...',
          style: GameStyles.mathExpressionStyle,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: UIConstants.paddingLarge * 2,
        vertical: UIConstants.paddingLarge,
      ),
      decoration: GameDecorations.mathCardDecoration,
      child: Text(
        currentTask!.formattedQuestion,
        style: GameStyles.mathExpressionStyle,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTimer() {
    final isCritical = timeRemaining <= TimeConstants.criticalTimeSeconds;
    final isWarning = timeRemaining <= TimeConstants.warningTimeSeconds;

    return _TimerDisplay(
      timeRemaining: timeRemaining,
      isCritical: isCritical,
      isWarning: isWarning,
    );
  }
}

/// Виджет отображения прогресса
class _ProgressIndicator extends StatelessWidget {
  final int current;
  final int total;

  const _ProgressIndicator({
    required this.current,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: UIConstants.paddingMedium,
        vertical: UIConstants.paddingSmall,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(UIConstants.borderRadiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: AppColors.success,
            size: UIConstants.iconSizeSmall,
          ),
          const SizedBox(width: UIConstants.paddingSmall),
          Text(
            '$current / $total',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Виджет отображения счёта
class _ScoreDisplay extends StatelessWidget {
  final int score;

  const _ScoreDisplay({required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: UIConstants.paddingMedium,
        vertical: UIConstants.paddingSmall,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(UIConstants.borderRadiusSmall),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star,
            color: AppColors.star,
            size: UIConstants.iconSizeSmall,
          ),
          const SizedBox(width: UIConstants.paddingSmall),
          Text(
            _formatScore(score),
            style: GameStyles.scoreStyle,
          ),
        ],
      ),
    );
  }

  String _formatScore(int value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toString();
  }
}

/// Виджет отображения комбо
class _ComboDisplay extends StatelessWidget {
  final int combo;
  final double multiplier;

  const _ComboDisplay({
    required this.combo,
    required this.multiplier,
  });

  @override
  Widget build(BuildContext context) {
    if (combo == 0) {
      return const SizedBox.shrink();
    }

    final comboColor = ComboColors.getColor(multiplier);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(
        horizontal: UIConstants.paddingMedium,
        vertical: UIConstants.paddingSmall,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            comboColor.withValues(alpha: 0.8),
            comboColor.withValues(alpha: 0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(UIConstants.borderRadiusSmall),
        boxShadow: [
          BoxShadow(
            color: comboColor.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department,
            color: AppColors.textOnDark,
            size: UIConstants.iconSizeSmall,
          ),
          const SizedBox(width: UIConstants.paddingSmall),
          Text(
            'x$combo',
            style: GameStyles.comboStyle.copyWith(
              color: AppColors.textOnDark,
            ),
          ),
          if (multiplier > 1.0) ...[
            const SizedBox(width: UIConstants.paddingSmall),
            Text(
              '(${multiplier.toStringAsFixed(1)}x)',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: AppColors.textOnDark,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Виджет отображения таймера
class _TimerDisplay extends StatelessWidget {
  final int timeRemaining;
  final bool isCritical;
  final bool isWarning;

  const _TimerDisplay({
    required this.timeRemaining,
    required this.isCritical,
    required this.isWarning,
  });

  @override
  Widget build(BuildContext context) {
    final color = isCritical
        ? AppColors.error
        : isWarning
            ? AppColors.warning
            : AppColors.textPrimary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(
        horizontal: UIConstants.paddingLarge,
        vertical: UIConstants.paddingSmall,
      ),
      decoration: BoxDecoration(
        color: isCritical
            ? AppColors.error.withValues(alpha: 0.2)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
        border: Border.all(
          color: color.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              isCritical ? Icons.warning : Icons.timer,
              key: ValueKey(isCritical),
              color: color,
              size: UIConstants.iconSizeMedium,
            ),
          ),
          const SizedBox(width: UIConstants.paddingSmall),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: (isCritical
                    ? GameStyles.timerCriticalStyle
                    : GameStyles.timerStyle)
                .copyWith(color: color),
            child: Text(
              _formatTime(timeRemaining),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    if (seconds >= 60) {
      final mins = seconds ~/ 60;
      final secs = seconds % 60;
      return '$mins:${secs.toString().padLeft(2, '0')}';
    }
    return '$seconds';
  }
}

/// Компактный HUD
class CompactMathHud extends StatelessWidget {
  /// Текущий пример
  final ExampleTaskEntity? currentTask;

  /// Оставшееся время
  final int timeRemaining;

  /// Комбо
  final int combo;

  const CompactMathHud({
    super.key,
    this.currentTask,
    required this.timeRemaining,
    this.combo = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(UIConstants.paddingSmall),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(UIConstants.borderRadiusSmall),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Пример
          Expanded(
            child: Text(
              currentTask?.formattedQuestion ?? '...',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Таймер
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: UIConstants.paddingSmall,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: timeRemaining <= TimeConstants.criticalTimeSeconds
                  ? AppColors.error.withValues(alpha: 0.3)
                  : AppColors.backgroundDark,
              borderRadius: BorderRadius.circular(UIConstants.borderRadiusSmall),
            ),
            child: Text(
              '$timeRemaining',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: timeRemaining <= TimeConstants.criticalTimeSeconds
                    ? AppColors.error
                    : AppColors.textPrimary,
              ),
            ),
          ),

          // Комбо
          if (combo > 0)
            Padding(
              padding: const EdgeInsets.only(left: UIConstants.paddingSmall),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: UIConstants.paddingSmall,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.combo.withValues(alpha: 0.3),
                  borderRadius:
                      BorderRadius.circular(UIConstants.borderRadiusSmall),
                ),
                child: Text(
                  'x$combo',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.combo,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Виджет результата ответа
class AnswerResultWidget extends StatelessWidget {
  /// Был ли ответ правильным
  final bool isCorrect;

  /// Полученные очки
  final int points;

  /// Показывать ли очки
  final bool showPoints;

  const AnswerResultWidget({
    super.key,
    required this.isCorrect,
    this.points = 0,
    this.showPoints = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(UIConstants.paddingMedium),
      decoration: BoxDecoration(
        color: isCorrect
            ? AppColors.success.withValues(alpha: 0.9)
            : AppColors.error.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
        boxShadow: [
          BoxShadow(
            color: (isCorrect ? AppColors.success : AppColors.error)
                .withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCorrect ? Icons.check_circle : Icons.cancel,
            color: AppColors.textOnDark,
            size: 48,
          ),
          const SizedBox(height: UIConstants.paddingSmall),
          Text(
            isCorrect ? 'Правильно!' : 'Неправильно',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textOnDark,
            ),
          ),
          if (showPoints && isCorrect && points > 0) ...[
            const SizedBox(height: UIConstants.paddingSmall),
            Text(
              '+$points',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.accent,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
