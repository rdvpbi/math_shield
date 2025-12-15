/// Popup паузы
///
/// Меню паузы с возможностью продолжить, перейти в настройки или выйти.
library;

import 'package:flutter/material.dart';

import '../../core/config/game_constants.dart';
import '../theme/app_colors.dart';

/// Popup паузы
class PausePopup extends StatefulWidget {
  /// Callback для кнопки "Продолжить"
  final VoidCallback? onResume;

  /// Callback для кнопки "Настройки"
  final VoidCallback? onSettings;

  /// Callback для кнопки "Выйти"
  final VoidCallback? onExit;

  /// Callback для кнопки "Перезапустить"
  final VoidCallback? onRestart;

  /// Показывать ли кнопку настроек
  final bool showSettings;

  /// Показывать ли кнопку перезапуска
  final bool showRestart;

  /// Текущий счёт (опционально)
  final int? currentScore;

  /// Название текущего мира (опционально)
  final String? worldName;

  const PausePopup({
    super.key,
    this.onResume,
    this.onSettings,
    this.onExit,
    this.onRestart,
    this.showSettings = true,
    this.showRestart = false,
    this.currentScore,
    this.worldName,
  });

  /// Показывает popup
  static Future<PauseAction?> show(
    BuildContext context, {
    VoidCallback? onResume,
    VoidCallback? onSettings,
    VoidCallback? onExit,
    VoidCallback? onRestart,
    bool showSettings = true,
    bool showRestart = false,
    int? currentScore,
    String? worldName,
  }) {
    return showDialog<PauseAction>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PausePopup(
        onResume: onResume ?? () => Navigator.of(context).pop(PauseAction.resume),
        onSettings: onSettings ?? () => Navigator.of(context).pop(PauseAction.settings),
        onExit: onExit ?? () => Navigator.of(context).pop(PauseAction.exit),
        onRestart: onRestart ?? () => Navigator.of(context).pop(PauseAction.restart),
        showSettings: showSettings,
        showRestart: showRestart,
        currentScore: currentScore,
        worldName: worldName,
      ),
    );
  }

  @override
  State<PausePopup> createState() => _PausePopupState();
}

class _PausePopupState extends State<PausePopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
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
            constraints: const BoxConstraints(maxWidth: 350),
            padding: const EdgeInsets.all(UIConstants.paddingLarge),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(UIConstants.borderRadiusLarge),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.5),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Иконка паузы
                _buildPauseIcon(),

                const SizedBox(height: UIConstants.paddingMedium),

                // Заголовок
                const Text(
                  'Пауза',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),

                // Информация о текущей игре
                if (widget.worldName != null || widget.currentScore != null) ...[
                  const SizedBox(height: UIConstants.paddingSmall),
                  _buildGameInfo(),
                ],

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

  Widget _buildPauseIcon() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withValues(alpha: 0.2),
        border: Border.all(
          color: AppColors.primary,
          width: 3,
        ),
      ),
      child: const Icon(
        Icons.pause,
        size: 40,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildGameInfo() {
    return Container(
      padding: const EdgeInsets.all(UIConstants.paddingSmall),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(UIConstants.borderRadiusSmall),
      ),
      child: Column(
        children: [
          if (widget.worldName != null)
            Text(
              widget.worldName!,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          if (widget.currentScore != null) ...[
            if (widget.worldName != null) const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.star,
                  size: 16,
                  color: AppColors.star,
                ),
                const SizedBox(width: 4),
                Text(
                  '${widget.currentScore}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Column(
      children: [
        // Продолжить
        _PauseButton(
          icon: Icons.play_arrow,
          label: 'Продолжить',
          color: AppColors.success,
          onPressed: widget.onResume,
        ),

        const SizedBox(height: UIConstants.paddingSmall),

        // Перезапустить
        if (widget.showRestart) ...[
          _PauseButton(
            icon: Icons.refresh,
            label: 'Начать заново',
            color: AppColors.warning,
            onPressed: widget.onRestart,
          ),
          const SizedBox(height: UIConstants.paddingSmall),
        ],

        // Настройки
        if (widget.showSettings) ...[
          _PauseButton(
            icon: Icons.settings,
            label: 'Настройки',
            color: AppColors.info,
            onPressed: widget.onSettings,
          ),
          const SizedBox(height: UIConstants.paddingSmall),
        ],

        // Выйти
        _PauseButton(
          icon: Icons.exit_to_app,
          label: 'Выйти в хаб',
          color: AppColors.error,
          onPressed: _confirmExit,
          outlined: true,
        ),
      ],
    );
  }

  void _confirmExit() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Выйти из игры?'),
        content: const Text(
          'Текущий прогресс уровня будет потерян.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onExit?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Выйти'),
          ),
        ],
      ),
    );
  }
}

/// Кнопка меню паузы
class _PauseButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onPressed;
  final bool outlined;

  const _PauseButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onPressed,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    if (outlined) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: color,
            side: BorderSide(color: color, width: 2),
            padding: const EdgeInsets.symmetric(
              vertical: UIConstants.paddingMedium,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 24),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(
            vertical: UIConstants.paddingMedium,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Действие из меню паузы
enum PauseAction {
  /// Продолжить игру
  resume,

  /// Открыть настройки
  settings,

  /// Выйти в хаб
  exit,

  /// Перезапустить уровень
  restart,
}
