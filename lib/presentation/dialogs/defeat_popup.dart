/// Popup поражения
///
/// Отображается при проигрыше (потеря всех жизней или HP).
library;

import 'package:flutter/material.dart';

import '../../core/config/game_constants.dart';
import '../theme/app_colors.dart';
import '../widgets/filin_helper.dart';

/// Popup поражения
class DefeatPopup extends StatefulWidget {
  /// Заголовок
  final String title;

  /// Сообщение поддержки
  final String message;

  /// Набранный счёт
  final int score;

  /// Количество правильных ответов
  final int correctAnswers;

  /// Общее количество ответов
  final int totalAnswers;

  /// Оставшиеся жизни
  final int livesRemaining;

  /// Callback для кнопки "Повторить"
  final VoidCallback? onRetry;

  /// Callback для кнопки "В хаб"
  final VoidCallback? onToHub;

  /// Показывать ли Филина
  final bool showFilin;

  const DefeatPopup({
    super.key,
    this.title = 'Не получилось...',
    this.message = 'Не сдавайся! Каждая попытка делает тебя сильнее!',
    this.score = 0,
    this.correctAnswers = 0,
    this.totalAnswers = 0,
    this.livesRemaining = 0,
    this.onRetry,
    this.onToHub,
    this.showFilin = true,
  });

  /// Показывает popup
  static Future<void> show(
    BuildContext context, {
    String title = 'Не получилось...',
    String message = 'Не сдавайся! Каждая попытка делает тебя сильнее!',
    int score = 0,
    int correctAnswers = 0,
    int totalAnswers = 0,
    int livesRemaining = 0,
    VoidCallback? onRetry,
    VoidCallback? onToHub,
    bool showFilin = true,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => DefeatPopup(
        title: title,
        message: message,
        score: score,
        correctAnswers: correctAnswers,
        totalAnswers: totalAnswers,
        livesRemaining: livesRemaining,
        onRetry: onRetry,
        onToHub: onToHub ?? () => Navigator.of(context).pop(),
        showFilin: showFilin,
      ),
    );
  }

  @override
  State<DefeatPopup> createState() => _DefeatPopupState();
}

class _DefeatPopupState extends State<DefeatPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
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
                  AppColors.error.withValues(alpha: 0.15),
                  AppColors.surface,
                ],
              ),
              borderRadius: BorderRadius.circular(UIConstants.borderRadiusLarge),
              border: Border.all(
                color: AppColors.error.withValues(alpha: 0.5),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.error.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Филин или иконка
                if (widget.showFilin)
                  const FilinHelper(
                    mood: FilinMood.encouraging,
                    size: 80,
                  )
                else
                  _buildDefeatIcon(),

                const SizedBox(height: UIConstants.paddingMedium),

                // Заголовок
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: UIConstants.paddingSmall),

                // Сообщение поддержки
                Text(
                  widget.message,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: UIConstants.paddingLarge),

                // Статистика
                if (widget.totalAnswers > 0) ...[
                  _buildStats(),
                  const SizedBox(height: UIConstants.paddingLarge),
                ],

                // Жизни
                if (widget.livesRemaining > 0) ...[
                  _buildLivesInfo(),
                  const SizedBox(height: UIConstants.paddingLarge),
                ],

                // Кнопки
                _buildButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDefeatIcon() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.error.withValues(alpha: 0.2),
        border: Border.all(
          color: AppColors.error,
          width: 3,
        ),
      ),
      child: const Icon(
        Icons.sentiment_dissatisfied,
        size: 48,
        color: AppColors.error,
      ),
    );
  }

  Widget _buildStats() {
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
          _StatRow(
            icon: Icons.star,
            label: 'Счёт',
            value: widget.score.toString(),
          ),
          const SizedBox(height: 8),
          _StatRow(
            icon: Icons.check_circle,
            label: 'Точность',
            value: '$accuracy%',
            subtitle: '${widget.correctAnswers}/${widget.totalAnswers}',
          ),
        ],
      ),
    );
  }

  Widget _buildLivesInfo() {
    return Container(
      padding: const EdgeInsets.all(UIConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.favorite,
            color: AppColors.error,
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            'Осталось жизней: ${widget.livesRemaining}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    final canRetry = widget.livesRemaining > 0 && widget.onRetry != null;

    return Column(
      children: [
        if (canRetry)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  vertical: UIConstants.paddingMedium,
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.refresh),
                  SizedBox(width: 8),
                  Text(
                    'Попробовать снова',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

        if (canRetry) const SizedBox(height: UIConstants.paddingSmall),

        SizedBox(
          width: double.infinity,
          child: canRetry
              ? TextButton(
                  onPressed: widget.onToHub,
                  child: const Text('Вернуться в хаб'),
                )
              : ElevatedButton(
                  onPressed: widget.onToHub,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      vertical: UIConstants.paddingMedium,
                    ),
                  ),
                  child: const Text(
                    'Вернуться в хаб',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
        ),

        // Сообщение о жизнях
        if (!canRetry && widget.livesRemaining == 0) ...[
          const SizedBox(height: UIConstants.paddingMedium),
          const Text(
            'Жизни закончились. Подождите или купите больше!',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

/// Строка статистики
class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? subtitle;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(width: 4),
          Text(
            '($subtitle)',
            style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
          ),
        ],
      ],
    );
  }
}

/// Предустановленные сообщения поражения
abstract class DefeatMessages {
  static const List<String> encouragements = [
    'Не сдавайся! Каждая попытка делает тебя сильнее!',
    'Ты почти справился! Попробуй ещё разок!',
    'Даже самые великие герои иногда проигрывают. Главное - не сдаваться!',
    'Практика - путь к мастерству! Попробуй снова!',
    'Ты можешь! Я в тебя верю!',
    'С каждой попыткой ты становишься умнее!',
  ];

  static String getRandomEncouragement() {
    final index = DateTime.now().millisecond % encouragements.length;
    return encouragements[index];
  }

  static const String noLives =
      'Жизни закончились! Отдохни немного и возвращайся!';

  static const String timeUp =
      'Время вышло! В следующий раз будет быстрее!';

  static const String bossWon =
      'Босс оказался сильнее... Но ты точно сможешь его победить!';
}
