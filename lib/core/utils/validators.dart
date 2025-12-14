/// Валидаторы для проверки данных в игре
///
/// Все функции возвращают bool и не выбрасывают исключений.
library;

import '../config/game_constants.dart';

/// Валидаторы для математических примеров
abstract class MathValidators {
  /// Проверяет, является ли ответ правильным
  ///
  /// ```dart
  /// validateAnswer(12, 12) // true
  /// validateAnswer(10, 12) // false
  /// ```
  static bool validateAnswer(int answer, int expected) {
    return answer == expected;
  }

  /// Проверяет, находится ли множитель в допустимом диапазоне (0-9)
  ///
  /// ```dart
  /// validateMultiplier(5) // true
  /// validateMultiplier(10) // false
  /// validateMultiplier(-1) // false
  /// ```
  static bool validateMultiplier(int multiplier) {
    return multiplier >= WorldConstants.minMultiplier &&
        multiplier <= WorldConstants.maxMultiplier;
  }

  /// Проверяет, находится ли множимое в допустимом диапазоне (0-10)
  ///
  /// ```dart
  /// validateMultiplicand(7) // true
  /// validateMultiplicand(11) // false
  /// ```
  static bool validateMultiplicand(int multiplicand) {
    return multiplicand >= WorldConstants.minMultiplicand &&
        multiplicand <= WorldConstants.maxMultiplicand;
  }

  /// Проверяет корректность примера умножения
  ///
  /// Проверяет, что оба числа в допустимых диапазонах
  /// и правильный ответ соответствует произведению.
  static bool validateExample({
    required int multiplicand,
    required int multiplier,
    required int correctAnswer,
  }) {
    if (!validateMultiplicand(multiplicand)) return false;
    if (!validateMultiplier(multiplier)) return false;
    return correctAnswer == multiplicand * multiplier;
  }

  /// Проверяет, является ли ответ неотрицательным числом
  static bool validateAnswerFormat(int answer) {
    return answer >= 0;
  }
}

/// Валидаторы для игрока
abstract class PlayerValidators {
  /// Проверяет корректность количества жизней
  ///
  /// ```dart
  /// validateLives(3) // true
  /// validateLives(0) // true (игра окончена)
  /// validateLives(-1) // false
  /// validateLives(10) // false (больше максимума)
  /// ```
  static bool validateLives(int lives) {
    return lives >= 0 && lives <= PlayerConstants.maxLives;
  }

  /// Проверяет корректность счёта
  static bool validateScore(int score) {
    return score >= 0;
  }

  /// Проверяет корректность ID мира
  ///
  /// ```dart
  /// validateWorldId(0) // true
  /// validateWorldId(9) // true
  /// validateWorldId(10) // false
  /// validateWorldId(-1) // false
  /// ```
  static bool validateWorldId(int worldId) {
    return worldId >= 0 && worldId < WorldConstants.totalWorlds;
  }

  /// Проверяет корректность значения комбо
  static bool validateCombo(int combo) {
    return combo >= 0;
  }
}

/// Валидаторы для боссов
abstract class BossValidators {
  /// Проверяет корректность HP босса
  static bool validateBossHp(int hp, int maxHp) {
    return hp >= 0 && hp <= maxHp && maxHp > 0;
  }

  /// Проверяет, может ли босс перейти в указанную фазу
  static bool validatePhaseTransition({
    required String fromPhase,
    required String toPhase,
    required int currentHp,
    required int maxHp,
  }) {
    // Допустимые переходы
    const validTransitions = {
      'idle': ['attack', 'hurt', 'rage', 'defeat'],
      'attack': ['idle', 'hurt', 'rage'],
      'hurt': ['idle', 'rage', 'defeat'],
      'rage': ['attack', 'hurt', 'defeat'],
      'defeat': <String>[], // Из defeat нельзя перейти
    };

    final allowed = validTransitions[fromPhase];
    if (allowed == null) return false;
    if (!allowed.contains(toPhase)) return false;

    // Дополнительные проверки для специфичных переходов
    if (toPhase == 'rage') {
      final hpPercent = (currentHp / maxHp) * 100;
      return hpPercent <= BossConstants.rageThresholdPercent;
    }

    if (toPhase == 'defeat') {
      return currentHp <= 0;
    }

    return true;
  }
}

/// Валидаторы для времени
abstract class TimeValidators {
  /// Проверяет корректность оставшегося времени
  static bool validateTimeRemaining(int seconds) {
    return seconds >= 0 && seconds <= TimeConstants.answerTimeSeconds;
  }

  /// Проверяет, истекло ли время
  static bool isTimeUp(int seconds) {
    return seconds <= 0;
  }
}

/// Валидаторы для сложности
abstract class DifficultyValidators {
  /// Проверяет корректность уровня сложности
  static bool validateDifficultyLevel(int level) {
    return level >= DifficultyConstants.minDifficulty &&
        level <= DifficultyConstants.maxDifficulty;
  }
}

/// Валидаторы для аудио
abstract class AudioValidators {
  /// Проверяет корректность значения громкости (0.0 - 1.0)
  static bool validateVolume(double volume) {
    return volume >= 0.0 && volume <= 1.0;
  }
}

// ============================================================
// Функции-обёртки для удобного использования
// ============================================================

/// Проверяет, является ли ответ правильным
bool validateAnswer(int answer, int expected) {
  return MathValidators.validateAnswer(answer, expected);
}

/// Проверяет, находится ли множитель в допустимом диапазоне (0-9)
bool validateMultiplier(int multiplier) {
  return MathValidators.validateMultiplier(multiplier);
}
