/// Экран битвы с боссом
///
/// Основной игровой экран для сражения с боссом мира.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/controllers/audio_controller.dart';
import '../../application/controllers/boss_controller.dart';
import '../../application/controllers/game_controller.dart';
import '../../application/controllers/math_controller.dart';
import '../../core/config/game_constants.dart';
import '../../domain/entities/boss_entity.dart';
import '../../domain/entities/world_entity.dart';
import '../dialogs/defeat_popup.dart';
import '../dialogs/pause_popup.dart';
import '../dialogs/sleshsh_dialog.dart';
import '../dialogs/victory_popup.dart';
import '../theme/app_colors.dart';
import '../widgets/answer_pad.dart';
import '../widgets/boss_widget.dart';
import '../widgets/math_hud.dart';

/// Экран битвы с боссом
class BossScreen extends ConsumerStatefulWidget {
  /// Данные мира
  final WorldEntity world;

  /// Callback при победе
  final VoidCallback? onVictory;

  /// Callback при поражении
  final VoidCallback? onDefeat;

  /// Callback при выходе
  final VoidCallback? onExit;

  const BossScreen({
    super.key,
    required this.world,
    this.onVictory,
    this.onDefeat,
    this.onExit,
  });

  @override
  ConsumerState<BossScreen> createState() => _BossScreenState();
}

