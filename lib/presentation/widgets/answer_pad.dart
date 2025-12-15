/// Виджет цифровой клавиатуры для ввода ответа
///
/// Клавиатура 0-9 с кнопками очистки и подтверждения.
/// Оптимизирована для детей: большие кнопки, яркие цвета.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/config/game_constants.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Callback для ввода цифры
typedef OnDigitPressed = void Function(String digit);

/// Callback для подтверждения ответа
typedef OnConfirmPressed = void Function();

/// Callback для удаления цифры
typedef OnDeletePressed = void Function();

/// Callback для очистки ввода
typedef OnClearPressed = void Function();

/// Виджет цифровой клавиатуры
class AnswerPad extends StatelessWidget {
  /// Callback при нажатии цифры
  final OnDigitPressed? onDigitPressed;

  /// Callback при подтверждении
  final OnConfirmPressed? onConfirmPressed;

  /// Callback при удалении последней цифры
  final OnDeletePressed? onDeletePressed;

  /// Callback при очистке всего ввода
  final OnClearPressed? onClearPressed;

  /// Текущий введённый ответ (для отображения)
  final String currentInput;

  /// Отключена ли клавиатура
  final bool isDisabled;

  /// Максимальная длина ввода
  final int maxInputLength;

  /// Показывать ли вибрацию при нажатии
  final bool enableHapticFeedback;

  /// Цвет кнопок цифр
  final Color? digitButtonColor;

  /// Цвет кнопки подтверждения
  final Color? confirmButtonColor;

  /// Цвет кнопки удаления
  final Color? deleteButtonColor;

