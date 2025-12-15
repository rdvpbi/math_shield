/// Виджет помощника Филина
///
/// Сова-ментор, которая даёт подсказки и поддерживает игрока.
library;

import 'package:flutter/material.dart';

import '../../core/config/game_constants.dart';
import '../theme/app_colors.dart';

/// Настроение Филина
enum FilinMood {
  /// Нейтральное
  neutral,

  /// Радостный
  happy,

  /// Думающий
  thinking,

  /// Ободряющий
  encouraging,

  /// Удивлённый
  surprised,

  /// Грустный (при ошибке)
  sad,
}

/// Виджет помощника Филина
class FilinHelper extends StatefulWidget {
  /// Текст подсказки
  final String? message;

  /// Настроение
  final FilinMood mood;

  /// Размер
  final double size;

  /// Показывать ли анимацию появления
  final bool animate;

  /// Callback при нажатии
  final VoidCallback? onTap;

  /// Длительность показа сообщения (0 = бесконечно)
  final Duration? messageDuration;

  /// Callback при скрытии сообщения
  final VoidCallback? onMessageDismiss;

  const FilinHelper({
    super.key,
    this.message,
    this.mood = FilinMood.neutral,
    this.size = 100,
    this.animate = true,
    this.onTap,
    this.messageDuration,
    this.onMessageDismiss,
  });

  @override
  State<FilinHelper> createState() => _FilinHelperState();
}

