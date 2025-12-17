/// Все игровые константы Math Shield
///
/// Этот файл содержит все числовые константы игры.
/// Изменение значений здесь влияет на всю игру.
library;

/// Константы миров и прогрессии
abstract class WorldConstants {
  /// Общее количество миров (0-9, таблица умножения)
  static const int totalWorlds = 10;

  /// Минимальный множитель (мир 0)
  static const int minMultiplier = 0;

  /// Максимальный множитель (мир 9)
  static const int maxMultiplier = 9;

  /// Диапазон второго множителя в примерах (0-10)
  static const int minMultiplicand = 0;
  static const int maxMultiplicand = 10;

  /// Количество примеров для прохождения уровня
  static const int examplesPerLevel = 10;

  /// Количество примеров в битве с боссом
  static const int examplesPerBoss = 15;
}

/// Константы игрока
abstract class PlayerConstants {
  /// Начальное количество жизней
  static const int initialLives = 3;

  /// Максимальное количество жизней
  static const int maxLives = 5;

  /// Начальный счёт
  static const int initialScore = 0;

  /// Начальный мир (разблокирован по умолчанию)
  static const int startingWorld = 0;
}

/// Константы времени
abstract class TimeConstants {
  /// Время на ответ в секундах
  static const int answerTimeSeconds = 15;

  /// Время на ответ в миллисекундах
  static const int answerTimeMs = answerTimeSeconds * 1000;

  /// Дополнительное время за правильный ответ (секунды)
  static const int bonusTimeSeconds = 2;

  /// Время отображения splash screen (миллисекунды)
  static const int splashDurationMs = 2500;

  /// Задержка перед автопереходом после победы (мс)
  static const int victoryDelayMs = 1500;

  /// Задержка перед автопереходом после поражения (мс)
  static const int defeatDelayMs = 2000;

  /// Время предупреждения (жёлтый таймер)
  static const int warningTimeSeconds = 5;

  /// Критическое время (красный таймер)
  static const int criticalTimeSeconds = 3;
}

/// Константы очков и наград
abstract class ScoreConstants {
  /// Очки за правильный ответ (базовые)
  static const int correctAnswerBase = 100;

  /// Бонус за быстрый ответ (< 5 сек)
  static const int fastAnswerBonus = 50;

  /// Порог быстрого ответа (секунды)
  static const int fastAnswerThresholdSeconds = 5;

  /// Штраф за неправильный ответ (потеря очков)
  static const int wrongAnswerPenalty = 0; // Для детей — без штрафа

  /// Множитель очков за победу над боссом
  static const double bossVictoryMultiplier = 2.0;

  /// Порог для 1 звезды (% правильных)
  static const int oneStarThreshold = 50;

  /// Порог для 2 звёзд (% правильных)
  static const int twoStarThreshold = 70;

  /// Порог для 3 звёзд (% правильных)
  static const int threeStarThreshold = 90;
}

/// Константы комбо-системы
abstract class ComboConstants {
  /// Начальное значение комбо
  static const int initialCombo = 0;

  /// Прирост комбо за правильный ответ
  static const int comboIncrement = 1;

  /// Множитель урона на единицу комбо
  static const double comboMultiplierStep = 0.5;

  /// Максимальный множитель урона от комбо
  static const double maxComboMultiplier = 5.0;

  /// Комбо для активации "Math Shield" (автокоррекция)
  static const int mathShieldComboThreshold = 10;

  /// Комбо для бонусных монет
  static const int bonusCoinsComboThreshold = 5;

  /// Комбо для золотых искр (визуальный эффект)
  static const int goldenSparklesComboThreshold = 3;

  /// Порог комбо для "Great!" звука
  static const int comboThresholdGreat = 3;

  /// Множитель на единицу комбо
  static const double multiplierPerCombo = 0.1;

  /// Вычисляет множитель урона для текущего комбо
  static double calculateMultiplier(int combo) {
    final multiplier = 1.0 + combo * comboMultiplierStep;
    return multiplier.clamp(1.0, maxComboMultiplier);
  }
}

/// Константы боссов
abstract class BossConstants {
  /// Базовое HP босса
  static const int baseHp = 100;

  /// Прирост HP за каждый мир
  static const int hpPerWorld = 100;

  /// Базовый урон от правильного ответа
  static const int baseDamage = 10;

  /// Порог HP для перехода в режим RAGE (%)
  static const int rageThresholdPercent = 30;

  /// Время между атаками босса (мс)
  static const int attackIntervalMs = 3000;

  /// Урон босса игроку (в жизнях)
  static const double bossAttackDamage = 0.5;

  /// Вычисляет HP босса для указанного мира
  static int calculateBossHp(int worldIndex) {
    return baseHp + worldIndex * hpPerWorld;
  }

  /// Проверяет, должен ли босс перейти в режим RAGE
  static bool shouldEnterRage(int currentHp, int maxHp) {
    final percentage = (currentHp / maxHp) * 100;
    return percentage <= rageThresholdPercent && percentage > 0;
  }
}

