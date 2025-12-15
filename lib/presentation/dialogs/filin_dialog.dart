/// Диалог с ментором Филином
///
/// Показывает сообщения от совы-помощника.
library;

import 'package:flutter/material.dart';

import '../../core/config/game_constants.dart';
import '../theme/app_colors.dart';
import '../widgets/filin_helper.dart';

/// Диалог с Филином
class FilinDialog extends StatefulWidget {
  /// Текст сообщения
  final String message;

  /// Заголовок (опционально)
  final String? title;

  /// Настроение Филина
  final FilinMood mood;

  /// Текст кнопки
  final String buttonText;

  /// Callback при закрытии
  final VoidCallback? onClose;

  /// Показывать ли анимацию появления
  final bool animate;

  const FilinDialog({
    super.key,
    required this.message,
    this.title,
    this.mood = FilinMood.neutral,
    this.buttonText = 'Понятно!',
    this.onClose,
    this.animate = true,
  });

  /// Показывает диалог
  static Future<void> show(
    BuildContext context, {
    required String message,
    String? title,
    FilinMood mood = FilinMood.neutral,
    String buttonText = 'Понятно!',
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => FilinDialog(
        message: message,
        title: title,
        mood: mood,
        buttonText: buttonText,
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  State<FilinDialog> createState() => _FilinDialogState();
}

class _FilinDialogState extends State<FilinDialog>
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
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _close() {
    _controller.reverse().then((_) {
      widget.onClose?.call();
    });
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
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(UIConstants.borderRadiusLarge),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.5),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Филин
                FilinHelper(
                  mood: widget.mood,
                  size: 80,
                  animate: widget.animate,
                ),

                const SizedBox(height: UIConstants.paddingMedium),

                // Заголовок
                if (widget.title != null) ...[
                  Text(
                    widget.title!,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: UIConstants.paddingSmall),
                ],

                // Сообщение
                Text(
                  widget.message,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: UIConstants.paddingLarge),

                // Кнопка
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _close,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                        vertical: UIConstants.paddingMedium,
                      ),
                    ),
                    child: Text(
                      widget.buttonText,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Диалог с несколькими страницами от Филина (туториал)
class FilinTutorialDialog extends StatefulWidget {
  /// Список сообщений
  final List<FilinTutorialPage> pages;

  /// Callback при завершении
  final VoidCallback? onComplete;

  /// Можно ли пропустить
  final bool canSkip;

  const FilinTutorialDialog({
    super.key,
    required this.pages,
    this.onComplete,
    this.canSkip = true,
  });

  /// Показывает туториал
  static Future<void> show(
    BuildContext context, {
    required List<FilinTutorialPage> pages,
    bool canSkip = true,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => FilinTutorialDialog(
        pages: pages,
        canSkip: canSkip,
        onComplete: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  State<FilinTutorialDialog> createState() => _FilinTutorialDialogState();
}

class _FilinTutorialDialogState extends State<FilinTutorialDialog> {
  int _currentPage = 0;

  void _nextPage() {
    if (_currentPage < widget.pages.length - 1) {
      setState(() => _currentPage++);
    } else {
      widget.onComplete?.call();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      setState(() => _currentPage--);
    }
  }

  void _skip() {
    widget.onComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    final page = widget.pages[_currentPage];
    final isLast = _currentPage == widget.pages.length - 1;
    final isFirst = _currentPage == 0;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(UIConstants.paddingLarge),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(UIConstants.borderRadiusLarge),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.5),
            width: 3,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Кнопка пропуска
            if (widget.canSkip)
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _skip,
                  child: const Text('Пропустить'),
                ),
              ),

            // Филин
            FilinHelper(
              mood: page.mood,
              size: 80,
              animate: false,
            ),

            const SizedBox(height: UIConstants.paddingMedium),

            // Заголовок
            if (page.title != null) ...[
              Text(
                page.title!,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: UIConstants.paddingSmall),
            ],

            // Сообщение
            Text(
              page.message,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: UIConstants.paddingLarge),

            // Индикатор страниц
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.pages.length, (index) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == _currentPage
                        ? AppColors.primary
                        : AppColors.textTertiary,
                  ),
                );
              }),
            ),

            const SizedBox(height: UIConstants.paddingMedium),

            // Кнопки навигации
            Row(
              children: [
                if (!isFirst)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousPage,
                      child: const Text('Назад'),
                    ),
                  ),
                if (!isFirst) const SizedBox(width: UIConstants.paddingSmall),
                Expanded(
                  flex: isFirst ? 1 : 1,
                  child: ElevatedButton(
                    onPressed: _nextPage,
                    child: Text(isLast ? 'Готово!' : 'Далее'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Страница туториала
class FilinTutorialPage {
  /// Заголовок
  final String? title;

  /// Сообщение
  final String message;

  /// Настроение Филина
  final FilinMood mood;

  const FilinTutorialPage({
    this.title,
    required this.message,
    this.mood = FilinMood.neutral,
  });
}

/// Предустановленные сообщения Филина
abstract class FilinMessages {
  // Приветствия
  static const String welcomeFirst =
      'Привет, юный математик! Я - Филин, твой мудрый помощник в мире чисел!';
  static const String welcomeBack =
      'Рад тебя снова видеть! Готов к новым приключениям?';

  // Подсказки
  static const String hintMultiply =
      'Помни: умножение - это когда мы складываем число несколько раз!';
  static const String hintZero =
      'Любое число, умноженное на 0, всегда равно 0!';
  static const String hintOne =
      'Любое число, умноженное на 1, остаётся таким же!';
  static const String hintCombo =
      'Чем больше правильных ответов подряд, тем сильнее удар!';

  // Поддержка
  static const String encourageAfterWrong =
      'Не переживай! Ошибки помогают нам учиться. Попробуй ещё раз!';
  static const String encourageStreak =
      'Отлично! Ты на верном пути!';
  static const String encourageBossDefeated =
      'Великолепно! Ты победил босса! Так держать!';

  // Инструкции
  static const String instructionBoss =
      'Решай примеры правильно, чтобы наносить урон боссу. Чем быстрее - тем лучше!';
  static const String instructionWorld =
      'В каждом мире ты будешь учить умножение на определённое число.';
}
