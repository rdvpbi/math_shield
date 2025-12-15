/// Цветовая палитра приложения
///
/// Содержит все цвета, используемые в Math Shield.
/// Включает основные цвета, цвета статусов и уникальные палитры для каждого мира.
library;

import 'package:flutter/material.dart';

/// Основные цвета приложения
abstract class AppColors {
  // ============================================================================
  // ОСНОВНЫЕ ЦВЕТА
  // ============================================================================

  /// Основной фиолетовый цвет
  static const Color primary = Color(0xFF6C5CE7);

  /// Светлый вариант основного цвета
  static const Color primaryLight = Color(0xFF9B8DF5);

  /// Тёмный вариант основного цвета
  static const Color primaryDark = Color(0xFF4A3DB8);

  /// Вторичный бирюзовый цвет
  static const Color secondary = Color(0xFF00CEC9);

  /// Светлый вариант вторичного цвета
  static const Color secondaryLight = Color(0xFF4DEDE8);

  /// Тёмный вариант вторичного цвета
  static const Color secondaryDark = Color(0xFF009E9A);

  /// Акцентный золотой цвет
  static const Color accent = Color(0xFFFDCB6E);

  /// Светлый вариант акцентного цвета
  static const Color accentLight = Color(0xFFFFE19A);

  /// Тёмный вариант акцентного цвета
  static const Color accentDark = Color(0xFFD4A84A);

  // ============================================================================
  // ФОНЫ
  // ============================================================================

  /// Тёмный фон (основной)
  static const Color backgroundDark = Color(0xFF1A1A2E);

  /// Светлый тёмный фон (карточки)
  static const Color backgroundLight = Color(0xFF16213E);

  /// Поверхность для карточек
  static const Color surface = Color(0xFF252A48);

  /// Альтернативная поверхность
  static const Color surfaceVariant = Color(0xFF2D3250);

  /// Цвет наложения (для модальных окон)
  static const Color overlay = Color(0x80000000);

  // ============================================================================
  // ТЕКСТ
  // ============================================================================

  /// Основной цвет текста
  static const Color textPrimary = Color(0xFFFFFFFF);

  /// Вторичный цвет текста
  static const Color textSecondary = Color(0xFFB8B8D0);

  /// Третичный цвет текста (подсказки)
  static const Color textTertiary = Color(0xFF7E7E9A);

  /// Цвет текста на тёмном фоне
  static const Color textOnDark = Color(0xFFFFFFFF);

  /// Цвет текста на светлом фоне
  static const Color textOnLight = Color(0xFF1A1A2E);

  // ============================================================================
  // СТАТУСЫ
  // ============================================================================

  /// Цвет успеха (правильный ответ)
  static const Color success = Color(0xFF00B894);

  /// Светлый вариант цвета успеха
  static const Color successLight = Color(0xFF55EFC4);

  /// Тёмный вариант цвета успеха
  static const Color successDark = Color(0xFF00866A);

  /// Цвет ошибки (неправильный ответ)
  static const Color error = Color(0xFFE74C3C);

  /// Светлый вариант цвета ошибки
  static const Color errorLight = Color(0xFFFF7675);

  /// Тёмный вариант цвета ошибки
  static const Color errorDark = Color(0xFFC0392B);

  /// Цвет предупреждения
  static const Color warning = Color(0xFFF39C12);

  /// Светлый вариант цвета предупреждения
  static const Color warningLight = Color(0xFFF9CA24);

  /// Тёмный вариант цвета предупреждения
  static const Color warningDark = Color(0xFFE67E22);

  /// Информационный цвет
  static const Color info = Color(0xFF3498DB);

  /// Светлый вариант информационного цвета
  static const Color infoLight = Color(0xFF74B9FF);

  /// Тёмный вариант информационного цвета
  static const Color infoDark = Color(0xFF2980B9);

  // ============================================================================
  // ИГРОВЫЕ ЭЛЕМЕНТЫ
  // ============================================================================

  /// Цвет здоровья (полное)
  static const Color healthFull = Color(0xFF00B894);

  /// Цвет здоровья (среднее)
  static const Color healthMedium = Color(0xFFF39C12);

  /// Цвет здоровья (низкое)
  static const Color healthLow = Color(0xFFE74C3C);

  /// Цвет комбо
  static const Color combo = Color(0xFFFFD700);

  /// Цвет звезды
  static const Color star = Color(0xFFFDCB6E);

  /// Цвет заблокированного элемента
  static const Color locked = Color(0xFF636E72);

  /// Цвет разблокированного элемента
  static const Color unlocked = Color(0xFF6C5CE7);

  /// Цвет пройденного элемента
  static const Color completed = Color(0xFF00B894);

  // ============================================================================
  // UI ЭЛЕМЕНТЫ
  // ============================================================================

  /// Цвет границ
  static const Color border = Color(0xFF3D3D5C);

  /// Цвет разделителя
  static const Color divider = Color(0xFF3D3D5C);

  /// Цвет тени
  static const Color shadow = Color(0x40000000);

