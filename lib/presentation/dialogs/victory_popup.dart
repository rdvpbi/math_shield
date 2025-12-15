/// Popup победы
///
/// Отображается при победе над боссом или завершении уровня.
library;

import 'package:flutter/material.dart';

import '../../core/config/game_constants.dart';
import '../theme/app_colors.dart';

/// Popup победы
class VictoryPopup extends StatefulWidget {
  /// Заголовок
  final String title;

  /// Количество звёзд (0-3)
  final int stars;

  /// Набранный счёт
  final int score;

  /// Лучший счёт (для сравнения)
  final int? bestScore;

  /// Количество правильных ответов
  final int correctAnswers;

  /// Общее количество ответов
  final int totalAnswers;

  /// Максимальное комбо
  final int maxCombo;

  /// Время прохождения в секундах
  final int? timeSeconds;

  /// Callback для кнопки "Дальше"
  final VoidCallback? onNext;

  /// Callback для кнопки "Повторить"
  final VoidCallback? onRetry;

  /// Callback для кнопки "В хаб"
  final VoidCallback? onToHub;

  /// Показывать ли кнопку "Дальше"
  final bool showNextButton;

  /// Текст кнопки "Дальше"
  final String nextButtonText;

  const VictoryPopup({
    super.key,
    this.title = 'Победа!',
    required this.stars,
    required this.score,
    this.bestScore,
    required this.correctAnswers,
    required this.totalAnswers,
    this.maxCombo = 0,
    this.timeSeconds,
    this.onNext,
    this.onRetry,
    this.onToHub,
    this.showNextButton = true,
    this.nextButtonText = 'Дальше',
  });

  /// Показывает popup
  static Future<void> show(
    BuildContext context, {
    String title = 'Победа!',
    required int stars,
    required int score,
    int? bestScore,
    required int correctAnswers,
    required int totalAnswers,
    int maxCombo = 0,
    int? timeSeconds,
    VoidCallback? onNext,
    VoidCallback? onRetry,
    VoidCallback? onToHub,
    bool showNextButton = true,
    String nextButtonText = 'Дальше',
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => VictoryPopup(
        title: title,
        stars: stars,
        score: score,
        bestScore: bestScore,
        correctAnswers: correctAnswers,
        totalAnswers: totalAnswers,
        maxCombo: maxCombo,
        timeSeconds: timeSeconds,
        onNext: onNext ?? () => Navigator.of(context).pop(),
        onRetry: onRetry,
        onToHub: onToHub ?? () => Navigator.of(context).pop(),
        showNextButton: showNextButton,
        nextButtonText: nextButtonText,
      ),
    );
  }

  @override
  State<VictoryPopup> createState() => _VictoryPopupState();
}

class _VictoryPopupState extends State<VictoryPopup>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _starsController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _starsController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward().then((_) {
      _starsController.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _starsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(UIConstants.paddingLarge),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.success.withValues(alpha: 0.2),
                  AppColors.surface,
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
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Иконка победы
                _buildVictoryIcon(),

                const SizedBox(height: UIConstants.paddingMedium),

                // Заголовок
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),

                const SizedBox(height: UIConstants.paddingMedium),

                // Звёзды
                _buildStars(),

                const SizedBox(height: UIConstants.paddingLarge),

                // Статистика
                _buildStats(),

                const SizedBox(height: UIConstants.paddingLarge),

                // Кнопки
                _buildButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVictoryIcon() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.success,
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withValues(alpha: 0.5),
            blurRadius: 16,
            spreadRadius: 4,
          ),
        ],
      ),
      child: const Icon(
        Icons.emoji_events,
        size: 48,
        color: Colors.white,
      ),
    );
  }

  Widget _buildStars() {
    return AnimatedBuilder(
      animation: _starsController,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final delay = index * 0.3;
            final progress = ((_starsController.value - delay) / 0.4).clamp(0.0, 1.0);
            final isEarned = index < widget.stars;

            return Transform.scale(
              scale: isEarned ? Curves.elasticOut.transform(progress) : 1.0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  isEarned ? Icons.star : Icons.star_border,
                  size: 48,
                  color: isEarned ? AppColors.star : AppColors.textTertiary,
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildStats() {
    final isNewBest = widget.bestScore != null && widget.score > widget.bestScore!;
    final accuracy = widget.totalAnswers > 0
        ? (widget.correctAnswers / widget.totalAnswers * 100).round()
        : 0;

    return Container(
      padding: const EdgeInsets.all(UIConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
      ),
      child: Column(
        children: [
          // Счёт
          _StatRow(
            icon: Icons.star,
            label: 'Счёт',
            value: widget.score.toString(),
            highlight: isNewBest,
            suffix: isNewBest ? ' (Новый рекорд!)' : null,
          ),

          if (widget.bestScore != null && !isNewBest) ...[
            const SizedBox(height: 8),
            _StatRow(
              icon: Icons.emoji_events,
              label: 'Лучший',
              value: widget.bestScore.toString(),
            ),
          ],

          const SizedBox(height: 8),

          // Точность
          _StatRow(
            icon: Icons.check_circle,
            label: 'Точность',
            value: '$accuracy%',
            subtitle: '${widget.correctAnswers}/${widget.totalAnswers}',
          ),

          if (widget.maxCombo > 0) ...[
            const SizedBox(height: 8),
            _StatRow(
              icon: Icons.local_fire_department,
              label: 'Макс. комбо',
              value: 'x${widget.maxCombo}',
              iconColor: AppColors.combo,
            ),
          ],

          if (widget.timeSeconds != null) ...[
            const SizedBox(height: 8),
            _StatRow(
              icon: Icons.timer,
              label: 'Время',
              value: _formatTime(widget.timeSeconds!),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Column(
      children: [
        // Кнопка "Дальше" или "Повторить"
        if (widget.showNextButton)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                padding: const EdgeInsets.symmetric(
                  vertical: UIConstants.paddingMedium,
                ),
              ),
              child: Text(
                widget.nextButtonText,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

        const SizedBox(height: UIConstants.paddingSmall),

        // Дополнительные кнопки
        Row(
          children: [
            if (widget.onRetry != null)
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onRetry,
                  child: const Text('Повторить'),
                ),
              ),
            if (widget.onRetry != null && widget.onToHub != null)
              const SizedBox(width: UIConstants.paddingSmall),
            if (widget.onToHub != null)
              Expanded(
                child: TextButton(
                  onPressed: widget.onToHub,
                  child: const Text('В хаб'),
                ),
              ),
          ],
        ),
      ],
    );
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    if (mins > 0) {
      return '$mins:${secs.toString().padLeft(2, '0')}';
    }
    return '${secs}с';
  }
}

/// Строка статистики
class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? subtitle;
  final String? suffix;
  final bool highlight;
  final Color? iconColor;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    this.subtitle,
    this.suffix,
    this.highlight = false,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: iconColor ?? AppColors.textSecondary,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: highlight ? AppColors.accent : AppColors.textPrimary,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(width: 4),
          Text(
            '($subtitle)',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textTertiary,
            ),
          ),
        ],
        if (suffix != null)
          Text(
            suffix!,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.accent,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }
}
