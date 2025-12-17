/// Экран мира (уровня)
///
/// Универсальный экран для прохождения уровня с примерами.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/controllers/audio_controller.dart';
import '../../application/controllers/game_controller.dart';
import '../../application/controllers/math_controller.dart';
import '../../core/config/game_constants.dart';
import '../../domain/entities/world_entity.dart';
import '../dialogs/defeat_popup.dart';
import '../dialogs/filin_dialog.dart';
import '../dialogs/pause_popup.dart';
import '../dialogs/victory_popup.dart';
import '../theme/app_colors.dart';
import '../widgets/answer_pad.dart';
import '../widgets/filin_helper.dart';
import '../widgets/health_bar.dart';
import '../widgets/math_hud.dart';

/// Экран мира
class WorldScreen extends ConsumerStatefulWidget {
  /// Данные мира
  final WorldEntity world;

  /// Callback при завершении уровня
  final VoidCallback? onComplete;

  /// Callback при выходе
  final VoidCallback? onExit;

  /// Callback для перехода к боссу
  final VoidCallback? onBossBattle;

  const WorldScreen({
    super.key,
    required this.world,
    this.onComplete,
    this.onExit,
    this.onBossBattle,
  });

  @override
  ConsumerState<WorldScreen> createState() => _WorldScreenState();
}