/// Константы сложности
abstract class DifficultyConstants {
  /// Минимальный уровень сложности
  static const int minDifficulty = 1;

  /// Максимальный уровень сложности
  static const int maxDifficulty = 5;

  /// Начальный уровень сложности
  static const int initialDifficulty = 1;

  /// Правильных ответов подряд для повышения сложности
  static const int correctToIncrease = 5;

  /// Ошибок подряд для понижения сложности
  static const int wrongToDecrease = 3;
}

/// Константы UI для детей (размеры в dp)
abstract class UIConstants {
  /// Минимальный размер touch target (WCAG)
  static const double minTouchTarget = 48.0;

  /// Размер кнопок ответа
  static const double answerButtonSize = 64.0;

  /// Отступ между кнопками
  static const double buttonSpacing = 16.0;

  /// Размер кнопок главного меню
  static const double menuButtonWidth = 200.0;
  static const double menuButtonHeight = 90.0;

  /// Минимальная ширина кнопки
  static const double buttonMinWidth = 88.0;

  /// Стандартная высота кнопки
  static const double buttonHeight = 48.0;

  /// Размер иконок
  static const double iconSizeSmall = 24.0;
  static const double iconSizeMedium = 48.0;
  static const double iconSizeLarge = 64.0;
  static const double iconSizeXLarge = 96.0;

  /// Размер шрифта для примеров (большой для детей)
  static const double mathExampleFontSize = 48.0;

  /// Размер шрифта для ответов
  static const double answerFontSize = 32.0;

  /// Размер шрифта для HUD
  static const double hudFontSize = 24.0;

  /// Размер шрифта для заголовков
  static const double titleFontSize = 36.0;

  /// Размер шрифта для обычного текста
  static const double bodyFontSize = 18.0;

  /// Радиус скругления кнопок
  static const double buttonBorderRadius = 16.0;

  /// Радиус скругления карточек
  static const double cardBorderRadius = 24.0;

  /// Радиусы скругления (общие)
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 16.0;
  static const double borderRadiusLarge = 24.0;

  /// Размер кнопки мира на хабе
  static const double worldButtonSize = 80.0;

  /// Стандартные отступы
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  /// Высота health bar
  static const double healthBarHeight = 20.0;

  /// Ширина health bar
  static const double healthBarWidth = 200.0;

  /// Размер портрета персонажа в диалоге
  static const double dialogPortraitSize = 80.0;
}

/// Константы анимаций (длительности в миллисекундах)
abstract class AnimationConstants {
  /// Быстрая анимация (кнопки, hover)
  static const int durationFastMs = 150;

  /// Стандартная анимация (переходы)
  static const int durationNormalMs = 250;

  /// Медленная анимация (появление экранов)
  static const int durationSlowMs = 400;

  /// Очень медленная анимация (специальные эффекты)
  static const int durationExtraSlowMs = 600;

  /// Анимация правильного ответа
  static const int correctAnswerMs = 300;

  /// Анимация неправильного ответа
  static const int wrongAnswerMs = 400;

  /// Анимация урона боссу
  static const int bossDamageMs = 200;

  /// Анимация атаки босса
  static const int bossAttackMs = 500;

  /// Анимация поражения босса
  static const int bossDefeatMs = 800;

  /// Анимация обновления health bar
  static const int healthBarUpdateMs = 300;

  /// Анимация появления комбо
  static const int comboPopMs = 250;

  /// Анимация shake при ошибке
  static const int shakeMs = 300;

  /// Анимация bounce кнопки
  static const int buttonBounceMs = 100;

  /// Анимация scale кнопки (1.0 → 1.1 → 1.0)
  static const double buttonScaleUp = 1.1;
  static const double buttonScaleNormal = 1.0;

  /// Duration объекты для удобства
  static const Duration durationFast = Duration(milliseconds: durationFastMs);
  static const Duration durationNormal = Duration(milliseconds: durationNormalMs);
  static const Duration durationSlow = Duration(milliseconds: durationSlowMs);
  static const Duration durationExtraSlow = Duration(milliseconds: durationExtraSlowMs);
}

/// Константы аудио
abstract class AudioConstants {
  /// Громкость музыки по умолчанию (0.0 - 1.0)
  static const double defaultMusicVolume = 0.7;

  /// Громкость звуков по умолчанию (0.0 - 1.0)
  static const double defaultSfxVolume = 1.0;

  /// Максимальное количество одновременных SFX
  static const int maxSimultaneousSfx = 8;

  /// Fade duration для музыки (мс)
  static const int musicFadeDurationMs = 500;
}

/// Константы для хранения данных (ключи SharedPreferences)
abstract class StorageKeys {
  static const String playerData = 'math_shield_player';
  static const String worldsData = 'math_shield_worlds';
  static const String settingsData = 'math_shield_settings';
  static const String statisticsData = 'math_shield_statistics';
  static const String firstLaunch = 'math_shield_first_launch';
}
