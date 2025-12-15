/// Тема приложения
///
/// Содержит ThemeData для Material 3, оптимизированный для детей 5-9 лет.
/// Большие шрифты, крупные кнопки, яркие цвета.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/config/game_constants.dart';
import 'app_colors.dart';

/// Главный класс темы приложения
abstract class AppTheme {
  // ============================================================================
  // ОСНОВНАЯ ТЕМА (ТЁМНАЯ)
  // ============================================================================

  /// Тёмная тема приложения (основная)
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,

        // Цветовая схема
        colorScheme: _darkColorScheme,

        // Scaffold
        scaffoldBackgroundColor: AppColors.backgroundDark,

        // AppBar
        appBarTheme: _appBarTheme,

        // Кнопки
        elevatedButtonTheme: _elevatedButtonTheme,
        outlinedButtonTheme: _outlinedButtonTheme,
        textButtonTheme: _textButtonTheme,
        iconButtonTheme: _iconButtonTheme,
        filledButtonTheme: _filledButtonTheme,

        // Карточки
        cardTheme: _cardTheme,

        // Текст
        textTheme: _textTheme,

        // Диалоги
        dialogTheme: _dialogTheme,

        // Иконки
        iconTheme: _iconTheme,

        // Слайдер
        sliderTheme: _sliderTheme,

        // Переключатель
        switchTheme: _switchTheme,

        // Прогресс
        progressIndicatorTheme: _progressIndicatorTheme,

        // Снэкбар
        snackBarTheme: _snackBarTheme,

        // Разделитель
        dividerTheme: _dividerTheme,

        // Визуальная плотность
        visualDensity: VisualDensity.comfortable,

        // Splash эффект
        splashFactory: InkRipple.splashFactory,

