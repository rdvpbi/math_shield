/// Менеджер аудио
///
/// Управляет воспроизведением музыки с использованием audioplayers.
library;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import '../core/config/game_constants.dart';
import 'sfx_player.dart';

/// Singleton менеджер аудио
class AudioManager {
  static AudioManager? _instance;
  static AudioManager get instance => _instance ??= AudioManager._();

  AudioManager._();

  /// Плеер для музыки
  late final AudioPlayer _musicPlayer;

  /// Плеер для звуковых эффектов
  late final SfxPlayer _sfxPlayer;

  /// Текущая громкость музыки
  double _musicVolume = AudioConstants.defaultMusicVolume;

  /// Текущая громкость SFX
  double _sfxVolume = AudioConstants.defaultSfxVolume;

  /// Громкость до приглушения (duck)
  double _preDuckMusicVolume = AudioConstants.defaultMusicVolume;

  /// Приглушена ли музыка
  bool _isDucked = false;

  /// Текущий трек
  String? _currentTrack;

  /// Инициализирован ли менеджер
  bool _isInitialized = false;

  /// Геттер для проверки инициализации
  bool get isInitialized => _isInitialized;

  /// Геттер текущего трека
  String? get currentTrack => _currentTrack;

  /// Геттер громкости музыки
  double get musicVolume => _musicVolume;

  /// Геттер громкости SFX
  double get sfxVolume => _sfxVolume;

  /// Инициализирует менеджер аудио
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _musicPlayer = AudioPlayer();
      _sfxPlayer = SfxPlayer();

      // Настройки плеера музыки
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer.setVolume(_musicVolume);

      // Инициализируем SFX плеер
      await _sfxPlayer.initialize();

