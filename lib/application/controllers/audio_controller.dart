/// Контроллер аудио
///
/// Управляет музыкой и звуковыми эффектами.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/game_constants.dart';

/// Состояние аудио
class AudioState {
  /// Громкость музыки (0.0 - 1.0)
  final double musicVolume;

  /// Громкость звуков (0.0 - 1.0)
  final double sfxVolume;

  /// Включена ли музыка
  final bool isMusicEnabled;

  /// Включены ли звуки
  final bool isSfxEnabled;

  /// Текущий трек
  final String? currentTrack;

  /// Играет ли музыка
  final bool isMusicPlaying;

  const AudioState({
    this.musicVolume = AudioConstants.defaultMusicVolume,
    this.sfxVolume = AudioConstants.defaultSfxVolume,
    this.isMusicEnabled = true,
    this.isSfxEnabled = true,
    this.currentTrack,
    this.isMusicPlaying = false,
  });

  /// Начальное состояние
  factory AudioState.initial() => const AudioState();

  /// Создаёт копию с изменёнными полями
  AudioState copyWith({
    double? musicVolume,
    double? sfxVolume,
    bool? isMusicEnabled,
    bool? isSfxEnabled,
    String? currentTrack,
    bool? isMusicPlaying,
    bool clearTrack = false,
  }) {
    return AudioState(
      musicVolume: musicVolume ?? this.musicVolume,
      sfxVolume: sfxVolume ?? this.sfxVolume,
      isMusicEnabled: isMusicEnabled ?? this.isMusicEnabled,
      isSfxEnabled: isSfxEnabled ?? this.isSfxEnabled,
      currentTrack: clearTrack ? null : (currentTrack ?? this.currentTrack),
      isMusicPlaying: isMusicPlaying ?? this.isMusicPlaying,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AudioState &&
        other.musicVolume == musicVolume &&
        other.sfxVolume == sfxVolume &&
        other.isMusicEnabled == isMusicEnabled &&
        other.isSfxEnabled == isSfxEnabled &&
        other.currentTrack == currentTrack &&
        other.isMusicPlaying == isMusicPlaying;
  }

  @override
  int get hashCode {
    return Object.hash(
      musicVolume,
      sfxVolume,
      isMusicEnabled,
      isSfxEnabled,
      currentTrack,
      isMusicPlaying,
    );
  }
}

/// Константы путей к аудио файлам
abstract class AudioAssets {
  // Музыка
  static const String musicMenu = 'audio/music/menu.mp3';
  static const String musicHub = 'audio/music/hub.mp3';
  static const String musicBattle = 'audio/music/battle.mp3';
  static const String musicBoss = 'audio/music/boss.mp3';
  static const String musicVictory = 'audio/music/victory.mp3';

  // Звуковые эффекты
  static const String sfxCorrect = 'audio/sfx/correct.wav';
  static const String sfxWrong = 'audio/sfx/wrong.wav';
  static const String sfxCombo = 'audio/sfx/combo.wav';
  static const String sfxBossHit = 'audio/sfx/boss_hit.wav';
  static const String sfxBossAttack = 'audio/sfx/boss_attack.wav';
  static const String sfxBossDefeat = 'audio/sfx/boss_defeat.wav';
  static const String sfxButtonClick = 'audio/sfx/button_click.wav';
  static const String sfxLevelUp = 'audio/sfx/level_up.wav';
  static const String sfxUnlock = 'audio/sfx/unlock.wav';
  static const String sfxStar = 'audio/sfx/star.wav';
  static const String sfxCountdown = 'audio/sfx/countdown.wav';
  static const String sfxTimeUp = 'audio/sfx/time_up.wav';
}

/// Контроллер аудио
///
/// Примечание: Реальное воспроизведение требует audioplayers пакета.
/// Этот контроллер управляет состоянием, а AudioManager выполняет воспроизведение.
class AudioController extends Notifier<AudioState> {
  @override
  AudioState build() {
    return AudioState.initial();
  }

  /// Воспроизводит музыку
  void playMusic(String track) {
    if (!state.isMusicEnabled) return;

    state = state.copyWith(
      currentTrack: track,
      isMusicPlaying: true,
    );

    // TODO: Вызвать AudioManager для реального воспроизведения
    // AudioManager.instance.playMusic(track, volume: state.musicVolume);
  }