class _FilinHelperState extends State<FilinHelper>
    with TickerProviderStateMixin {
  late AnimationController _appearController;
  late AnimationController _idleController;
  late AnimationController _blinkController;

  late Animation<double> _appearAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _blinkAnimation;

  bool _showMessage = false;

  @override
  void initState() {
    super.initState();

    // Анимация появления
    _appearController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _appearAnimation = CurvedAnimation(
      parent: _appearController,
      curve: Curves.elasticOut,
    );

    // Анимация покачивания (idle)
    _idleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _floatAnimation = Tween<double>(begin: -5, end: 5).animate(
      CurvedAnimation(parent: _idleController, curve: Curves.easeInOut),
    );
    _idleController.repeat(reverse: true);

    // Анимация моргания
    _blinkController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _blinkAnimation = Tween<double>(begin: 1, end: 0.1).animate(
      CurvedAnimation(parent: _blinkController, curve: Curves.easeInOut),
    );

    // Периодическое моргание
    _startBlinking();

    if (widget.animate) {
      _appearController.forward();
    } else {
      _appearController.value = 1.0;
    }

    if (widget.message != null) {
      _showMessage = true;
      _scheduleMessageDismiss();
    }
  }

  void _startBlinking() {
    Future.delayed(Duration(milliseconds: 2000 + (1000 * (DateTime.now().millisecond % 3))), () {
      if (mounted) {
        _blinkController.forward().then((_) {
          _blinkController.reverse().then((_) {
            _startBlinking();
          });
        });
      }
    });
  }

  void _scheduleMessageDismiss() {
    if (widget.messageDuration != null &&
        widget.messageDuration!.inMilliseconds > 0) {
      Future.delayed(widget.messageDuration!, () {
        if (mounted) {
          setState(() => _showMessage = false);
          widget.onMessageDismiss?.call();
        }
      });
    }
  }

  @override
  void didUpdateWidget(FilinHelper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.message != oldWidget.message && widget.message != null) {
      setState(() => _showMessage = true);
      _scheduleMessageDismiss();
    }
  }

  @override
  void dispose() {
    _appearController.dispose();
    _idleController.dispose();
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_appearAnimation, _floatAnimation]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: Transform.scale(
            scale: _appearAnimation.value,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Пузырь с сообщением
            if (_showMessage && widget.message != null) ...[
              _buildMessageBubble(),
              const SizedBox(height: 8),
            ],

            // Филин
            _buildFilin(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: _showMessage ? 1.0 : 0.0,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: widget.size * 2.5,
        ),
        padding: const EdgeInsets.all(UIConstants.paddingMedium),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.message!,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilin() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            _getMoodColor().withValues(alpha: 0.9),
            _getMoodColor().withValues(alpha: 0.6),
          ],
        ),
        border: Border.all(
          color: _getMoodColor(),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: _getMoodColor().withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Тело совы
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Глаза
                _buildEyes(),

                const SizedBox(height: 4),

                // Клюв
                _buildBeak(),
              ],
            ),
          ),

          // Шапочка мудреца
          Positioned(
            top: 0,
            left: widget.size * 0.2,
            right: widget.size * 0.2,
            child: _buildHat(),
          ),
        ],
      ),
    );
  }

  Widget _buildEyes() {
    return AnimatedBuilder(
      animation: _blinkAnimation,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildEye(_blinkAnimation.value),
            SizedBox(width: widget.size * 0.1),
            _buildEye(_blinkAnimation.value),
          ],
        );
      },
    );
  }

  Widget _buildEye(double openness) {
    final eyeSize = widget.size * 0.2;

    return Container(
      width: eyeSize,
      height: eyeSize * openness,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(eyeSize / 2),
        border: Border.all(
          color: Colors.black87,
          width: 2,
        ),
      ),
      child: openness > 0.5
          ? Center(
              child: Container(
                width: eyeSize * 0.4,
                height: eyeSize * 0.4,
                decoration: const BoxDecoration(
                  color: Colors.black87,
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildBeak() {
    return CustomPaint(
      size: Size(widget.size * 0.15, widget.size * 0.1),
      painter: _BeakPainter(color: Colors.orange),
    );
  }

  Widget _buildHat() {
    return CustomPaint(
      size: Size(widget.size * 0.6, widget.size * 0.25),
      painter: _HatPainter(color: AppColors.primary),
    );
  }

  Color _getMoodColor() {
    switch (widget.mood) {
      case FilinMood.neutral:
        return AppColors.primary;
      case FilinMood.happy:
        return AppColors.success;
      case FilinMood.thinking:
        return AppColors.info;
      case FilinMood.encouraging:
        return AppColors.accent;
      case FilinMood.surprised:
        return AppColors.warning;
      case FilinMood.sad:
        return AppColors.textSecondary;
    }
  }
}

/// Painter для клюва совы
class _BeakPainter extends CustomPainter {
  final Color color;

  _BeakPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Painter для шапочки
class _HatPainter extends CustomPainter {
  final Color color;

  _HatPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Основание шапки
    final basePath = Path()
      ..addRect(Rect.fromLTWH(0, size.height * 0.6, size.width, size.height * 0.4));
    canvas.drawPath(basePath, paint);

    // Верх шапки (треугольник)
    final topPath = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width * 0.2, size.height * 0.6)
      ..lineTo(size.width * 0.8, size.height * 0.6)
      ..close();
    canvas.drawPath(topPath, paint);

    // Кисточка
    final brushPaint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width / 2, size.height * 0.1),
      size.width * 0.08,
      brushPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Компактный виджет Филина для углов экрана
class FilinCompact extends StatelessWidget {
  /// Настроение
  final FilinMood mood;

  /// Размер
  final double size;

  /// Callback при нажатии
  final VoidCallback? onTap;

  const FilinCompact({
    super.key,
    this.mood = FilinMood.neutral,
    this.size = 48,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _getMoodColor(),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: _getMoodColor().withValues(alpha: 0.4),
              blurRadius: 8,
            ),
          ],
        ),
        child: const Icon(
          Icons.help_outline,
          color: Colors.white,
        ),
      ),
    );
  }

  Color _getMoodColor() {
    switch (mood) {
      case FilinMood.neutral:
        return AppColors.primary;
      case FilinMood.happy:
        return AppColors.success;
      case FilinMood.thinking:
        return AppColors.info;
      case FilinMood.encouraging:
        return AppColors.accent;
      case FilinMood.surprised:
        return AppColors.warning;
      case FilinMood.sad:
        return AppColors.textSecondary;
    }
  }
}

/// Анимированная подсказка от Филина
class FilinHint extends StatefulWidget {
  /// Текст подсказки
  final String hint;

  /// Callback при закрытии
  final VoidCallback? onClose;

  /// Автозакрытие через время
  final Duration? autoCloseDuration;

  const FilinHint({
    super.key,
    required this.hint,
    this.onClose,
    this.autoCloseDuration,
  });

  @override
  State<FilinHint> createState() => _FilinHintState();
}

class _FilinHintState extends State<FilinHint>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _controller.forward();

    if (widget.autoCloseDuration != null) {
      Future.delayed(widget.autoCloseDuration!, _close);
    }
  }

  void _close() {
    _controller.reverse().then((_) {
      widget.onClose?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.all(UIConstants.paddingMedium),
          padding: const EdgeInsets.all(UIConstants.paddingMedium),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Иконка Филина
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
                child: const Icon(
                  Icons.lightbulb_outline,
                  color: Colors.white,
                  size: 24,
                ),
              ),

              const SizedBox(width: UIConstants.paddingMedium),

              // Текст подсказки
              Expanded(
                child: Text(
                  widget.hint,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),

              // Кнопка закрытия
              IconButton(
                onPressed: _close,
                icon: const Icon(
                  Icons.close,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