      _isInitialized = true;
      debugPrint('AudioManager: initialized');
    } catch (e) {
      debugPrint('AudioManager: initialization failed - $e');
    }
  }

  /// Освобождает ресурсы
  Future<void> dispose() async {
    if (!_isInitialized) return;

    try {
      await _musicPlayer.dispose();
      await _sfxPlayer.dispose();
      _isInitialized = false;
      debugPrint('AudioManager: disposed');
    } catch (e) {
      debugPrint('AudioManager: dispose failed - $e');
    }
  }

  // ========== Музыка ==========

  /// Воспроизводит музыку
  Future<void> playMusic(String assetPath, {bool loop = true}) async {
    if (!_isInitialized) {
      debugPrint('AudioManager: not initialized, cannot play music');
      return;
    }

    try {
      // Если тот же трек — ничего не делаем
      if (_currentTrack == assetPath) return;

      // Останавливаем текущую музыку
      await _musicPlayer.stop();

      // Устанавливаем режим повтора
      await _musicPlayer.setReleaseMode(
        loop ? ReleaseMode.loop : ReleaseMode.stop,
      );

      // Воспроизводим
      await _musicPlayer.setSource(AssetSource(assetPath));
      await _musicPlayer.setVolume(_musicVolume);
      await _musicPlayer.resume();

      _currentTrack = assetPath;
      debugPrint('AudioManager: playing music - $assetPath');
    } catch (e) {
      debugPrint('AudioManager: playMusic failed - $e');
    }
  }

  /// Останавливает музыку
  Future<void> stopMusic() async {
    if (!_isInitialized) return;

    try {
      await _musicPlayer.stop();
      _currentTrack = null;
      debugPrint('AudioManager: music stopped');
    } catch (e) {
      debugPrint('AudioManager: stopMusic failed - $e');
    }
  }

  /// Ставит музыку на паузу
  Future<void> pauseMusic() async {
    if (!_isInitialized) return;

    try {
      await _musicPlayer.pause();
      debugPrint('AudioManager: music paused');
    } catch (e) {
      debugPrint('AudioManager: pauseMusic failed - $e');
    }
  }

  /// Возобновляет музыку
  Future<void> resumeMusic() async {
    if (!_isInitialized) return;

    try {
      await _musicPlayer.resume();
      debugPrint('AudioManager: music resumed');
    } catch (e) {
      debugPrint('AudioManager: resumeMusic failed - $e');
    }
  }

  /// Устанавливает громкость музыки
  Future<void> setMusicVolume(double volume) async {
    _musicVolume = volume.clamp(0.0, 1.0);

    if (!_isInitialized) return;

    try {
      if (!_isDucked) {
        await _musicPlayer.setVolume(_musicVolume);
      }
      debugPrint('AudioManager: music volume set to $_musicVolume');
    } catch (e) {
      debugPrint('AudioManager: setMusicVolume failed - $e');
    }
  }

  /// Плавное изменение громкости музыки
  Future<void> fadeMusicVolume(
    double targetVolume, {
    Duration duration = const Duration(milliseconds: 500),
  }) async {
    if (!_isInitialized) return;

    final startVolume = _musicVolume;
    final steps = 20;
    final stepDuration = duration ~/ steps;
    final volumeStep = (targetVolume - startVolume) / steps;

    for (var i = 0; i < steps; i++) {
      await Future.delayed(stepDuration);
      final newVolume = startVolume + volumeStep * (i + 1);
      await setMusicVolume(newVolume.clamp(0.0, 1.0));
    }
  }

  /// Приглушает музыку (для диалогов)
  Future<void> duck({double factor = 0.3}) async {
    if (!_isInitialized || _isDucked) return;

    _preDuckMusicVolume = _musicVolume;
    _isDucked = true;

    try {
      await _musicPlayer.setVolume(_musicVolume * factor);
      debugPrint('AudioManager: music ducked');
    } catch (e) {
      debugPrint('AudioManager: duck failed - $e');
    }
  }

  /// Восстанавливает громкость после приглушения
  Future<void> unduck() async {
    if (!_isInitialized || !_isDucked) return;

    _isDucked = false;

    try {
      await _musicPlayer.setVolume(_preDuckMusicVolume);
      debugPrint('AudioManager: music unducked');
    } catch (e) {
      debugPrint('AudioManager: unduck failed - $e');
    }
  }

  // ========== SFX ==========

  /// Воспроизводит звуковой эффект
  Future<void> playSfx(String assetPath) async {
    if (!_isInitialized) {
      debugPrint('AudioManager: not initialized, cannot play SFX');
      return;
    }

    await _sfxPlayer.play(assetPath, volume: _sfxVolume);
  }

  /// Устанавливает громкость звуковых эффектов
  void setSfxVolume(double volume) {
    _sfxVolume = volume.clamp(0.0, 1.0);
    debugPrint('AudioManager: SFX volume set to $_sfxVolume');
  }

  /// Останавливает все звуковые эффекты
  Future<void> stopAllSfx() async {
    if (!_isInitialized) return;
    await _sfxPlayer.stopAll();
  }

  // ========== Утилиты ==========

  /// Останавливает всё аудио
  Future<void> stopAll() async {
    await stopMusic();
    await stopAllSfx();
  }

  /// Предзагружает аудио файлы для быстрого воспроизведения
  Future<void> preloadAssets(List<String> assets) async {
    if (!_isInitialized) return;

    for (final asset in assets) {
      try {
        await AudioCache.instance.load(asset);
        debugPrint('AudioManager: preloaded $asset');
      } catch (e) {
        debugPrint('AudioManager: preload failed for $asset - $e');
      }
    }
  }

  /// Предзагружает все игровые звуки
  Future<void> preloadGameSounds() async {
    final sounds = [
      AudioAssets.sfxCorrect,
      AudioAssets.sfxWrong,
      AudioAssets.sfxCombo,
      AudioAssets.sfxBossHit,
      AudioAssets.sfxBossAttack,
      AudioAssets.sfxBossDefeat,
      AudioAssets.sfxButtonClick,
      AudioAssets.sfxLevelUp,
      AudioAssets.sfxUnlock,
      AudioAssets.sfxStar,
      AudioAssets.sfxCountdown,
      AudioAssets.sfxTimeUp,
    ];

    await preloadAssets(sounds);
  }
}

/// Расширение для предзагрузки из AudioAssets
extension AudioAssetsPreload on AudioAssets {
  /// Все звуковые эффекты для предзагрузки
  static List<String> get allSfx => [
        AudioAssets.sfxCorrect,
        AudioAssets.sfxWrong,
        AudioAssets.sfxCombo,
        AudioAssets.sfxBossHit,
        AudioAssets.sfxBossAttack,
        AudioAssets.sfxBossDefeat,
        AudioAssets.sfxButtonClick,
        AudioAssets.sfxLevelUp,
        AudioAssets.sfxUnlock,
        AudioAssets.sfxStar,
        AudioAssets.sfxCountdown,
        AudioAssets.sfxTimeUp,
      ];

  /// Все музыкальные треки
  static List<String> get allMusic => [
        AudioAssets.musicMenu,
        AudioAssets.musicHub,
        AudioAssets.musicBattle,
        AudioAssets.musicBoss,
        AudioAssets.musicVictory,
      ];
}