  /// Останавливает музыку
  void stopMusic() {
    state = state.copyWith(
      isMusicPlaying: false,
      clearTrack: true,
    );

    // TODO: AudioManager.instance.stopMusic();
  }

  /// Ставит музыку на паузу
  void pauseMusic() {
    state = state.copyWith(isMusicPlaying: false);
    // TODO: AudioManager.instance.pauseMusic();
  }

  /// Возобновляет музыку
  void resumeMusic() {
    if (!state.isMusicEnabled || state.currentTrack == null) return;

    state = state.copyWith(isMusicPlaying: true);
    // TODO: AudioManager.instance.resumeMusic();
  }

  /// Воспроизводит звуковой эффект
  void playSfx(String sound) {
    if (!state.isSfxEnabled) return;

    // TODO: AudioManager.instance.playSfx(sound, volume: state.sfxVolume);
  }

  /// Воспроизводит звук правильного ответа
  void playCorrect() => playSfx(AudioAssets.sfxCorrect);

  /// Воспроизводит звук неправильного ответа
  void playWrong() => playSfx(AudioAssets.sfxWrong);

  /// Воспроизводит звук комбо
  void playCombo() => playSfx(AudioAssets.sfxCombo);

  /// Воспроизводит звук удара по боссу
  void playBossHit() => playSfx(AudioAssets.sfxBossHit);

  /// Воспроизводит звук атаки босса
  void playBossAttack() => playSfx(AudioAssets.sfxBossAttack);

  /// Воспроизводит звук победы над боссом
  void playBossDefeat() => playSfx(AudioAssets.sfxBossDefeat);

  /// Воспроизводит звук клика кнопки
  void playButtonClick() => playSfx(AudioAssets.sfxButtonClick);

  /// Воспроизводит звук повышения уровня
  void playLevelUp() => playSfx(AudioAssets.sfxLevelUp);

  /// Воспроизводит звук разблокировки
  void playUnlock() => playSfx(AudioAssets.sfxUnlock);

  /// Воспроизводит звук получения звезды
  void playStar() => playSfx(AudioAssets.sfxStar);

  /// Воспроизводит звук обратного отсчёта
  void playCountdown() => playSfx(AudioAssets.sfxCountdown);

  /// Воспроизводит звук истечения времени
  void playTimeUp() => playSfx(AudioAssets.sfxTimeUp);

  /// Устанавливает громкость музыки
  void setMusicVolume(double volume) {
    final clampedVolume = volume.clamp(0.0, 1.0);
    state = state.copyWith(musicVolume: clampedVolume);
    // TODO: AudioManager.instance.setMusicVolume(clampedVolume);
  }

  /// Устанавливает громкость звуков
  void setSfxVolume(double volume) {
    final clampedVolume = volume.clamp(0.0, 1.0);
    state = state.copyWith(sfxVolume: clampedVolume);
    // TODO: AudioManager.instance.setSfxVolume(clampedVolume);
  }

  /// Включает/выключает музыку
  void toggleMusic() {
    final newEnabled = !state.isMusicEnabled;
    state = state.copyWith(isMusicEnabled: newEnabled);

    if (!newEnabled) {
      stopMusic();
    }
  }

  /// Включает/выключает звуки
  void toggleSfx() {
    state = state.copyWith(isSfxEnabled: !state.isSfxEnabled);
  }

  /// Включает музыку
  void enableMusic() {
    state = state.copyWith(isMusicEnabled: true);
  }

  /// Выключает музыку
  void disableMusic() {
    state = state.copyWith(isMusicEnabled: false);
    stopMusic();
  }

  /// Включает звуки
  void enableSfx() {
    state = state.copyWith(isSfxEnabled: true);
  }

  /// Выключает звуки
  void disableSfx() {
    state = state.copyWith(isSfxEnabled: false);
  }

  /// Останавливает всё аудио
  void stopAll() {
    stopMusic();
    // TODO: AudioManager.instance.stopAllSfx();
  }

  /// Приглушает аудио (для диалогов)
  void duck() {
    // TODO: AudioManager.instance.duck();
  }

  /// Восстанавливает громкость после приглушения
  void unduck() {
    // TODO: AudioManager.instance.unduck();
  }

  /// Сбрасывает состояние
  void reset() {
    stopAll();
    state = AudioState.initial();
  }
}

/// Provider для AudioController
final audioControllerProvider =
    NotifierProvider<AudioController, AudioState>(AudioController.new);