        // Отключаем Material Splash для более детского ощущения
        splashColor: AppColors.primary.withValues(alpha: 0.3),
        highlightColor: AppColors.primary.withValues(alpha: 0.1),
      );

  // ============================================================================
  // ЦВЕТОВАЯ СХЕМА
  // ============================================================================

  static ColorScheme get _darkColorScheme => ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: AppColors.textOnDark,
        primaryContainer: AppColors.primaryDark,
        onPrimaryContainer: AppColors.textOnDark,
        secondary: AppColors.secondary,
        onSecondary: AppColors.textOnDark,
        secondaryContainer: AppColors.secondaryDark,
        onSecondaryContainer: AppColors.textOnDark,
        tertiary: AppColors.accent,
        onTertiary: AppColors.textOnLight,
        tertiaryContainer: AppColors.accentDark,
        onTertiaryContainer: AppColors.textOnLight,
        error: AppColors.error,
        onError: AppColors.textOnDark,
        errorContainer: AppColors.errorDark,
        onErrorContainer: AppColors.textOnDark,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        surfaceContainerHighest: AppColors.surfaceVariant,
        onSurfaceVariant: AppColors.textSecondary,
        outline: AppColors.border,
        outlineVariant: AppColors.divider,
        shadow: AppColors.shadow,
        scrim: AppColors.overlay,
      );

  // ============================================================================
  // APPBAR
  // ============================================================================

  static AppBarTheme get _appBarTheme => AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: _textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.textPrimary,
          size: UIConstants.iconSizeLarge,
        ),
        actionsIconTheme: const IconThemeData(
          color: AppColors.textPrimary,
          size: UIConstants.iconSizeLarge,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      );

  // ============================================================================
  // КНОПКИ
  // ============================================================================

  /// ElevatedButton - основная кнопка действия
  static ElevatedButtonThemeData get _elevatedButtonTheme =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnDark,
          disabledBackgroundColor: AppColors.buttonDisabled,
          disabledForegroundColor: AppColors.textTertiary,
          elevation: 4,
          shadowColor: AppColors.shadow,
          padding: const EdgeInsets.symmetric(
            horizontal: UIConstants.paddingLarge,
            vertical: UIConstants.paddingMedium,
          ),
          minimumSize: const Size(
            UIConstants.buttonMinWidth,
            UIConstants.buttonHeight,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
          ),
          textStyle: _textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      );

  /// FilledButton - заполненная кнопка
  static FilledButtonThemeData get _filledButtonTheme => FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnDark,
          disabledBackgroundColor: AppColors.buttonDisabled,
          disabledForegroundColor: AppColors.textTertiary,
          padding: const EdgeInsets.symmetric(
            horizontal: UIConstants.paddingLarge,
            vertical: UIConstants.paddingMedium,
          ),
          minimumSize: const Size(
            UIConstants.buttonMinWidth,
            UIConstants.buttonHeight,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
          ),
          textStyle: _textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      );

  /// OutlinedButton - кнопка с обводкой
  static OutlinedButtonThemeData get _outlinedButtonTheme =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          disabledForegroundColor: AppColors.textTertiary,
          side: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: UIConstants.paddingLarge,
            vertical: UIConstants.paddingMedium,
          ),
          minimumSize: const Size(
            UIConstants.buttonMinWidth,
            UIConstants.buttonHeight,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
          ),
          textStyle: _textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      );

  /// TextButton - текстовая кнопка
  static TextButtonThemeData get _textButtonTheme => TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          disabledForegroundColor: AppColors.textTertiary,
          padding: const EdgeInsets.symmetric(
            horizontal: UIConstants.paddingMedium,
            vertical: UIConstants.paddingSmall,
          ),
          minimumSize: const Size(
            UIConstants.minTouchTarget,
            UIConstants.minTouchTarget,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UIConstants.borderRadiusSmall),
          ),
          textStyle: _textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  /// IconButton - кнопка с иконкой
  static IconButtonThemeData get _iconButtonTheme => IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          disabledForegroundColor: AppColors.textTertiary,
          minimumSize: const Size(
            UIConstants.minTouchTarget,
            UIConstants.minTouchTarget,
          ),
          padding: const EdgeInsets.all(UIConstants.paddingSmall),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UIConstants.borderRadiusSmall),
          ),
        ),
      );

  // ============================================================================
  // КАРТОЧКИ
  // ============================================================================

  static CardTheme get _cardTheme => CardTheme(
        color: AppColors.surface,
        elevation: 4,
        shadowColor: AppColors.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
        ),
        margin: const EdgeInsets.all(UIConstants.paddingSmall),
      );

  // ============================================================================
  // ТЕКСТ
  // ============================================================================

  /// Текстовая тема с увеличенными размерами для детей
  static TextTheme get _textTheme => const TextTheme(
        // Display — очень крупный текст (для чисел, счёта)
        displayLarge: TextStyle(
          fontSize: 72,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
          letterSpacing: -1.5,
        ),
        displayMedium: TextStyle(
          fontSize: 56,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
          letterSpacing: -0.5,
        ),
        displaySmall: TextStyle(
          fontSize: 44,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
          letterSpacing: 0,
        ),

        // Headline — крупные заголовки
        headlineLarge: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
          letterSpacing: 0,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
          letterSpacing: 0,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
          letterSpacing: 0,
        ),

        // Title — заголовки элементов
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          letterSpacing: 0,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          letterSpacing: 0.15,
        ),
        titleSmall: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          letterSpacing: 0.1,
        ),

        // Body — основной текст
        bodyLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.normal,
          color: AppColors.textPrimary,
          letterSpacing: 0.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: AppColors.textPrimary,
          letterSpacing: 0.25,
        ),
        bodySmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: AppColors.textSecondary,
          letterSpacing: 0.4,
        ),

        // Label — подписи и кнопки
        labelLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
          letterSpacing: 0.1,
        ),
        labelMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
          letterSpacing: 0.5,
        ),
        labelSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
          letterSpacing: 0.5,
        ),
      );

  // ============================================================================
  // ДИАЛОГИ
  // ============================================================================

  static DialogTheme get _dialogTheme => DialogTheme(
        backgroundColor: AppColors.surface,
        elevation: 8,
        shadowColor: AppColors.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UIConstants.borderRadiusLarge),
        ),
        titleTextStyle: _textTheme.headlineSmall,
        contentTextStyle: _textTheme.bodyLarge,
      );

  // ============================================================================
  // ИКОНКИ
  // ============================================================================

  static IconThemeData get _iconTheme => const IconThemeData(
        color: AppColors.textPrimary,
        size: UIConstants.iconSizeMedium,
      );

  // ============================================================================
  // СЛАЙДЕР
  // ============================================================================

  static SliderThemeData get _sliderTheme => SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.surface,
        thumbColor: AppColors.primary,
        overlayColor: AppColors.primary.withValues(alpha: 0.2),
        trackHeight: 8,
        thumbShape: const RoundSliderThumbShape(
          enabledThumbRadius: 12,
        ),
        overlayShape: const RoundSliderOverlayShape(
          overlayRadius: 24,
        ),
      );

  // ============================================================================
  // ПЕРЕКЛЮЧАТЕЛЬ
  // ============================================================================

  static SwitchThemeData get _switchTheme => SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.textSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryLight;
          }
          return AppColors.surface;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          return AppColors.border;
        }),
      );

  // ============================================================================
  // ИНДИКАТОР ПРОГРЕССА
  // ============================================================================

  static ProgressIndicatorThemeData get _progressIndicatorTheme =>
      const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.surface,
        circularTrackColor: AppColors.surface,
      );

  // ============================================================================
  // СНЭКБАР
  // ============================================================================

  static SnackBarThemeData get _snackBarTheme => SnackBarThemeData(
        backgroundColor: AppColors.surface,
        contentTextStyle: _textTheme.bodyLarge,
        actionTextColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UIConstants.borderRadiusSmall),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
      );

  // ============================================================================
  // РАЗДЕЛИТЕЛЬ
  // ============================================================================

  static DividerThemeData get _dividerTheme => const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: UIConstants.paddingMedium,
      );
}