  /// Цвет кнопки
  static const Color button = Color(0xFF6C5CE7);

  /// Цвет нажатой кнопки
  static const Color buttonPressed = Color(0xFF4A3DB8);

  /// Цвет отключённой кнопки
  static const Color buttonDisabled = Color(0xFF636E72);

  // ============================================================================
  // МЕТОДЫ
  // ============================================================================

  /// Возвращает цвет здоровья в зависимости от процента
  static Color getHealthColor(double percentage) {
    if (percentage > 0.5) return healthFull;
    if (percentage > 0.25) return healthMedium;
    return healthLow;
  }

  /// Возвращает цвет с прозрачностью
  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }
}

/// Цветовые палитры для каждого мира
///
/// Каждый мир имеет уникальную цветовую схему.
class WorldColors {
  /// Основной цвет мира
  final Color primary;

  /// Вторичный цвет мира
  final Color secondary;

  /// Цвет фона мира
  final Color background;

  /// Цвет градиента (верх)
  final Color gradientTop;

  /// Цвет градиента (низ)
  final Color gradientBottom;

  /// Цвет акцента мира
  final Color accent;

  /// Цвет босса
  final Color boss;

  const WorldColors({
    required this.primary,
    required this.secondary,
    required this.background,
    required this.gradientTop,
    required this.gradientBottom,
    required this.accent,
    required this.boss,
  });

  /// Создаёт градиент для фона мира
  LinearGradient get backgroundGradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [gradientTop, gradientBottom],
      );

  /// Создаёт радиальный градиент для эффектов
  RadialGradient get radialGradient => RadialGradient(
        colors: [primary.withValues(alpha: 0.5), Colors.transparent],
        radius: 1.0,
      );
}

/// Цвета для всех миров
abstract class WorldPalettes {
  // ============================================================================
  // МИР 0: Лабиринт Нуля (×0)
  // ============================================================================

  /// Мир 0 — пустота, минимализм, серые тона
  static const WorldColors world0 = WorldColors(
    primary: Color(0xFF636E72),
    secondary: Color(0xFF2D3436),
    background: Color(0xFF1E272E),
    gradientTop: Color(0xFF2D3436),
    gradientBottom: Color(0xFF1E272E),
    accent: Color(0xFF00CEC9),
    boss: Color(0xFF95A5A6),
  );

  // ============================================================================
  // МИР 1: Фабрика Хаоса (×1)
  // ============================================================================

  /// Мир 1 — механика, оранжевый и металлик
  static const WorldColors world1 = WorldColors(
    primary: Color(0xFFE17055),
    secondary: Color(0xFFD63031),
    background: Color(0xFF2D2D2D),
    gradientTop: Color(0xFF3D3D3D),
    gradientBottom: Color(0xFF1A1A1A),
    accent: Color(0xFFFDCB6E),
    boss: Color(0xFFFF6B6B),
  );

  // ============================================================================
  // МИР 2: Зеркальная Башня (×2)
  // ============================================================================

  /// Мир 2 — отражения, серебро и голубой
  static const WorldColors world2 = WorldColors(
    primary: Color(0xFF74B9FF),
    secondary: Color(0xFF0984E3),
    background: Color(0xFF1B2838),
    gradientTop: Color(0xFF2D4B6D),
    gradientBottom: Color(0xFF0D1B2A),
    accent: Color(0xFFE8E8E8),
    boss: Color(0xFF81ECEC),
  );

  // ============================================================================
  // МИР 3: Тройной Лес (×3)
  // ============================================================================

  /// Мир 3 — природа, зелёный и коричневый
  static const WorldColors world3 = WorldColors(
    primary: Color(0xFF00B894),
    secondary: Color(0xFF55EFC4),
    background: Color(0xFF1D2E28),
    gradientTop: Color(0xFF2D4A3E),
    gradientBottom: Color(0xFF0D1B14),
    accent: Color(0xFF8B4513),
    boss: Color(0xFF26DE81),
  );

  // ============================================================================
  // МИР 4: Квадратный Город (×4)
  // ============================================================================

  /// Мир 4 — геометрия, синий и серый
  static const WorldColors world4 = WorldColors(
    primary: Color(0xFF6C5CE7),
    secondary: Color(0xFFA29BFE),
    background: Color(0xFF1A1A2E),
    gradientTop: Color(0xFF2D2D5A),
    gradientBottom: Color(0xFF0D0D1A),
    accent: Color(0xFFFFD700),
    boss: Color(0xFF786FA6),
  );

  // ============================================================================
  // МИР 5: Вихревая Фабрика (×5)
  // ============================================================================

  /// Мир 5 — движение, жёлтый и чёрный
  static const WorldColors world5 = WorldColors(
    primary: Color(0xFFFDCB6E),
    secondary: Color(0xFFF9CA24),
    background: Color(0xFF2D2D1A),
    gradientTop: Color(0xFF4A4A2D),
    gradientBottom: Color(0xFF1A1A0D),
    accent: Color(0xFF2D3436),
    boss: Color(0xFFFFBE76),
  );

