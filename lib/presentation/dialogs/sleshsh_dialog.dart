/// Диалог с антагонистом Слэшшем
///
/// Показывает угрожающие сообщения от главного злодея.
library;

import 'package:flutter/material.dart';

import '../../core/config/game_constants.dart';
import '../theme/app_colors.dart';

/// Диалог с антагонистом
class SleshshDialog extends StatefulWidget {
  /// Текст сообщения
  final String message;

  /// Заголовок (имя или фраза)
  final String? title;

  /// Текст кнопки
  final String buttonText;

  /// Callback при закрытии
  final VoidCallback? onClose;

  /// ID босса (для цвета)
  final int? bossWorldId;

  /// Имя босса
  final String? bossName;

  const SleshshDialog({
    super.key,
    required this.message,
    this.title,
    this.buttonText = 'Вызов принят!',
    this.onClose,
    this.bossWorldId,
    this.bossName,
  });

  /// Показывает диалог
  static Future<void> show(
    BuildContext context, {
    required String message,
    String? title,
    String buttonText = 'Вызов принят!',
    int? bossWorldId,
    String? bossName,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SleshshDialog(
        message: message,
        title: title,
        buttonText: buttonText,
        bossWorldId: bossWorldId,
        bossName: bossName,
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  State<SleshshDialog> createState() => _SleshshDialogState();
}

class _SleshshDialogState extends State<SleshshDialog>
    with TickerProviderStateMixin {
  late AnimationController _appearController;
  late AnimationController _glowController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _appearController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _appearController,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _appearController,
      curve: Curves.easeIn,
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _appearController.forward();
    _glowController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _appearController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  Color get _accentColor {
    if (widget.bossWorldId != null) {
      return WorldPalettes.getBossColor(widget.bossWorldId!);
    }
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return Container(
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(UIConstants.borderRadiusLarge),
                  boxShadow: [
                    BoxShadow(
                      color: _accentColor.withValues(alpha: _glowAnimation.value),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: child,
              );
            },
            child: _buildContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      padding: const EdgeInsets.all(UIConstants.paddingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _accentColor.withValues(alpha: 0.3),
            AppColors.backgroundDark,
          ],
        ),
        borderRadius: BorderRadius.circular(UIConstants.borderRadiusLarge),
        border: Border.all(
          color: _accentColor,
          width: 3,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Аватар злодея
          _buildVillainAvatar(),

          const SizedBox(height: UIConstants.paddingMedium),

          // Имя
          Text(
            widget.bossName ?? widget.title ?? 'Слэшш',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _accentColor,
              letterSpacing: 2,
            ),
          ),

          const SizedBox(height: UIConstants.paddingMedium),

          // Сообщение
          Container(
            padding: const EdgeInsets.all(UIConstants.paddingMedium),
            decoration: BoxDecoration(
              color: AppColors.backgroundDark.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
              border: Border.all(
                color: _accentColor.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              widget.message,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
                height: 1.5,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: UIConstants.paddingLarge),

          // Кнопка
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.onClose,
              style: ElevatedButton.styleFrom(
                backgroundColor: _accentColor,
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
    );
  }

  Widget _buildVillainAvatar() {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                _accentColor,
                _accentColor.withValues(alpha: 0.5),
              ],
            ),
            border: Border.all(
              color: _accentColor,
              width: 4,
            ),
            boxShadow: [
              BoxShadow(
                color: _accentColor.withValues(alpha: _glowAnimation.value * 0.5),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Иконка злодея
              Icon(
                Icons.mood_bad,
                size: 50,
                color: AppColors.textOnDark,
              ),

              // Номер мира
              if (widget.bossWorldId != null)
                Positioned(
                  bottom: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundDark,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '×${widget.bossWorldId}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _accentColor,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Предустановленные фразы боссов
abstract class BossTaunts {
  /// Фразы насмешек перед боем
  static const Map<int, List<String>> taunts = {
    0: [
      'Ты ничто! Как и результат умножения на меня!',
      'Нулевые шансы на победу!',
    ],
    1: [
      'Я не изменю ничего в твоих числах... кроме твоей уверенности!',
      'Думаешь, умножение на 1 легко? Попробуй в хаосе!',
    ],
    2: [
      'Увидишь себя в поражении... дважды!',
      'Моё отражение сильнее тебя!',
    ],
    3: [
      'Тройная сила природы против тебя!',
      'В лесу тройняшек ты заблудишься!',
    ],
    4: [
      'Мои идеальные квадраты раздавят тебя!',
      'Геометрия твоего поражения неизбежна!',
    ],
    5: [
      'Закружу тебя в вихре пятёрок!',
      'Пятью пять - и ты проиграл!',
    ],
    6: [
      'Шесть чудес, и ни одно тебе не поможет!',
      'Магия шестёрок не на твоей стороне!',
    ],
    7: [
      'Удача? Ха! Семёрка всегда за меня!',
      'В казино математики ты всегда проигрываешь!',
    ],
    8: [
      'Восемь щупалец схватят твои ответы!',
      'Глубины моих чисел поглотят тебя!',
    ],
    9: [
      'Девять зеркал отразят твой страх!',
      'Величие девятки непобедимо!',
    ],
  };

  /// Фразы при поражении босса
  static const Map<int, String> defeatPhrases = {
    0: 'Невозможно... обнулён...',
    1: 'Хаос... усмирён...',
    2: 'Мои отражения... разбиты...',
    3: 'Лес... увядает...',
    4: 'Мои квадраты... рушатся...',
    5: 'Вихрь... стихает...',
    6: 'Магия... иссякла...',
    7: 'Удача... отвернулась...',
    8: 'Глубины... мелеют...',
    9: 'Зеркала... потускнели...',
  };

  /// Получить случайную насмешку для босса
  static String getTaunt(int worldId) {
    final worldTaunts = taunts[worldId] ?? taunts[0]!;
    final index = DateTime.now().millisecond % worldTaunts.length;
    return worldTaunts[index];
  }

  /// Получить фразу поражения
  static String getDefeatPhrase(int worldId) {
    return defeatPhrases[worldId] ?? 'Нет... это невозможно...';
  }
}

/// Диалог перед боем с боссом
class BossIntroDialog extends StatelessWidget {
  final int worldId;
  final String bossName;
  final VoidCallback? onStart;

  const BossIntroDialog({
    super.key,
    required this.worldId,
    required this.bossName,
    this.onStart,
  });

  static Future<void> show(
    BuildContext context, {
    required int worldId,
    required String bossName,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BossIntroDialog(
        worldId: worldId,
        bossName: bossName,
        onStart: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SleshshDialog(
      message: BossTaunts.getTaunt(worldId),
      bossWorldId: worldId,
      bossName: bossName,
      buttonText: 'В бой!',
      onClose: onStart,
    );
  }
}