class _BossScreenState extends ConsumerState<BossScreen>
    with TickerProviderStateMixin {
  late AnimationController _damageController;
  late Animation<double> _damageAnimation;

  bool _showDamage = false;
  int _lastDamage = 0;
  bool _battleStarted = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initBattle();
  }

  void _initAnimations() {
    _damageController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _damageAnimation = CurvedAnimation(
      parent: _damageController,
      curve: Curves.easeOut,
    );
  }

  void _initBattle() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Инициализируем босса
      ref.read(bossControllerProvider.notifier).initBoss(widget.world.id);

      // Инициализируем математику
      final mathController = ref.read(mathControllerProvider.notifier);
      mathController.initialize(widget.world.id);

      // Показываем диалог босса
      _showBossIntro();
    });
  }

  void _showBossIntro() {
    final bossState = ref.read(bossControllerProvider);
    final bossName = bossState.boss?.name ?? 'Босс';

    BossIntroDialog.show(
      context,
      worldId: widget.world.id,
      bossName: bossName,
    ).then((_) {
      _startBattle();
    });
  }

  void _startBattle() {
    setState(() => _battleStarted = true);
    ref.read(mathControllerProvider.notifier).generateTask();
    ref.read(bossControllerProvider.notifier).startAutoAttack();
    ref.read(audioControllerProvider.notifier).playMusic(AudioAssets.musicBoss);
  }

  @override
  void dispose() {
    _damageController.dispose();
    ref.read(bossControllerProvider.notifier).stopAutoAttack();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bossState = ref.watch(bossControllerProvider);
    final mathState = ref.watch(mathControllerProvider);
    final gameState = ref.watch(gameControllerProvider);
    final worldColors = WorldPalettes.getWorld(widget.world.id);

    // Проверяем условия завершения
    _checkBattleEnd(bossState, gameState);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: worldColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Верхняя панель
              _buildTopBar(gameState),

              // Босс
              Expanded(
                flex: 2,
                child: _buildBossArea(bossState),
              ),

              // HUD с примером
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: UIConstants.paddingMedium,
                ),
                child: CompactMathHud(
                  currentTask: mathState.currentTask,
                  timeRemaining: mathState.timeRemaining,
                  combo: mathState.combo,
                ),
              ),

              // Клавиатура
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.all(UIConstants.paddingMedium),
                  child: AnswerPad(
                    currentInput: mathState.currentInput,
                    isDisabled: !_battleStarted ||
                        mathState.currentTask == null ||
                        bossState.isVictory ||
                        bossState.isDefeat,
                    onDigitPressed: _onDigitPressed,
                    onDeletePressed: _onDeletePressed,
                    onClearPressed: _onClearPressed,
                    onConfirmPressed: _onConfirmPressed,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(gameState) {
    return Padding(
      padding: const EdgeInsets.all(UIConstants.paddingSmall),
      child: Row(
        children: [
          // Кнопка паузы
          IconButton(
            onPressed: _battleStarted ? _onPause : null,
            icon: const Icon(
              Icons.pause_circle_outline,
              color: AppColors.textPrimary,
              size: 32,
            ),
          ),

          // Жизни игрока
          _buildLivesDisplay(gameState.player.lives),

          const Spacer(),

          // Название мира
          Text(
            widget.world.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
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

  Widget _buildBossArea(BossState bossState) {
    if (bossState.boss == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        // Босс
        BossWidget(
          boss: bossState.boss!,
          showHealthBar: true,
          showName: true,
          message: bossState.bossMessage,
          size: 150,
          onDefeatAnimationComplete: _onBossDefeated,
        ),

        // Отображение урона
        if (_showDamage)
          Positioned(
            top: 20,
            child: FadeTransition(
              opacity: _damageAnimation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: Offset.zero,
                  end: const Offset(0, -1),
                ).animate(_damageAnimation),
                child: Text(
                  '-$_lastDamage',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        blurRadius: 4,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
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

    final audioController = ref.read(audioControllerProvider.notifier);
    final bossController = ref.read(bossControllerProvider.notifier);

    if (result.isCorrect) {
      // Наносим урон боссу
      bossController.onCorrectAnswer(
        combo: result.combo,
        isFastAnswer: result.isFastAnswer,
      );

      // Показываем урон
      setState(() {
        _showDamage = true;
        _lastDamage = result.damage;
      });
      _damageController.forward(from: 0).then((_) {
        if (mounted) setState(() => _showDamage = false);
      });

      // Звуки
      audioController.playCorrect();
      audioController.playBossHit();

      if (result.combo >= ComboConstants.comboThresholdGreat) {
        audioController.playCombo();
      }
    } else {
      // Босс атакует
      bossController.onWrongAnswer();
      audioController.playWrong();
      audioController.playBossAttack();

      // Теряем жизнь
      ref.read(gameControllerProvider.notifier).loseLife();
    }

    // Генерируем следующий пример (если битва продолжается)
    final bossState = ref.read(bossControllerProvider);
    if (!bossState.isVictory && !bossState.isDefeat) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          ref.read(mathControllerProvider.notifier).generateTask();
        }
      });
    }
  }

  void _checkBattleEnd(BossState bossState, gameState) {
    // Проверяем поражение игрока
    if (gameState.player.lives <= 0 && !bossState.isDefeat) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(bossControllerProvider.notifier).onPlayerDefeated();
        _showDefeatPopup();
      });
    }
  }

  void _onBossDefeated() {
    ref.read(audioControllerProvider.notifier).playBossDefeat();
    _showVictoryPopup();
  }

  void _onPause() {
    ref.read(mathControllerProvider.notifier).pauseTimer();
    ref.read(bossControllerProvider.notifier).stopAutoAttack();

    PausePopup.show(
      context,
      worldName: 'Босс: ${ref.read(bossControllerProvider).boss?.name}',
    ).then((action) {
      switch (action) {
        case PauseAction.resume:
          ref.read(mathControllerProvider.notifier).resumeTimer();
          ref.read(bossControllerProvider.notifier).startAutoAttack();
          break;
        case PauseAction.exit:
          widget.onExit?.call();
          break;
        case PauseAction.settings:
        case PauseAction.restart:
        case null:
          ref.read(mathControllerProvider.notifier).resumeTimer();
          ref.read(bossControllerProvider.notifier).startAutoAttack();
          break;
      }
    });
  }

  void _showVictoryPopup() {
    final mathState = ref.read(mathControllerProvider);

    ref.read(audioControllerProvider.notifier).playMusic(AudioAssets.musicVictory);

    VictoryPopup.show(
      context,
      title: 'Босс побеждён!',
      stars: 3, // За победу над боссом всегда 3 звезды
      score: mathState.score,
      correctAnswers: mathState.correctAnswers,
      totalAnswers: mathState.tasksCompleted,
      maxCombo: ref.read(mathControllerProvider.notifier).maxCombo,
      showNextButton: true,
      nextButtonText: 'Отлично!',
      onNext: () {
        Navigator.of(context).pop();
        widget.onVictory?.call();
      },
      onToHub: () {
        Navigator.of(context).pop();
        widget.onVictory?.call();
      },
    );
  }

  void _showDefeatPopup() {
    final mathState = ref.read(mathControllerProvider);
    final gameState = ref.read(gameControllerProvider);
    final bossState = ref.read(bossControllerProvider);

    DefeatPopup.show(
      context,
      title: 'Босс победил...',
      message: BossTaunts.getDefeatPhrase(widget.world.id),
      score: mathState.score,
      correctAnswers: mathState.correctAnswers,
      totalAnswers: mathState.tasksCompleted,
      livesRemaining: gameState.player.lives,
      showFilin: true,
      onRetry: gameState.player.lives > 0
          ? () {
              Navigator.of(context).pop();
              _restartBattle();
            }
          : null,
      onToHub: () {
        Navigator.of(context).pop();
        widget.onDefeat?.call();
      },
    );
  }

  void _restartBattle() {
    // Сбрасываем состояние
    ref.read(bossControllerProvider.notifier).restoreBoss();
    ref.read(mathControllerProvider.notifier).reset();
    ref.read(mathControllerProvider.notifier).initialize(widget.world.id);

    setState(() {
      _battleStarted = false;
      _showDamage = false;
    });

    // Начинаем заново
    _showBossIntro();
  }
}
