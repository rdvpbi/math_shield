/// Сервис наград
///
/// Рассчитывает очки, монеты и бонусы.
library;

import '../../core/config/game_constants.dart';

/// Данные о награде
class RewardData {
  /// Базовые очки
  final int baseScore;

  /// Бонус за комбо
  final int comboBonus;

  /// Бонус за быстрый ответ
  final int speedBonus;

  /// Бонус за безошибочность
  final int perfectBonus;

  /// Монеты
  final int coins;

  /// Опыт
  final int experience;

  const RewardData({
    this.baseScore = 0,
    this.comboBonus = 0,
    this.speedBonus = 0,
    this.perfectBonus = 0,
    this.coins = 0,
    this.experience = 0,
  });

  /// Общий счёт
  int get totalScore => baseScore + comboBonus + speedBonus + perfectBonus;

  /// Создаёт пустую награду
  factory RewardData.empty() => const RewardData();

  /// Сложение наград
  RewardData operator +(RewardData other) {
    return RewardData(
      baseScore: baseScore + other.baseScore,
      comboBonus: comboBonus + other.comboBonus,
      speedBonus: speedBonus + other.speedBonus,
      perfectBonus: perfectBonus + other.perfectBonus,
      coins: coins + other.coins,
      experience: experience + other.experience,
    );
  }

  @override
  String toString() {
    return 'RewardData(total: $totalScore, coins: $coins, exp: $experience)';
  }
}

/// Сервис наград
class RewardService {
  /// Рассчитывает счёт за правильный ответ
  ///
  /// [combo] - текущее комбо
  /// [timeSpentSeconds] - время на ответ в секундах
  /// [difficulty] - уровень сложности
  int calculateScore({
    required int combo,
    required int timeSpentSeconds,
    int difficulty = 1,
  }) {
    // Базовые очки
    int score = ScoreConstants.correctAnswerBase;

    // Бонус за сложность: +20% за каждый уровень
    final difficultyMultiplier = 1.0 + (difficulty - 1) * 0.2;
    score = (score * difficultyMultiplier).round();

    // Бонус за быстрый ответ
    if (timeSpentSeconds < ScoreConstants.fastAnswerThresholdSeconds) {
      score += ScoreConstants.fastAnswerBonus;
    }

    // Бонус за комбо: +10% за каждый уровень комбо
    final comboMultiplier = 1.0 + (combo * 0.1);
    score = (score * comboMultiplier).round();

    return score;
  }

  /// Рассчитывает полную награду за ответ
  RewardData calculateReward({
    required bool isCorrect,
    required int combo,
    required int timeSpentSeconds,
    int difficulty = 1,
  }) {
    if (!isCorrect) {
      return RewardData.empty();
    }

    // Базовые очки
    final baseScore = ScoreConstants.correctAnswerBase;

    // Бонус за комбо
    final comboBonus = (baseScore * combo * 0.1).round();

    // Бонус за скорость
    final speedBonus =
        timeSpentSeconds < ScoreConstants.fastAnswerThresholdSeconds
            ? ScoreConstants.fastAnswerBonus
            : 0;

    // Монеты: 1 за ответ + бонус за комбо
    final coins = 1 + (combo >= 5 ? 1 : 0);

    // Опыт: базовый + бонус за сложность
    final experience = 10 + (difficulty - 1) * 5;

    return RewardData(
      baseScore: baseScore,
      comboBonus: comboBonus,
      speedBonus: speedBonus,
      coins: coins,
      experience: experience,
    );
  }

  /// Рассчитывает награду за победу над боссом
  RewardData calculateBossReward({
    required int worldId,
    required int correctAnswers,
    required int totalAnswers,
    required int maxCombo,
    required int timeSpentSeconds,
  }) {
    // Базовый счёт за правильные ответы
    final baseScore = correctAnswers * ScoreConstants.correctAnswerBase;

    // Множитель за победу над боссом
    final bossMultiplier = ScoreConstants.bossVictoryMultiplier;

    // Бонус за безошибочность
    final perfectBonus = correctAnswers == totalAnswers
        ? (baseScore * 0.5).round()
        : 0;

    // Бонус за комбо
    final comboBonus = (maxCombo * 50);

    // Монеты: больше за боссов
    final coins = 10 + worldId * 5 + (correctAnswers == totalAnswers ? 10 : 0);

    // Опыт
    final experience = 100 + worldId * 20;

    return RewardData(
      baseScore: (baseScore * bossMultiplier).round(),
      comboBonus: comboBonus,
      perfectBonus: perfectBonus,
      coins: coins,
      experience: experience,
    );
  }

  /// Рассчитывает награду за прохождение уровня
  RewardData calculateLevelReward({
    required int worldId,
    required int correctAnswers,
    required int totalAnswers,
    required int maxCombo,
    required int sessionScore,
  }) {
    // Бонус за безошибочность
    final perfectBonus = correctAnswers == totalAnswers
        ? (sessionScore * 0.25).round()
        : 0;

    // Монеты за уровень
    final coins = 5 + worldId * 2;

    // Опыт
    final experience = 50 + worldId * 10;

    return RewardData(
      baseScore: sessionScore,
      perfectBonus: perfectBonus,
      coins: coins,
      experience: experience,
    );
  }

  /// Получает данные о награде для мира
  RewardData getRewardForWorld(int worldId) {
    // Базовые награды за мир увеличиваются с каждым миром
    return RewardData(
      baseScore: 1000 + worldId * 500,
      coins: 20 + worldId * 10,
      experience: 100 + worldId * 25,
    );
  }

  /// Рассчитывает урон боссу
  int calculateBossDamage({
    required int combo,
    required bool isFastAnswer,
  }) {
    // Базовый урон
    int damage = BossConstants.baseDamage;

    // Множитель комбо
    final comboMultiplier = ComboConstants.calculateMultiplier(combo);
    damage = (damage * comboMultiplier).round();

    // Бонус за быстрый ответ
    if (isFastAnswer) {
      damage = (damage * 1.2).round();
    }

    return damage;
  }

  /// Форматирует счёт для отображения
  String formatScore(int score) {
    if (score >= 1000000) {
      return '${(score / 1000000).toStringAsFixed(1)}M';
    }
    if (score >= 1000) {
      return '${(score / 1000).toStringAsFixed(1)}K';
    }
    return score.toString();
  }
}
