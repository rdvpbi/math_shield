/// Сервис прогресса
///
/// Рассчитывает звёзды, прогресс и условия разблокировки.
library;

import '../../core/config/game_constants.dart';
import '../../domain/entities/player_entity.dart';
import '../../domain/entities/world_entity.dart';

/// Сервис прогресса
class ProgressService {
  /// Рассчитывает количество звёзд по проценту правильных ответов
  ///
  /// [correctPercent] - процент правильных (0-100)
  int calculateStars(int correctPercent) {
    if (correctPercent >= ScoreConstants.threeStarThreshold) return 3;
    if (correctPercent >= ScoreConstants.twoStarThreshold) return 2;
    if (correctPercent >= ScoreConstants.oneStarThreshold) return 1;
    return 0;
  }

  /// Рассчитывает звёзды по количеству правильных и всего
  int calculateStarsFromCount(int correct, int total) {
    if (total == 0) return 0;
    final percent = (correct / total * 100).round();
    return calculateStars(percent);
  }

  /// Рассчитывает звёзды по счёту
  int calculateStarsFromScore(int score, int worldId) {
    // Максимальный счёт для мира
    final maxScore = _calculateMaxScore(worldId);
    final percent = (score / maxScore * 100).round().clamp(0, 100);
    return calculateStars(percent);
  }

  /// Рассчитывает максимальный счёт для мира
  int _calculateMaxScore(int worldId) {
    final baseScore = WorldConstants.examplesPerLevel *
        ScoreConstants.correctAnswerBase;
    // Добавляем бонусы за быстрые ответы и комбо
    return (baseScore * 1.5).round();
  }

  /// Проверяет, нужно ли разблокировать следующий мир
  bool shouldUnlockNextWorld(WorldEntity currentWorld) {
    // Разблокируем, если босс побеждён
    return currentWorld.bossDefeated;
  }

  /// Проверяет, можно ли разблокировать мир
  bool canUnlockWorld(int worldId, List<WorldEntity> worlds) {
    // Первый мир всегда разблокирован
    if (worldId == 0) return true;

    // Для остальных нужно победить босса предыдущего мира
    final prevWorld = worlds.firstWhere(
      (w) => w.id == worldId - 1,
      orElse: () => throw ArgumentError('Previous world not found'),
    );

    return prevWorld.bossDefeated;
  }

  /// Получает следующий мир для разблокировки
  int? getNextWorldToUnlock(List<WorldEntity> worlds) {
    for (final world in worlds) {
      if (!world.isUnlocked) {
        // Проверяем, можно ли его разблокировать
        if (canUnlockWorld(world.id, worlds)) {
          return world.id;
        }
        break;
      }
    }
    return null;
  }

  /// Рассчитывает общий процент завершения
  double calculateTotalProgress(List<WorldEntity> worlds) {
    if (worlds.isEmpty) return 0.0;

    final total = worlds.fold<double>(
      0.0,
      (sum, w) => sum + w.completionPercentage,
    );

    return total / worlds.length;
  }

  /// Рассчитывает общее количество звёзд
  int calculateTotalStars(List<WorldEntity> worlds) {
    return worlds.fold(0, (sum, w) => sum + w.stars);
  }

  /// Максимальное количество звёзд
  int get maxTotalStars => WorldConstants.totalWorlds * 3;

  /// Проверяет, получены ли все звёзды
  bool hasAllStars(List<WorldEntity> worlds) {
    return calculateTotalStars(worlds) >= maxTotalStars;
  }

  /// Проверяет, пройдены ли все миры
  bool isGameCompleted(List<WorldEntity> worlds) {
    return worlds.every((w) => w.bossDefeated);
  }

  /// Рассчитывает уровень игрока на основе прогресса
  int calculatePlayerLevel(PlayerEntity player, List<WorldEntity> worlds) {
    final stars = calculateTotalStars(worlds);
    final bossesDefeated = worlds.where((w) => w.bossDefeated).length;

    // Формула: 1 уровень за каждые 3 звезды + 1 за каждого босса
    return 1 + (stars ~/ 3) + bossesDefeated;
  }

  /// Получает название ранга игрока
  String getPlayerRank(int level) {
    if (level >= 30) return 'Гранд-Мастер';
    if (level >= 25) return 'Мастер';
    if (level >= 20) return 'Эксперт';
    if (level >= 15) return 'Профи';
    if (level >= 10) return 'Знаток';
    if (level >= 5) return 'Ученик';
    return 'Новичок';
  }

  /// Рассчитывает прогресс до следующего уровня
  double calculateLevelProgress(int currentLevel, int totalStars) {
    final starsForCurrentLevel = (currentLevel - 1) * 3;
    final starsForNextLevel = currentLevel * 3;
    final starsInLevel = totalStars - starsForCurrentLevel;
    final starsNeeded = starsForNextLevel - starsForCurrentLevel;

    return (starsInLevel / starsNeeded).clamp(0.0, 1.0);
  }
}