/// Стили для специфических элементов игры
abstract class GameStyles {
  // ============================================================================
  // КНОПКА ОТВЕТА (AnswerPad)
  // ============================================================================

  /// Стиль кнопки цифры в AnswerPad
  static ButtonStyle get answerButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 4,
        shadowColor: AppColors.shadow,
        padding: EdgeInsets.zero,
        minimumSize: const Size(
          UIConstants.answerButtonSize,
          UIConstants.answerButtonSize,
        ),
        fixedSize: const Size(
          UIConstants.answerButtonSize,
          UIConstants.answerButtonSize,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
        ),
        textStyle: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      );

  /// Стиль кнопки подтверждения
  static ButtonStyle get confirmButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: AppColors.success,
        foregroundColor: AppColors.textOnDark,
        elevation: 4,
        shadowColor: AppColors.shadow,
        padding: EdgeInsets.zero,
        minimumSize: const Size(
          UIConstants.answerButtonSize,
          UIConstants.answerButtonSize,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
        ),
        textStyle: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      );

  /// Стиль кнопки удаления
  static ButtonStyle get deleteButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: AppColors.error,
        foregroundColor: AppColors.textOnDark,
        elevation: 4,
        shadowColor: AppColors.shadow,
        padding: EdgeInsets.zero,
        minimumSize: const Size(
          UIConstants.answerButtonSize,
          UIConstants.answerButtonSize,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
        ),
        textStyle: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      );

  // ============================================================================
  // КНОПКА МИРА
  // ============================================================================

  /// Стиль кнопки выбора мира (разблокированный)
  static ButtonStyle worldButtonUnlocked(Color worldColor) =>
      ElevatedButton.styleFrom(
        backgroundColor: worldColor,
        foregroundColor: AppColors.textOnDark,
        elevation: 6,
        shadowColor: worldColor.withValues(alpha: 0.5),
        padding: const EdgeInsets.all(UIConstants.paddingMedium),
        minimumSize: const Size(
          UIConstants.worldButtonSize,
          UIConstants.worldButtonSize,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UIConstants.borderRadiusLarge),
        ),
      );

  /// Стиль кнопки выбора мира (заблокированный)
  static ButtonStyle get worldButtonLocked => ElevatedButton.styleFrom(
        backgroundColor: AppColors.locked,
        foregroundColor: AppColors.textTertiary,
        elevation: 2,
        shadowColor: AppColors.shadow,
        padding: const EdgeInsets.all(UIConstants.paddingMedium),
        minimumSize: const Size(
          UIConstants.worldButtonSize,
          UIConstants.worldButtonSize,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UIConstants.borderRadiusLarge),
        ),
      );

  /// Стиль кнопки выбора мира (пройденный)
  static ButtonStyle worldButtonCompleted(Color worldColor) =>
      ElevatedButton.styleFrom(
        backgroundColor: worldColor,
        foregroundColor: AppColors.textOnDark,
        elevation: 6,
        shadowColor: AppColors.success.withValues(alpha: 0.5),
        padding: const EdgeInsets.all(UIConstants.paddingMedium),
        minimumSize: const Size(
          UIConstants.worldButtonSize,
          UIConstants.worldButtonSize,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UIConstants.borderRadiusLarge),
          side: const BorderSide(
            color: AppColors.success,
            width: 3,
          ),
        ),
      );

  // ============================================================================
  // ТЕКСТОВЫЕ СТИЛИ
  // ============================================================================

  /// Стиль для отображения математического примера
  static const TextStyle mathExpressionStyle = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: 2,
  );

  /// Стиль для отображения ответа
  static const TextStyle answerDisplayStyle = TextStyle(
    fontSize: 56,
    fontWeight: FontWeight.bold,
    color: AppColors.accent,
    letterSpacing: 4,
  );

  /// Стиль для счёта
  static const TextStyle scoreStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.accent,
  );

  /// Стиль для комбо
  static const TextStyle comboStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.combo,
  );

  /// Стиль для таймера
  static const TextStyle timerStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  /// Стиль для критического таймера
  static const TextStyle timerCriticalStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.error,
  );
}

/// Декорации для игровых элементов
abstract class GameDecorations {
  /// Декорация для карточки примера
  static BoxDecoration get mathCardDecoration => BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(UIConstants.borderRadiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      );

  /// Декорация для health bar
  static BoxDecoration healthBarDecoration(Color color) => BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(UIConstants.borderRadiusSmall),
      );

  /// Декорация для health bar фона
  static BoxDecoration get healthBarBackgroundDecoration => BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(UIConstants.borderRadiusSmall),
        border: Border.all(
          color: AppColors.border,
          width: 2,
        ),
      );

  /// Декорация для popup
  static BoxDecoration get popupDecoration => BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(UIConstants.borderRadiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      );

  /// Декорация с градиентом мира
  static BoxDecoration worldBackgroundDecoration(int worldId) => BoxDecoration(
        gradient: WorldPalettes.getBackgroundGradient(worldId),
      );
}