  const AnswerPad({
    super.key,
    this.onDigitPressed,
    this.onConfirmPressed,
    this.onDeletePressed,
    this.onClearPressed,
    this.currentInput = '',
    this.isDisabled = false,
    this.maxInputLength = 4,
    this.enableHapticFeedback = true,
    this.digitButtonColor,
    this.confirmButtonColor,
    this.deleteButtonColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Дисплей ввода
        _buildInputDisplay(),

        const SizedBox(height: UIConstants.paddingMedium),

        // Клавиатура
        _buildKeypad(),
      ],
    );
  }

  Widget _buildInputDisplay() {
    return Container(
      width: double.infinity,
      height: 72,
      padding: const EdgeInsets.symmetric(
        horizontal: UIConstants.paddingLarge,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
        border: Border.all(
          color: AppColors.border,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          currentInput.isEmpty ? '?' : currentInput,
          style: GameStyles.answerDisplayStyle.copyWith(
            color: currentInput.isEmpty
                ? AppColors.textTertiary
                : AppColors.accent,
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Рассчитываем размер кнопок на основе доступного пространства
        final availableWidth = constraints.maxWidth;
        final buttonSize = ((availableWidth - UIConstants.paddingSmall * 4) / 5)
            .clamp(UIConstants.answerButtonSize, 80.0);
        final spacing = UIConstants.paddingSmall;

        return Column(
          children: [
            // Ряд 1: 1, 2, 3, 4, 5
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 1; i <= 5; i++) ...[
                  _buildDigitButton('$i', buttonSize),
                  if (i < 5) SizedBox(width: spacing),
                ],
              ],
            ),

            SizedBox(height: spacing),

            // Ряд 2: 6, 7, 8, 9, 0
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 6; i <= 9; i++) ...[
                  _buildDigitButton('$i', buttonSize),
                  SizedBox(width: spacing),
                ],
                _buildDigitButton('0', buttonSize),
              ],
            ),

            SizedBox(height: spacing),

            // Ряд 3: Очистить, Удалить, Подтвердить
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildClearButton(buttonSize),
                SizedBox(width: spacing),
                _buildDeleteButton(buttonSize),
                SizedBox(width: spacing),
                _buildConfirmButton(buttonSize * 2 + spacing),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildDigitButton(String digit, double size) {
    final isActive = !isDisabled && currentInput.length < maxInputLength;

    return SizedBox(
      width: size,
      height: size,
      child: ElevatedButton(
        onPressed: isActive ? () => _onDigitTap(digit) : null,
        style: GameStyles.answerButtonStyle.copyWith(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return AppColors.buttonDisabled;
            }
            if (states.contains(WidgetState.pressed)) {
              return (digitButtonColor ?? AppColors.surface)
                  .withValues(alpha: 0.8);
            }
            return digitButtonColor ?? AppColors.surface;
          }),
          minimumSize: WidgetStateProperty.all(Size(size, size)),
          fixedSize: WidgetStateProperty.all(Size(size, size)),
        ),
        child: Text(
          digit,
          style: TextStyle(
            fontSize: size * 0.45,
            fontWeight: FontWeight.bold,
            color: isActive ? AppColors.textPrimary : AppColors.textTertiary,
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton(double size) {
    final isActive = !isDisabled && currentInput.isNotEmpty;

    return SizedBox(
      width: size,
      height: size,
      child: ElevatedButton(
        onPressed: isActive ? _onDeleteTap : null,
        style: GameStyles.deleteButtonStyle.copyWith(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return AppColors.buttonDisabled;
            }
            if (states.contains(WidgetState.pressed)) {
              return (deleteButtonColor ?? AppColors.error)
                  .withValues(alpha: 0.8);
            }
            return deleteButtonColor ?? AppColors.error;
          }),
          minimumSize: WidgetStateProperty.all(Size(size, size)),
          fixedSize: WidgetStateProperty.all(Size(size, size)),
        ),
        child: Icon(
          Icons.backspace_outlined,
          size: size * 0.4,
          color: isActive ? AppColors.textOnDark : AppColors.textTertiary,
        ),
      ),
    );
  }

  Widget _buildClearButton(double size) {
    final isActive = !isDisabled && currentInput.isNotEmpty;

    return SizedBox(
      width: size,
      height: size,
      child: ElevatedButton(
        onPressed: isActive ? _onClearTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.warning,
          foregroundColor: AppColors.textOnDark,
          disabledBackgroundColor: AppColors.buttonDisabled,
          elevation: 4,
          padding: EdgeInsets.zero,
          minimumSize: Size(size, size),
          fixedSize: Size(size, size),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
          ),
        ),
        child: Icon(
          Icons.clear,
          size: size * 0.4,
          color: isActive ? AppColors.textOnDark : AppColors.textTertiary,
        ),
      ),
    );
  }

  Widget _buildConfirmButton(double width) {
    final isActive = !isDisabled && currentInput.isNotEmpty;
    const height = UIConstants.answerButtonSize;

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isActive ? _onConfirmTap : null,
        style: GameStyles.confirmButtonStyle.copyWith(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return AppColors.buttonDisabled;
            }
            if (states.contains(WidgetState.pressed)) {
              return (confirmButtonColor ?? AppColors.success)
                  .withValues(alpha: 0.8);
            }
            return confirmButtonColor ?? AppColors.success;
          }),
          minimumSize: WidgetStateProperty.all(Size(width, height)),
          fixedSize: WidgetStateProperty.all(Size(width, height)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check,
              size: height * 0.4,
              color: isActive ? AppColors.textOnDark : AppColors.textTertiary,
            ),
            const SizedBox(width: 4),
            Text(
              'OK',
              style: TextStyle(
                fontSize: height * 0.35,
                fontWeight: FontWeight.bold,
                color: isActive ? AppColors.textOnDark : AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onDigitTap(String digit) {
    if (enableHapticFeedback) {
      HapticFeedback.lightImpact();
    }
    onDigitPressed?.call(digit);
  }

  void _onDeleteTap() {
    if (enableHapticFeedback) {
      HapticFeedback.mediumImpact();
    }
    onDeletePressed?.call();
  }

  void _onClearTap() {
    if (enableHapticFeedback) {
      HapticFeedback.mediumImpact();
    }
    onClearPressed?.call();
  }

  void _onConfirmTap() {
    if (enableHapticFeedback) {
      HapticFeedback.heavyImpact();
    }
    onConfirmPressed?.call();
  }
}

/// Компактная версия клавиатуры
class CompactAnswerPad extends StatelessWidget {
  /// Callback при вводе полного ответа
  final ValueChanged<int>? onAnswer;

  /// Отключена ли клавиатура
  final bool isDisabled;

  const CompactAnswerPad({
    super.key,
    this.onAnswer,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 5,
      mainAxisSpacing: UIConstants.paddingSmall,
      crossAxisSpacing: UIConstants.paddingSmall,
      children: [
        for (var i = 0; i <= 9; i++)
          _QuickAnswerButton(
            value: i,
            onPressed: isDisabled ? null : () => onAnswer?.call(i),
          ),
      ],
    );
  }
}

class _QuickAnswerButton extends StatelessWidget {
  final int value;
  final VoidCallback? onPressed;

  const _QuickAnswerButton({
    required this.value,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: ElevatedButton(
        onPressed: onPressed,
        style: GameStyles.answerButtonStyle,
        child: Text(
          '$value',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// Горизонтальная клавиатура для одной строки
class HorizontalAnswerPad extends StatelessWidget {
  /// Callback при нажатии цифры
  final OnDigitPressed? onDigitPressed;

  /// Текущий ввод
  final String currentInput;

  /// Отключена ли клавиатура
  final bool isDisabled;

  /// Максимальная длина ввода
  final int maxInputLength;

  const HorizontalAnswerPad({
    super.key,
    this.onDigitPressed,
    this.currentInput = '',
    this.isDisabled = false,
    this.maxInputLength = 4,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i <= 9; i++) ...[
            _buildButton('$i'),
            if (i < 9) const SizedBox(width: UIConstants.paddingSmall),
          ],
        ],
      ),
    );
  }

  Widget _buildButton(String digit) {
    final isActive = !isDisabled && currentInput.length < maxInputLength;

    return SizedBox(
      width: 56,
      height: 56,
      child: ElevatedButton(
        onPressed: isActive ? () => onDigitPressed?.call(digit) : null,
        style: GameStyles.answerButtonStyle.copyWith(
          minimumSize: WidgetStateProperty.all(const Size(56, 56)),
          fixedSize: WidgetStateProperty.all(const Size(56, 56)),
        ),
        child: Text(
          digit,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isActive ? AppColors.textPrimary : AppColors.textTertiary,
          ),
        ),
      ),
    );
  }
}