  // ============================================================================
  // МИР 6: Шесть Чудес (×6)
  // ============================================================================

  /// Мир 6 — магия, фиолетовый и золотой
  static const WorldColors world6 = WorldColors(
    primary: Color(0xFF9B59B6),
    secondary: Color(0xFFBE2EDD),
    background: Color(0xFF2D1B3D),
    gradientTop: Color(0xFF4A2D5A),
    gradientBottom: Color(0xFF1A0D2D),
    accent: Color(0xFFFFD700),
    boss: Color(0xFFE056FD),
  );

  // ============================================================================
  // МИР 7: Казино Удачи (×7)
  // ============================================================================

  /// Мир 7 — удача, красный и золотой
  static const WorldColors world7 = WorldColors(
    primary: Color(0xFFE74C3C),
    secondary: Color(0xFFC0392B),
    background: Color(0xFF2D1A1A),
    gradientTop: Color(0xFF5A2D2D),
    gradientBottom: Color(0xFF2D0D0D),
    accent: Color(0xFFFFD700),
    boss: Color(0xFFEE5A5A),
  );

  // ============================================================================
  // МИР 8: Океан Осьминога (×8)
  // ============================================================================

  /// Мир 8 — глубина, бирюзовый и тёмно-синий
  static const WorldColors world8 = WorldColors(
    primary: Color(0xFF00CEC9),
    secondary: Color(0xFF81ECEC),
    background: Color(0xFF0D2B3E),
    gradientTop: Color(0xFF1A4A5E),
    gradientBottom: Color(0xFF051520),
    accent: Color(0xFF55EFC4),
    boss: Color(0xFF7EFFF5),
  );

  // ============================================================================
  // МИР 9: Дворец Девяти Зеркал (×9)
  // ============================================================================

  /// Мир 9 — величие, золотой и королевский синий
  static const WorldColors world9 = WorldColors(
    primary: Color(0xFFFFD700),
    secondary: Color(0xFFF39C12),
    background: Color(0xFF1A1A3D),
    gradientTop: Color(0xFF2D2D5A),
    gradientBottom: Color(0xFF0D0D2D),
    accent: Color(0xFF3498DB),
    boss: Color(0xFFFFEC8B),
  );

  // ============================================================================
  // МЕТОДЫ
  // ============================================================================

  /// Список всех палитр миров
  static const List<WorldColors> all = [
    world0,
    world1,
    world2,
    world3,
    world4,
    world5,
    world6,
    world7,
    world8,
    world9,
  ];

  /// Получает палитру мира по ID
  static WorldColors getWorld(int worldId) {
    if (worldId < 0 || worldId >= all.length) {
      return world0; // По умолчанию
    }
    return all[worldId];
  }

  /// Получает цвет босса по ID мира
  static Color getBossColor(int worldId) {
    return getWorld(worldId).boss;
  }

  /// Получает градиент фона по ID мира
  static LinearGradient getBackgroundGradient(int worldId) {
    return getWorld(worldId).backgroundGradient;
  }
}

/// Цвета для уровней комбо
abstract class ComboColors {
  /// Цвет для комбо уровня 1 (normal)
  static const Color level1 = Color(0xFFFFFFFF);

  /// Цвет для комбо уровня 2 (good)
  static const Color level2 = Color(0xFF00B894);

  /// Цвет для комбо уровня 3 (great)
  static const Color level3 = Color(0xFF0984E3);

  /// Цвет для комбо уровня 4 (amazing)
  static const Color level4 = Color(0xFF6C5CE7);

  /// Цвет для комбо уровня 5 (legendary)
  static const Color level5 = Color(0xFFFFD700);

  /// Получает цвет комбо по множителю
  static Color getColor(double multiplier) {
    if (multiplier >= 4.0) return level5;
    if (multiplier >= 3.0) return level4;
    if (multiplier >= 2.0) return level3;
    if (multiplier >= 1.5) return level2;
    return level1;
  }

  /// Получает градиент для комбо
  static LinearGradient getGradient(double multiplier) {
    final color = getColor(multiplier);
    return LinearGradient(
      colors: [color, color.withValues(alpha: 0.5)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}

/// Расширение для работы с цветами
extension ColorExtensions on Color {
  /// Осветляет цвет на указанный процент
  Color lighten([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1, 'Amount must be between 0 and 1');
    return Color.lerp(this, Colors.white, amount)!;
  }

  /// Затемняет цвет на указанный процент
  Color darken([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1, 'Amount must be between 0 and 1');
    return Color.lerp(this, Colors.black, amount)!;
  }

  /// Создаёт Material Color Swatch из цвета
  MaterialColor toMaterialColor() {
    final strengths = <double>[.05];
    final swatch = <int, Color>{};

    for (var i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }

    for (final strength in strengths) {
      final ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }

    return MaterialColor(toARGB32(), swatch);
  }

  /// Возвращает ARGB32 представление цвета
  int toARGB32() {
    return (a * 255).round() << 24 |
        (r * 255).round() << 16 |
        (g * 255).round() << 8 |
        (b * 255).round();
  }
}
