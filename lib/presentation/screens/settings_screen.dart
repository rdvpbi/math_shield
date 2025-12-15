/// Экран настроек
///
/// Позволяет настроить звук, сбросить прогресс и посмотреть информацию.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/controllers/audio_controller.dart';
import '../../application/controllers/game_controller.dart';
import '../../core/config/game_constants.dart';
import '../theme/app_colors.dart';
import '../widgets/filin_helper.dart';

/// Экран настроек
class SettingsScreen extends ConsumerStatefulWidget {
  /// Callback при закрытии
  final VoidCallback? onClose;

  const SettingsScreen({
    super.key,
    this.onClose,
  });

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final audioState = ref.watch(audioControllerProvider);

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
              _buildTopBar(),

              // Основной контент
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(UIConstants.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Раздел звука
                      _buildSoundSection(audioState),

                      const SizedBox(height: UIConstants.paddingLarge),

                      // Раздел прогресса
                      _buildProgressSection(),

                      const SizedBox(height: UIConstants.paddingLarge),

                      // Раздел о приложении
                      _buildAboutSection(),
                    ],
                  ),
                ),
              ),

              // Нижняя панель с Филином
              _buildBottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.all(UIConstants.paddingMedium),
      child: Row(
        children: [
          // Кнопка назад
          IconButton(
            onPressed: widget.onClose,
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.textPrimary,
              size: 28,
            ),
          ),

          const Spacer(),

          // Заголовок
          const Text(
            'Настройки',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          const Spacer(),

          // Пустое место для симметрии
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildSoundSection(AudioState audioState) {
    return _buildSection(
      title: 'Звук',
      icon: Icons.volume_up_rounded,
      children: [
        // Музыка
        _buildSliderTile(
          title: 'Музыка',
          icon: Icons.music_note_rounded,
          value: audioState.musicVolume,
          onChanged: (value) {
            ref.read(audioControllerProvider.notifier).setMusicVolume(value);
          },
        ),

        const SizedBox(height: UIConstants.paddingMedium),

        // Звуковые эффекты
        _buildSliderTile(
          title: 'Звуковые эффекты',
          icon: Icons.speaker_rounded,
          value: audioState.sfxVolume,
          onChanged: (value) {
            ref.read(audioControllerProvider.notifier).setSfxVolume(value);
          },
        ),

        const SizedBox(height: UIConstants.paddingMedium),

        // Переключатели
        _buildSwitchTile(
          title: 'Музыка',
          value: audioState.isMusicEnabled,
          onChanged: (value) {
            ref.read(audioControllerProvider.notifier).toggleMusic();
          },
        ),

        _buildSwitchTile(
          title: 'Звуки',
          value: audioState.isSfxEnabled,
          onChanged: (value) {
            ref.read(audioControllerProvider.notifier).toggleSfx();
          },
        ),
      ],
    );
  }

  Widget _buildProgressSection() {
    return _buildSection(
      title: 'Прогресс',
      icon: Icons.emoji_events_rounded,
      children: [
        // Статистика
        _buildStatsTile(),

        const SizedBox(height: UIConstants.paddingMedium),

        // Кнопка сброса
        _buildResetButton(),
      ],
    );
  }

  Widget _buildAboutSection() {
    return _buildSection(
      title: 'О приложении',
      icon: Icons.info_outline_rounded,
      children: [
        _buildInfoTile(
          title: 'Math Shield',
          subtitle: 'Версия 1.0.0',
          icon: Icons.shield_rounded,
        ),
        _buildInfoTile(
          title: 'Разработано для детей',
          subtitle: 'Обучение умножению через игру',
          icon: Icons.child_care_rounded,
        ),
        _buildInfoTile(
          title: 'Возраст',
          subtitle: '5-9 лет',
          icon: Icons.cake_rounded,
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(UIConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(UIConstants.borderRadiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок раздела
          Row(
            children: [
              Icon(icon, color: AppColors.accent, size: 24),
              const SizedBox(width: UIConstants.paddingSmall),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: UIConstants.paddingMedium),
          const Divider(color: AppColors.textTertiary, height: 1),
          const SizedBox(height: UIConstants.paddingMedium),
          // Контент
          ...children,
        ],
      ),
    );
  }

  Widget _buildSliderTile({
    required String title,
    required IconData icon,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 20),
        const SizedBox(width: UIConstants.paddingSmall),
        Expanded(
          flex: 2,
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.backgroundDark,
              thumbColor: AppColors.accent,
              overlayColor: AppColors.primary.withValues(alpha: 0.2),
              trackHeight: 4,
            ),
            child: Slider(
              value: value,
              onChanged: onChanged,
            ),
          ),
        ),
        SizedBox(
          width: 40,
          child: Text(
            '${(value * 100).toInt()}%',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.accent,
          activeTrackColor: AppColors.primary,
          inactiveThumbColor: AppColors.textTertiary,
          inactiveTrackColor: AppColors.backgroundDark,
        ),
      ],
    );
  }

  Widget _buildStatsTile() {
    final gameState = ref.watch(gameControllerProvider);
    final player = gameState.player;

    return Container(
      padding: const EdgeInsets.all(UIConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
      ),
      child: Column(
        children: [
          _buildStatRow('Очки', '${player.totalScore}', Icons.star_rounded),
          const SizedBox(height: UIConstants.paddingSmall),
          _buildStatRow('Текущий мир', '×${player.currentWorld}', Icons.public_rounded),
          const SizedBox(height: UIConstants.paddingSmall),
          _buildStatRow('Жизни', '${player.lives}/${player.maxLives}', Icons.favorite_rounded),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.accent, size: 20),
        const SizedBox(width: UIConstants.paddingSmall),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildResetButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _showResetConfirmation,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error.withValues(alpha: 0.2),
          foregroundColor: AppColors.error,
          padding: const EdgeInsets.symmetric(
            vertical: UIConstants.paddingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
            side: const BorderSide(color: AppColors.error),
          ),
        ),
        icon: const Icon(Icons.restart_alt_rounded),
        label: const Text(
          'Сбросить прогресс',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: UIConstants.paddingSmall),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(UIConstants.borderRadiusSmall),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: UIConstants.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
      child: const Row(
        children: [
          // Филин
          FilinCompact(
            mood: FilinMood.neutral,
            size: 48,
          ),

          SizedBox(width: UIConstants.paddingMedium),

          // Подсказка
          Expanded(
            child: Text(
              'Настрой игру под себя!',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UIConstants.borderRadiusLarge),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_rounded, color: AppColors.error),
            SizedBox(width: UIConstants.paddingSmall),
            Text(
              'Сбросить прогресс?',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: const Text(
          'Все твои достижения, звёзды и очки будут удалены. Это действие нельзя отменить!',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Отмена',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetProgress();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Сбросить'),
          ),
        ],
      ),
    );
  }

  void _resetProgress() {
    ref.read(gameControllerProvider.notifier).resetProgress();

    // Показываем подтверждение
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success),
            SizedBox(width: UIConstants.paddingSmall),
            Text('Прогресс сброшен!'),
          ],
        ),
        backgroundColor: AppColors.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
        ),
      ),
    );
  }
}

/// Настройки для показа в диалоге
class SettingsDialog extends StatelessWidget {
  const SettingsDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SettingsDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.backgroundDark,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(UIConstants.borderRadiusLarge),
            ),
          ),
          child: SettingsScreen(
            onClose: () => Navigator.of(context).pop(),
          ),
        );
      },
    );
  }
}
