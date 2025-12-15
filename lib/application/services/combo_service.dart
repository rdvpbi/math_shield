/// Сервис комбо-системы
///
/// Управляет комбо и расчётом множителя урона.
library;

import '../../core/config/game_constants.dart';

/// Сервис комбо
class ComboService {
  /// Текущее значение комбо
  int _currentCombo;

  /// Максимальное достигнутое комбо за сессию
  int _maxCombo;

  /// Общее количество комбо за всё время
  int _totalCombos;

  /// Создаёт сервис комбо
  ComboService()
      : _currentCombo = 0,
        _maxCombo = 0,
        _totalCombos = 0;

  /// Текущее комбо
  int get currentCombo => _currentCombo;

  /// Максимальное комбо за сессию
  int get maxCombo => _maxCombo;

  /// Общее количество комбо
  int get totalCombos => _totalCombos;

  /// Текущий множитель урона
  double get multiplier => getMultiplier(_currentCombo);

  /// Достигнут ли порог для Math Shield
  bool get hasMathShield =>
      _currentCombo >= ComboConstants.mathShieldComboThreshold;

  /// Достигнут ли порог для бонусных монет
  bool get hasBonusCoins =>
      _currentCombo >= ComboConstants.bonusCoinsComboThreshold;

  /// Достигнут ли порог для золотых искр
  bool get hasGoldenSparkles =>
      _currentCombo >= ComboConstants.goldenSparklesComboThreshold;

  /// Уровень комбо для визуальных эффектов
  ComboLevel get comboLevel {
    if (_currentCombo >= 10) return ComboLevel.legendary;
    if (_currentCombo >= 5) return ComboLevel.epic;
    if (_currentCombo >= 3) return ComboLevel.great;
    if (_currentCombo >= 1) return ComboLevel.good;
    return ComboLevel.none;
  }

  /// Рассчитывает множитель для указанного комбо
  static double getMultiplier(int combo) {
    return ComboConstants.calculateMultiplier(combo);
  }

  /// Регистрирует правильный ответ
  ///
  /// Возвращает текущий множитель урона
  double onCorrectAnswer() {
    _currentCombo++;
    _totalCombos++;

    if (_currentCombo > _maxCombo) {
      _maxCombo = _currentCombo;
    }

    return multiplier;
  }

  /// Регистрирует неправильный ответ
  ///
  /// Сбрасывает комбо и возвращает потерянное значение
  int onWrongAnswer() {
    final lost = _currentCombo;
    _currentCombo = 0;
    return lost;
  }

  /// Рассчитывает урон с учётом комбо
  int calculateDamage(int baseDamage) {
    return (baseDamage * multiplier).round();
  }

  /// Рассчитывает очки с учётом комбо
  int calculateScore(int baseScore) {
    // Бонус за комбо: +10% за каждый уровень
    final comboBonus = 1.0 + (_currentCombo * 0.1);
    return (baseScore * comboBonus).round();
  }

  /// Использует Math Shield (автокоррекция ошибки)
  ///
  /// Возвращает true, если щит был использован
  bool useMathShield() {
    if (!hasMathShield) return false;

    // Уменьшаем комбо, но не сбрасываем полностью
    _currentCombo = (_currentCombo - ComboConstants.mathShieldComboThreshold)
        .clamp(0, _currentCombo);
    return true;
  }

  /// Сбрасывает комбо
  void reset() {
    _currentCombo = 0;
  }

  /// Полный сброс сервиса
  void fullReset() {
    _currentCombo = 0;
    _maxCombo = 0;
    _totalCombos = 0;
  }

  /// Сбрасывает только сессионные данные
  void resetSession() {
    _currentCombo = 0;
    _maxCombo = 0;
  }

  /// Получает текст для отображения комбо
  String get comboText {
    if (_currentCombo == 0) return '';
    return '×$_currentCombo';
  }

  /// Получает текст множителя
  String get multiplierText {
    final mult = multiplier;
    if (mult == 1.0) return '';
    return '×${mult.toStringAsFixed(1)}';
  }
}

/// Уровни комбо для визуальных эффектов
enum ComboLevel {
  /// Нет комбо
  none,

  /// Хорошо (1-2)
  good,

  /// Отлично (3-4)
  great,

  /// Эпично (5-9)
  epic,

  /// Легендарно (10+)
  legendary,
}

/// Расширение для ComboLevel
extension ComboLevelExtension on ComboLevel {
  /// Название уровня
  String get name {
    switch (this) {
      case ComboLevel.none:
        return '';
      case ComboLevel.good:
        return 'Хорошо!';
      case ComboLevel.great:
        return 'Отлично!';
      case ComboLevel.epic:
        return 'Великолепно!';
      case ComboLevel.legendary:
        return 'ЛЕГЕНДАРНО!';
    }
  }

  /// Цвет для отображения (hex)
  int get colorValue {
    switch (this) {
      case ComboLevel.none:
        return 0xFFFFFFFF;
      case ComboLevel.good:
        return 0xFF4CAF50; // Зелёный
      case ComboLevel.great:
        return 0xFF2196F3; // Синий
      case ComboLevel.epic:
        return 0xFF9C27B0; // Фиолетовый
      case ComboLevel.legendary:
        return 0xFFFF9800; // Оранжевый/Золотой
    }
  }
}