class _WorldScreenState extends ConsumerState<WorldScreen>
    with TickerProviderStateMixin {
  late AnimationController _resultController;
  late Animation<double> _resultAnimation;

  bool _showResult = false;
  bool? _lastAnswerCorrect;
  int _lastPoints = 0;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initGame();
  }

  void _initAnimations() {
    _resultController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _resultAnimation = CurvedAnimation(
      parent: _resultController,
      curve: Curves.elasticOut,
    );
  }

  void _initGame() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mathController = ref.read(mathControllerProvider.notifier);
      mathController.initialize(widget.world.id);
      mathController.generateTask();
    });
  }

  @override
  void dispose() {
    _resultController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mathState = ref.watch(mathControllerProvider);
    final gameState = ref.watch(gameControllerProvider);
    final worldColors = WorldPalettes.getWorld(widget.world.id);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: worldColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Верхняя панель
              _buildTopBar(gameState, mathState),

              // HUD с примером
              Padding(
                padding: const EdgeInsets.all(UIConstants.paddingMedium),
                child: MathHud(
                  currentTask: mathState.currentTask,
                  timeRemaining: mathState.timeRemaining,
                  score: mathState.sessionScore,
                  combo: mathState.combo,
                  comboMultiplier: 1 + mathState.combo * ComboConstants.multiplierPerCombo,
                  tasksCompleted: mathState.tasksCompleted,
                  totalTasks: WorldConstants.examplesPerLevel,
                ),
              ),

              // Зона результата
              Expanded(
                child: Center(
                  child: _showResult
                      ? _buildResultDisplay()
                      : _buildFilinHint(mathState),
                ),
              ),

              // Клавиатура ввода
              Padding(
                padding: const EdgeInsets.all(UIConstants.paddingMedium),
                child: AnswerPad(
                  currentInput: mathState.inputValue,
                  isDisabled: mathState.currentTask == null || _showResult,
                  onDigitPressed: _onDigitPressed,
                  onDeletePressed: _onDeletePressed,
                  onClearPressed: _onClearPressed,
                  onConfirmPressed: _onConfirmPressed,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(gameState, mathState) {
    return Padding(
      padding: const EdgeInsets.all(UIConstants.paddingSmall),
      child: Row(
        children: [
          // Кнопка паузы
          IconButton(
            onPressed: _onPause,
            icon: const Icon(
              Icons.pause_circle_outline,
              color: AppColors.textPrimary,
              size: 32,
            ),
          ),

          // Жизни
          _buildLivesDisplay(gameState.player.lives),

          const Spacer(),

          // Название мира
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                widget.world.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '×${widget.world.multiplier}',
                style: TextStyle(
                  fontSize: 14,
                  color: WorldPalettes.getWorld(widget.world.id).accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLivesDisplay(int lives) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(PlayerConstants.maxLives, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Icon(
            index < lives ? Icons.favorite : Icons.favorite_border,
            color: index < lives ? AppColors.error : AppColors.textTertiary,
            size: 24,
          ),
        );
      }),
    );
  }

  Widget _buildResultDisplay() {
    return ScaleTransition(
      scale: _resultAnimation,
      child: AnswerResultWidget(
        isCorrect: _lastAnswerCorrect ?? false,
        points: _lastPoints,
      ),
    );
  }

  Widget _buildFilinHint(mathState) {
    if (mathState.currentTask == null) {
      return const SizedBox.shrink();
    }

    // Показываем подсказку, если долго думает
    if (mathState.timeRemaining <= TimeConstants.warningTimeSeconds &&
        mathState.timeRemaining > TimeConstants.criticalTimeSeconds) {
      return const FilinHelper(
        message: 'Вспомни таблицу умножения!',
        mood: FilinMood.thinking,
        size: 60,
      );
    }

    if (mathState.timeRemaining <= TimeConstants.criticalTimeSeconds) {
      return const FilinHelper(
        message: 'Торопись!',
        mood: FilinMood.encouraging,
        size: 60,
      );
    }

    return const SizedBox.shrink();
  }

  void _onDigitPressed(String digit) {
    ref.read(mathControllerProvider.notifier).addDigit(digit);
  }

  void _onDeletePressed() {
    ref.read(mathControllerProvider.notifier).removeDigit();
  }

  void _onClearPressed() {
    ref.read(mathControllerProvider.notifier).clearInput();
  }

  void _onConfirmPressed() {
    final result = ref.read(mathControllerProvider.notifier).confirmAnswer();
    if (result == null) return;

    setState(() {
      _showResult = true;
      _lastAnswerCorrect = result.isCorrect;
      _lastPoints = result.score;
    });

    // Воспроизводим звук
    final audioController = ref.read(audioControllerProvider.notifier);
    if (result.isCorrect) {
      audioController.playCorrect();
      if (result.combo >= ComboConstants.comboThresholdGreat) {
        audioController.playCombo();
      }
    } else {
      audioController.playWrong();
      // Теряем жизнь при ошибке
      ref.read(gameControllerProvider.notifier).loseLife();
    }

    // Показываем анимацию результата
    _resultController.forward(from: 0);

    // Проверяем условия завершения
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;

      setState(() => _showResult = false);

      final mathState = ref.read(mathControllerProvider);
      final gameState = ref.read(gameControllerProvider);

      // Проверяем поражение (нет жизней)
      if (gameState.player.lives <= 0) {
        _showDefeatPopup();
        return;
      }

      // Проверяем завершение уровня
      if (mathState.tasksCompleted >= WorldConstants.examplesPerLevel) {
        _showVictoryPopup();
        return;
      }

      // Генерируем следующий пример
      ref.read(mathControllerProvider.notifier).generateTask();
    });
  }

  void _onPause() {
    ref.read(mathControllerProvider.notifier).pauseTimer();

    PausePopup.show(
      context,
      worldName: widget.world.name,
      currentScore: ref.read(mathControllerProvider).sessionScore,
      showRestart: true,
    ).then((action) {
      switch (action) {
        case PauseAction.resume:
          ref.read(mathControllerProvider.notifier).resumeTimer();
          break;
        case PauseAction.restart:
          _restartLevel();
          break;
        case PauseAction.settings:
          // TODO: Открыть настройки
          ref.read(mathControllerProvider.notifier).resumeTimer();
          break;
        case PauseAction.exit:
          widget.onExit?.call();
          break;
        case null:
          ref.read(mathControllerProvider.notifier).resumeTimer();
          break;
      }
    });
  }

  void _restartLevel() {
    final mathController = ref.read(mathControllerProvider.notifier);
    mathController.reset();
    mathController.initialize(widget.world.id);
    mathController.generateTask();
  }

  void _showVictoryPopup() {
    final mathState = ref.read(mathControllerProvider);
    final stars = _calculateStars(mathState.accuracy);

    ref.read(audioControllerProvider.notifier).playStar();

    VictoryPopup.show(
      context,
      stars: stars,
      score: mathState.sessionScore,
      bestScore: widget.world.bestScore,
      correctAnswers: mathState.correctAnswers,
      totalAnswers: mathState.tasksCompleted,
      maxCombo: ref.read(mathControllerProvider.notifier).maxCombo,
      showNextButton: !widget.world.bossDefeated,
      nextButtonText: 'К боссу!',
      onNext: () {
        Navigator.of(context).pop();
        widget.onBossBattle?.call();
      },
      onRetry: () {
        Navigator.of(context).pop();
        _restartLevel();
      },
      onToHub: () {
        Navigator.of(context).pop();
        widget.onExit?.call();
      },
    );
  }

  void _showDefeatPopup() {
    final mathState = ref.read(mathControllerProvider);
    final gameState = ref.read(gameControllerProvider);

    DefeatPopup.show(
      context,
      score: mathState.sessionScore,
      correctAnswers: mathState.correctAnswers,
      totalAnswers: mathState.tasksCompleted,
      livesRemaining: gameState.player.lives,
      message: DefeatMessages.getRandomEncouragement(),
      onRetry: gameState.player.lives > 0
          ? () {
              Navigator.of(context).pop();
              _restartLevel();
            }
          : null,
      onToHub: () {
        Navigator.of(context).pop();
        widget.onExit?.call();
      },
    );
  }

  int _calculateStars(double accuracy) {
    if (accuracy >= ScoreConstants.threeStarThreshold / 100) return 3;
    if (accuracy >= ScoreConstants.twoStarThreshold / 100) return 2;
    if (accuracy >= ScoreConstants.oneStarThreshold / 100) return 1;
    return 0;
  }
}
