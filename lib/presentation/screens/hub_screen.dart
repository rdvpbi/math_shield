/// Экран хаба (Центральный экран)
///
/// Отображает все миры и позволяет выбрать уровень.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/controllers/game_controller.dart';
import '../../application/controllers/world_controller.dart';
import '../../core/config/game_constants.dart';
import '../../domain/entities/world_entity.dart';
import '../dialogs/filin_dialog.dart';
import '../theme/app_colors.dart';
import '../widgets/filin_helper.dart';
import '../widgets/world_button.dart';

/// Экран хаба
class HubScreen extends ConsumerStatefulWidget {
  /// Callback при выборе мира
  final ValueChanged<WorldEntity>? onWorldSelected;

  /// Callback при нажатии настроек
  final VoidCallback? onSettingsPressed;

  const HubScreen({
    super.key,
    this.onWorldSelected,
    this.onSettingsPressed,
  });

  @override
  ConsumerState<HubScreen> createState() => _HubScreenState();
}

class _HubScreenState extends ConsumerState<HubScreen> {
  bool _showFilinGreeting = false;

  @override
  void initState() {
    super.initState();
    // Показываем приветствие Филина при первом запуске
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFirstLaunch();
    });
  }

  void _checkFirstLaunch() {
    final gameState = ref.read(gameControllerProvider);
    if (gameState.isFirstLaunch) {
      setState(() => _showFilinGreeting = true);
      _showWelcomeDialog();
    }
  }

  void _showWelcomeDialog() {
    FilinDialog.show(
      context,
      message: FilinMessages.welcomeFirst,
      title: 'Привет!',
      mood: FilinMood.happy,
    ).then((_) {
      ref.read(gameControllerProvider.notifier).markFirstLaunchComplete();
      setState(() => _showFilinGreeting = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameControllerProvider);
    final worldState = ref.watch(worldControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.backgroundLight,
              AppColors.backgroundDark,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Верхняя панель
              _buildTopBar(gameState),

              // Основной контент
              Expanded(
                child: worldState.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : worldState.error != null
                        ? _buildError(worldState.error!)
                        : _buildContent(worldState.worlds),
              ),

              // Нижняя панель с Филином
              _buildBottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(gameState) {
    return Padding(
      padding: const EdgeInsets.all(UIConstants.paddingMedium),
      child: Row(
        children: [
          // Жизни
          _buildLivesDisplay(gameState.player.lives, gameState.player.maxLives),

          const Spacer(),

          // Заголовок
          const Text(
            'Математический Проспект',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          const Spacer(),

          // Настройки
          IconButton(
            onPressed: widget.onSettingsPressed,
            icon: const Icon(
              Icons.settings,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLivesDisplay(int lives, int maxLives) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: UIConstants.paddingMedium,
        vertical: UIConstants.paddingSmall,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...List.generate(maxLives, (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Icon(
                index < lives ? Icons.favorite : Icons.favorite_border,
                color: index < lives ? AppColors.error : AppColors.textTertiary,
                size: 20,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: UIConstants.paddingMedium),
          Text(
            'Ошибка загрузки',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: UIConstants.paddingSmall),
          Text(
            error,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: UIConstants.paddingLarge),
          ElevatedButton(
            onPressed: () {
              ref.read(worldControllerProvider.notifier).loadWorlds();
            },
            child: const Text('Повторить'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(List<WorldEntity> worlds) {
    return Column(
      children: [
        // Общий прогресс
        _buildProgressBar(worlds),

        const SizedBox(height: UIConstants.paddingMedium),

        // Сетка миров
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: UIConstants.paddingMedium,
            ),
            child: _buildWorldsGrid(worlds),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(List<WorldEntity> worlds) {
    final completedCount = worlds.where((w) => w.isCompleted).length;
    final totalStars = worlds.fold<int>(0, (sum, w) => sum + w.stars);
    final maxStars = worlds.length * 3;
    final progress = worlds.isEmpty ? 0.0 : completedCount / worlds.length;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: UIConstants.paddingMedium,
      ),
      padding: const EdgeInsets.all(UIConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Прогресс: $completedCount/${worlds.length} миров',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star, color: AppColors.star, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '$totalStars/$maxStars',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: UIConstants.paddingSmall),
          ClipRRect(
            borderRadius: BorderRadius.circular(UIConstants.borderRadiusSmall),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.backgroundDark,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorldsGrid(List<WorldEntity> worlds) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Определяем количество колонок на основе ширины
        final crossAxisCount = constraints.maxWidth > 600 ? 5 : 4;
        final buttonSize = (constraints.maxWidth - (crossAxisCount + 1) * UIConstants.paddingMedium) / crossAxisCount;

        return GridView.builder(
          padding: const EdgeInsets.only(bottom: UIConstants.paddingLarge),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: UIConstants.paddingMedium,
            crossAxisSpacing: UIConstants.paddingMedium,
            childAspectRatio: 0.7,
          ),
          itemCount: worlds.length,
          itemBuilder: (context, index) {
            final world = worlds[index];
            return WorldButton(
              world: world,
              size: buttonSize.clamp(60.0, UIConstants.worldButtonSize),
              onTap: world.isUnlocked
                  ? () => _onWorldTap(world)
                  : null,
            );
          },
        );
      },
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(UIConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.5),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(UIConstants.borderRadiusLarge),
        ),
      ),
      child: Row(
        children: [
          // Филин
          GestureDetector(
            onTap: _showFilinHelp,
            child: const FilinCompact(
              mood: FilinMood.neutral,
              size: 48,
            ),
          ),

          const SizedBox(width: UIConstants.paddingMedium),

          // Подсказка
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                _showFilinGreeting
                    ? 'Привет! Я Филин!'
                    : 'Нажми на меня для подсказки!',
                key: ValueKey(_showFilinGreeting),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onWorldTap(WorldEntity world) {
    widget.onWorldSelected?.call(world);
  }

  void _showFilinHelp() {
    final worldState = ref.read(worldControllerProvider);
    final nextWorld = worldState.nextLockedWorld;

    String message;
    FilinMood mood;

    if (nextWorld != null) {
      final prevWorld = worldState.worlds
          .where((w) => w.id == nextWorld.id - 1)
          .firstOrNull;
      if (prevWorld != null && !prevWorld.bossDefeated) {
        message = 'Победи босса мира "${prevWorld.name}", чтобы открыть "${nextWorld.name}"!';
        mood = FilinMood.encouraging;
      } else {
        message = 'Выбери мир и начни тренировку! Чем больше звёзд - тем лучше!';
        mood = FilinMood.happy;
      }
    } else {
      message = 'Ты открыл все миры! Попробуй получить 3 звезды в каждом!';
      mood = FilinMood.happy;
    }

    FilinDialog.show(
      context,
      message: message,
      mood: mood,
    );
  }
}
