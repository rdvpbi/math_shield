/// Тесты для ComboService
///
/// Проверяет комбо-систему и расчёт множителей.
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:math_shield/application/services/combo_service.dart';
import 'package:math_shield/core/config/game_constants.dart';

void main() {
  late ComboService comboService;

  setUp(() {
    comboService = ComboService();
  });

  group('ComboService - Initial State', () {
    test('должен начинаться с нулевыми значениями', () {
      expect(comboService.currentCombo, 0);
      expect(comboService.maxCombo, 0);
      expect(comboService.totalCombos, 0);
      expect(comboService.multiplier, 1.0);
    });

    test('должен начинаться без Math Shield', () {
      expect(comboService.hasMathShield, false);
    });

    test('должен начинаться с уровнем комбо none', () {
      expect(comboService.comboLevel, ComboLevel.none);
    });
  });

  group('ComboService - onCorrectAnswer', () {
    test('должен увеличивать комбо на 1', () {
      comboService.onCorrectAnswer();
      expect(comboService.currentCombo, 1);
    });

    test('должен увеличивать totalCombos', () {
      comboService.onCorrectAnswer();
      comboService.onCorrectAnswer();
      expect(comboService.totalCombos, 2);
    });

    test('должен обновлять maxCombo', () {
      comboService.onCorrectAnswer();
      comboService.onCorrectAnswer();
      comboService.onCorrectAnswer();
      expect(comboService.maxCombo, 3);

      // После сброса maxCombo не должен уменьшаться
      comboService.reset();
      expect(comboService.maxCombo, 3);
    });

    test('должен возвращать множитель', () {
      final multiplier = comboService.onCorrectAnswer();
      expect(multiplier, greaterThan(1.0));
    });

    test('должен увеличивать множитель с каждым комбо', () {
      final mult1 = comboService.onCorrectAnswer();
      final mult2 = comboService.onCorrectAnswer();
      final mult3 = comboService.onCorrectAnswer();

      expect(mult2, greaterThan(mult1));
      expect(mult3, greaterThan(mult2));
    });
  });

  group('ComboService - onWrongAnswer', () {
    test('должен сбрасывать комбо до 0', () {
      comboService.onCorrectAnswer();
      comboService.onCorrectAnswer();
      comboService.onCorrectAnswer();
      expect(comboService.currentCombo, 3);

      comboService.onWrongAnswer();
      expect(comboService.currentCombo, 0);
    });

    test('должен возвращать потерянное комбо', () {
      comboService.onCorrectAnswer();
      comboService.onCorrectAnswer();
      comboService.onCorrectAnswer();

      final lost = comboService.onWrongAnswer();
      expect(lost, 3);
    });

    test('должен возвращать 0 если комбо не было', () {
      final lost = comboService.onWrongAnswer();
      expect(lost, 0);
    });

    test('не должен влиять на maxCombo и totalCombos', () {
      comboService.onCorrectAnswer();
      comboService.onCorrectAnswer();
      comboService.onCorrectAnswer();

      final maxBefore = comboService.maxCombo;
      final totalBefore = comboService.totalCombos;

      comboService.onWrongAnswer();

      expect(comboService.maxCombo, maxBefore);
      expect(comboService.totalCombos, totalBefore);
    });
  });

  group('ComboService - calculateDamage', () {
    test('должен возвращать базовый урон при нулевом комбо', () {
      const baseDamage = 10;
      final damage = comboService.calculateDamage(baseDamage);
      expect(damage, baseDamage);
    });

    test('должен увеличивать урон с комбо', () {
      const baseDamage = 10;

      comboService.onCorrectAnswer();
      comboService.onCorrectAnswer();

      final damage = comboService.calculateDamage(baseDamage);
      expect(damage, greaterThan(baseDamage));
    });

    test('должен ограничивать множитель максимальным значением', () {
      const baseDamage = 10;

      // Набираем много комбо
      for (var i = 0; i < 20; i++) {
        comboService.onCorrectAnswer();
      }

      final damage = comboService.calculateDamage(baseDamage);
      final maxDamage =
          (baseDamage * ComboConstants.maxComboMultiplier).round();

      expect(damage, lessThanOrEqualTo(maxDamage));
    });
  });

  group('ComboService - calculateScore', () {
    test('должен возвращать базовые очки при нулевом комбо', () {
      const baseScore = 100;
      final score = comboService.calculateScore(baseScore);
      expect(score, baseScore);
    });

    test('должен увеличивать очки с комбо', () {
      const baseScore = 100;

      comboService.onCorrectAnswer();
      comboService.onCorrectAnswer();

      final score = comboService.calculateScore(baseScore);
      expect(score, greaterThan(baseScore));
    });

    test('должен давать +10% за каждый уровень комбо', () {
      const baseScore = 100;

      comboService.onCorrectAnswer(); // combo = 1
      final score1 = comboService.calculateScore(baseScore);
      expect(score1, 110); // 100 * 1.1

      comboService.onCorrectAnswer(); // combo = 2
      final score2 = comboService.calculateScore(baseScore);
      expect(score2, 120); // 100 * 1.2
    });
  });

  group('ComboService - useMathShield', () {
    test('должен возвращать false если комбо недостаточно', () {
      comboService.onCorrectAnswer();
      comboService.onCorrectAnswer();

      final result = comboService.useMathShield();
      expect(result, false);
    });

    test('должен возвращать true и уменьшать комбо при достаточном уровне',
        () {
      // Набираем достаточно комбо для Math Shield
      for (var i = 0; i < ComboConstants.mathShieldComboThreshold; i++) {
        comboService.onCorrectAnswer();
      }

      expect(comboService.hasMathShield, true);

      final comboBefore = comboService.currentCombo;
      final result = comboService.useMathShield();

      expect(result, true);
      expect(
        comboService.currentCombo,
        comboBefore - ComboConstants.mathShieldComboThreshold,
      );
    });
  });

  group('ComboService - comboLevel', () {
    test('должен возвращать none при combo = 0', () {
      expect(comboService.comboLevel, ComboLevel.none);
    });

    test('должен возвращать good при combo = 1-2', () {
      comboService.onCorrectAnswer();
      expect(comboService.comboLevel, ComboLevel.good);

      comboService.onCorrectAnswer();
      expect(comboService.comboLevel, ComboLevel.good);
    });

    test('должен возвращать great при combo = 3-4', () {
      for (var i = 0; i < 3; i++) {
        comboService.onCorrectAnswer();
      }
      expect(comboService.comboLevel, ComboLevel.great);

      comboService.onCorrectAnswer();
      expect(comboService.comboLevel, ComboLevel.great);
    });

    test('должен возвращать epic при combo = 5-9', () {
      for (var i = 0; i < 5; i++) {
        comboService.onCorrectAnswer();
      }
      expect(comboService.comboLevel, ComboLevel.epic);

      for (var i = 0; i < 4; i++) {
        comboService.onCorrectAnswer();
      }
      expect(comboService.comboLevel, ComboLevel.epic);
    });

    test('должен возвращать legendary при combo >= 10', () {
      for (var i = 0; i < 10; i++) {
        comboService.onCorrectAnswer();
      }
      expect(comboService.comboLevel, ComboLevel.legendary);

      for (var i = 0; i < 5; i++) {
        comboService.onCorrectAnswer();
      }
      expect(comboService.comboLevel, ComboLevel.legendary);
    });
  });

  group('ComboService - bonus thresholds', () {
    test('hasBonusCoins должен быть true при combo >= 5', () {
      for (var i = 0; i < ComboConstants.bonusCoinsComboThreshold - 1; i++) {
        comboService.onCorrectAnswer();
      }
      expect(comboService.hasBonusCoins, false);

      comboService.onCorrectAnswer();
      expect(comboService.hasBonusCoins, true);
    });

    test('hasGoldenSparkles должен быть true при combo >= 3', () {
      for (var i = 0; i < ComboConstants.goldenSparklesComboThreshold - 1; i++) {
        comboService.onCorrectAnswer();
      }
      expect(comboService.hasGoldenSparkles, false);

      comboService.onCorrectAnswer();
      expect(comboService.hasGoldenSparkles, true);
    });
  });

  group('ComboService - reset methods', () {
    test('reset должен обнулять только currentCombo', () {
      for (var i = 0; i < 5; i++) {
        comboService.onCorrectAnswer();
      }

      final maxBefore = comboService.maxCombo;
      final totalBefore = comboService.totalCombos;

      comboService.reset();

      expect(comboService.currentCombo, 0);
      expect(comboService.maxCombo, maxBefore);
      expect(comboService.totalCombos, totalBefore);
    });

    test('fullReset должен обнулять все значения', () {
      for (var i = 0; i < 5; i++) {
        comboService.onCorrectAnswer();
      }

      comboService.fullReset();

      expect(comboService.currentCombo, 0);
      expect(comboService.maxCombo, 0);
      expect(comboService.totalCombos, 0);
    });

    test('resetSession должен обнулять currentCombo и maxCombo', () {
      for (var i = 0; i < 5; i++) {
        comboService.onCorrectAnswer();
      }

      final totalBefore = comboService.totalCombos;

      comboService.resetSession();

      expect(comboService.currentCombo, 0);
      expect(comboService.maxCombo, 0);
      expect(comboService.totalCombos, totalBefore);
    });
  });

  group('ComboService - text getters', () {
    test('comboText должен возвращать пустую строку при combo = 0', () {
      expect(comboService.comboText, '');
    });

    test('comboText должен возвращать форматированное значение', () {
      comboService.onCorrectAnswer();
      comboService.onCorrectAnswer();
      comboService.onCorrectAnswer();

      expect(comboService.comboText, '×3');
    });

    test('multiplierText должен возвращать пустую строку при multiplier = 1.0',
        () {
      expect(comboService.multiplierText, '');
    });

    test('multiplierText должен возвращать форматированное значение', () {
      comboService.onCorrectAnswer();
      comboService.onCorrectAnswer();

      expect(comboService.multiplierText, contains('×'));
    });
  });

  group('ComboLevel extension', () {
    test('name должен возвращать правильные названия', () {
      expect(ComboLevel.none.name, '');
      expect(ComboLevel.good.name, 'Хорошо!');
      expect(ComboLevel.great.name, 'Отлично!');
      expect(ComboLevel.epic.name, 'Великолепно!');
      expect(ComboLevel.legendary.name, 'ЛЕГЕНДАРНО!');
    });

    test('colorValue должен возвращать правильные цвета', () {
      expect(ComboLevel.none.colorValue, 0xFFFFFFFF);
      expect(ComboLevel.good.colorValue, 0xFF4CAF50);
      expect(ComboLevel.great.colorValue, 0xFF2196F3);
      expect(ComboLevel.epic.colorValue, 0xFF9C27B0);
      expect(ComboLevel.legendary.colorValue, 0xFFFF9800);
    });
  });

  group('ComboService - static getMultiplier', () {
    test('должен возвращать 1.0 при combo = 0', () {
      expect(ComboService.getMultiplier(0), 1.0);
    });

    test('должен увеличиваться с комбо', () {
      expect(ComboService.getMultiplier(1), greaterThan(1.0));
      expect(ComboService.getMultiplier(2), greaterThan(ComboService.getMultiplier(1)));
    });

    test('не должен превышать максимальный множитель', () {
      expect(
        ComboService.getMultiplier(100),
        lessThanOrEqualTo(ComboConstants.maxComboMultiplier),
      );
    });
  });
}
