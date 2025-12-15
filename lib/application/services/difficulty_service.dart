/// Сервис управления сложностью
///
/// Адаптивная система сложности на основе успехов игрока.
library;

import '../../core/config/game_constants.dart';

/// Сервис управления сложностью
class DifficultyService {
  /// Текущий уровень сложности (1-5)
  int _currentDifficulty;

  /// Счётчик правильных ответов подряд
  int _correctStreak;

  /// Счётчик неправильных ответов подряд
  int _wrongStreak;

  /// История последних ответов (true = правильный)
  final List<bool> _recentAnswers;

  /// Максимальный размер истории
  static const int _historySize = 20;

  /// Создаёт сервис сложности
  DifficultyService({int initialDifficulty = 1})
      : _currentDifficulty = initialDifficulty.clamp(
          DifficultyConstants.minDifficulty,
          DifficultyConstants.maxDifficulty,
        ),
        _correctStreak = 0,
        _wrongStreak = 0,
        _recentAnswers = [];

  /// Текущий уровень сложности
  int get currentDifficulty => _currentDifficulty;

  /// Счётчик правильных ответов подряд
  int get correctStreak => _correctStreak;

  /// Счётчик неправильных ответов подряд
  int get wrongStreak => _wrongStreak;

  /// Процент правильных за последние N ответов
  double get recentAccuracy {
    if (_recentAnswers.isEmpty) return 0.0;
    final correct = _recentAnswers.where((a) => a).length;
    return correct / _recentAnswers.length;
  }

  /// Проверяет, минимальная ли сложность
  bool get isMinDifficulty =>
      _currentDifficulty <= DifficultyConstants.minDifficulty;

  /// Проверяет, максимальная ли сложность
  bool get isMaxDifficulty =>
      _currentDifficulty >= DifficultyConstants.maxDifficulty;

  /// Название текущего уровня сложности
  String get difficultyName {
    switch (_currentDifficulty) {
      case 1:
        return 'Легко';
      case 2:
        return 'Нормально';
      case 3:
        return 'Средне';
      case 4:
        return 'Сложно';
      case 5:
        return 'Эксперт';
      default:
        return 'Неизвестно';
    }
  }

  /// Регистрирует правильный ответ
  ///
  /// Возвращает true, если сложность повысилась
  bool onCorrectAnswer() {
    _correctStreak++;
    _wrongStreak = 0;
    _addToHistory(true);

    // Проверяем условие повышения сложности
    if (_correctStreak >= DifficultyConstants.correctToIncrease) {
      return increaseDifficulty();
    }

    return false;
  }

  /// Регистрирует неправильный ответ
  ///
  /// Возвращает true, если сложность понизилась
  bool onWrongAnswer() {
    _wrongStreak++;
    _correctStreak = 0;
    _addToHistory(false);

    // Проверяем условие понижения сложности
    if (_wrongStreak >= DifficultyConstants.wrongToDecrease) {
      return decreaseDifficulty();
    }

    return false;
  }

  /// Повышает сложность на 1
  ///
  /// Возвращает true, если сложность изменилась
  bool increaseDifficulty() {
    if (_currentDifficulty >= DifficultyConstants.maxDifficulty) {
      return false;
    }

    _currentDifficulty++;
    _correctStreak = 0;
    return true;
  }

  /// Понижает сложность на 1
  ///
  /// Возвращает true, если сложность изменилась
  bool decreaseDifficulty() {
    if (_currentDifficulty <= DifficultyConstants.minDifficulty) {
      return false;
    }

    _currentDifficulty--;
    _wrongStreak = 0;
    return true;
  }

  /// Устанавливает сложность напрямую
  void setDifficulty(int difficulty) {
    _currentDifficulty = difficulty.clamp(
      DifficultyConstants.minDifficulty,
      DifficultyConstants.maxDifficulty,
    );
    _correctStreak = 0;
    _wrongStreak = 0;
  }

  /// Сбрасывает сервис
  void reset({int initialDifficulty = 1}) {
    _currentDifficulty = initialDifficulty.clamp(
      DifficultyConstants.minDifficulty,
      DifficultyConstants.maxDifficulty,
    );
    _correctStreak = 0;
    _wrongStreak = 0;
    _recentAnswers.clear();
  }

  /// Добавляет ответ в историю
  void _addToHistory(bool correct) {
    _recentAnswers.add(correct);
    if (_recentAnswers.length > _historySize) {
      _recentAnswers.removeAt(0);
    }
  }

  /// Рассчитывает рекомендуемую сложность на основе истории
  int calculateRecommendedDifficulty() {
    if (_recentAnswers.length < 5) {
      return _currentDifficulty;
    }

    final accuracy = recentAccuracy;

    if (accuracy >= 0.9) {
      return (_currentDifficulty + 1).clamp(
        DifficultyConstants.minDifficulty,
        DifficultyConstants.maxDifficulty,
      );
    } else if (accuracy < 0.5) {
      return (_currentDifficulty - 1).clamp(
        DifficultyConstants.minDifficulty,
        DifficultyConstants.maxDifficulty,
      );
    }

    return _currentDifficulty;
  }

  /// Автоматически корректирует сложность
  bool autoAdjust() {
    final recommended = calculateRecommendedDifficulty();
    if (recommended != _currentDifficulty) {
      _currentDifficulty = recommended;
      return true;
    }
    return false;
  }
}
