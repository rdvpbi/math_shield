/// Плеер звуковых эффектов
///
/// Управляет пулом плееров для одновременного воспроизведения SFX.
library;

import 'dart:collection';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import '../core/config/game_constants.dart';

/// Плеер звуковых эффектов с пулом
class SfxPlayer {
  /// Пул плееров для одновременного воспроизведения
  final List<AudioPlayer> _playerPool = [];

  /// Очередь свободных плееров
  final Queue<AudioPlayer> _availablePlayers = Queue();

  /// Максимальное количество одновременных звуков
  final int maxPlayers;

  /// Инициализирован ли плеер
  bool _isInitialized = false;

  /// Геттер для проверки инициализации
  bool get isInitialized => _isInitialized;

  /// Создаёт плеер звуковых эффектов
  SfxPlayer({
    this.maxPlayers = AudioConstants.maxSimultaneousSfx,
  });

  /// Инициализирует пул плееров
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      for (var i = 0; i < maxPlayers; i++) {
        final player = AudioPlayer();
        await player.setReleaseMode(ReleaseMode.stop);

        // Возвращаем плеер в пул после завершения воспроизведения
        player.onPlayerComplete.listen((_) {
          _returnPlayer(player);
        });

        _playerPool.add(player);
        _availablePlayers.add(player);
      }

      _isInitialized = true;
      debugPrint('SfxPlayer: initialized with $maxPlayers players');
    } catch (e) {
      debugPrint('SfxPlayer: initialization failed - $e');
    }
  }

  /// Освобождает ресурсы
  Future<void> dispose() async {
    if (!_isInitialized) return;

    try {
      for (final player in _playerPool) {
        await player.dispose();
      }
      _playerPool.clear();
      _availablePlayers.clear();
      _isInitialized = false;
      debugPrint('SfxPlayer: disposed');
    } catch (e) {
      debugPrint('SfxPlayer: dispose failed - $e');
    }
  }

  /// Воспроизводит звуковой эффект
  Future<void> play(String assetPath, {double volume = 1.0}) async {
    if (!_isInitialized) {
      debugPrint('SfxPlayer: not initialized');
      return;
    }

    final player = _getAvailablePlayer();
    if (player == null) {
      debugPrint('SfxPlayer: no available players for $assetPath');
      return;
    }

    try {
      await player.setVolume(volume.clamp(0.0, 1.0));
      await player.setSource(AssetSource(assetPath));
      await player.resume();
      debugPrint('SfxPlayer: playing $assetPath');
    } catch (e) {
      debugPrint('SfxPlayer: play failed - $e');
      _returnPlayer(player);
    }
  }

  /// Воспроизводит звуковой эффект с высотой тона
  Future<void> playWithPitch(
    String assetPath, {
    double volume = 1.0,
    double pitch = 1.0,
  }) async {
    if (!_isInitialized) {
      debugPrint('SfxPlayer: not initialized');
      return;
    }

    final player = _getAvailablePlayer();
    if (player == null) {
      debugPrint('SfxPlayer: no available players for $assetPath');
      return;
    }

    try {
      await player.setVolume(volume.clamp(0.0, 1.0));
      await player.setPlaybackRate(pitch.clamp(0.5, 2.0));
      await player.setSource(AssetSource(assetPath));
      await player.resume();
      debugPrint('SfxPlayer: playing $assetPath with pitch $pitch');
    } catch (e) {
      debugPrint('SfxPlayer: playWithPitch failed - $e');
      _returnPlayer(player);
    }
  }

  /// Останавливает все звуковые эффекты
  Future<void> stopAll() async {
    if (!_isInitialized) return;

    for (final player in _playerPool) {
      try {
        await player.stop();
      } catch (e) {
        debugPrint('SfxPlayer: stop failed - $e');
      }
    }

    _availablePlayers.clear();
    _availablePlayers.addAll(_playerPool);
    debugPrint('SfxPlayer: all sounds stopped');
  }

  /// Получает доступный плеер из пула
  AudioPlayer? _getAvailablePlayer() {
    if (_availablePlayers.isEmpty) {
      // Если все плееры заняты, освобождаем самый старый
      debugPrint('SfxPlayer: pool exhausted, recycling oldest player');
      return _forceRecycleOldest();
    }
    return _availablePlayers.removeFirst();
  }

  /// Принудительно освобождает самый старый занятый плеер
  AudioPlayer? _forceRecycleOldest() {
    for (final player in _playerPool) {
      if (player.state == PlayerState.playing) {
        try {
          player.stop();
          return player;
        } catch (e) {
          debugPrint('SfxPlayer: force recycle failed - $e');
        }
      }
    }
    return null;
  }

  /// Возвращает плеер в пул
  void _returnPlayer(AudioPlayer player) {
    if (!_availablePlayers.contains(player)) {
      _availablePlayers.add(player);
    }
  }

  /// Возвращает количество доступных плееров
  int get availablePlayersCount => _availablePlayers.length;

  /// Возвращает количество занятых плееров
  int get busyPlayersCount => maxPlayers - _availablePlayers.length;
}

/// Расширение для удобного воспроизведения звуков
extension SfxPlayerExtension on SfxPlayer {
  /// Воспроизводит звук правильного ответа
  Future<void> playCorrect({double volume = 1.0}) =>
      play(AudioAssets.sfxCorrect, volume: volume);

  /// Воспроизводит звук неправильного ответа
  Future<void> playWrong({double volume = 1.0}) =>
      play(AudioAssets.sfxWrong, volume: volume);

  /// Воспроизводит звук комбо
  Future<void> playCombo({double volume = 1.0, int comboLevel = 1}) {
    // Повышаем высоту тона с увеличением комбо
    final pitch = 1.0 + (comboLevel - 1) * 0.1;
    return playWithPitch(
      AudioAssets.sfxCombo,
      volume: volume,
      pitch: pitch.clamp(1.0, 1.5),
    );
  }

  /// Воспроизводит звук удара по боссу
  Future<void> playBossHit({double volume = 1.0}) =>
      play(AudioAssets.sfxBossHit, volume: volume);

  /// Воспроизводит звук атаки босса
  Future<void> playBossAttack({double volume = 1.0}) =>
      play(AudioAssets.sfxBossAttack, volume: volume);

  /// Воспроизводит звук победы над боссом
  Future<void> playBossDefeat({double volume = 1.0}) =>
      play(AudioAssets.sfxBossDefeat, volume: volume);

  /// Воспроизводит звук клика кнопки
  Future<void> playButtonClick({double volume = 0.7}) =>
      play(AudioAssets.sfxButtonClick, volume: volume);

  /// Воспроизводит звук получения звезды
  Future<void> playStar({double volume = 1.0, int starNumber = 1}) {
    // Повышаем высоту тона для каждой следующей звезды
    final pitch = 1.0 + (starNumber - 1) * 0.15;
    return playWithPitch(
      AudioAssets.sfxStar,
      volume: volume,
      pitch: pitch.clamp(1.0, 1.5),
    );
  }

  /// Воспроизводит звук обратного отсчёта
  Future<void> playCountdown({double volume = 1.0, int secondsRemaining = 5}) {
    // Повышаем высоту тона с уменьшением времени
    final pitch = 1.0 + (5 - secondsRemaining) * 0.1;
    return playWithPitch(
      AudioAssets.sfxCountdown,
      volume: volume,
      pitch: pitch.clamp(1.0, 1.5),
    );
  }
}

/// Вспомогательный класс для создания последовательности звуков
class SfxSequence {
  final SfxPlayer _player;
  final List<_SfxQueueItem> _queue = [];

  SfxSequence(this._player);

  /// Добавляет звук в последовательность
  SfxSequence add(String assetPath, {double volume = 1.0, Duration delay = Duration.zero}) {
    _queue.add(_SfxQueueItem(assetPath, volume, delay));
    return this;
  }

  /// Добавляет паузу в последовательность
  SfxSequence pause(Duration duration) {
    if (_queue.isNotEmpty) {
      _queue.last = _SfxQueueItem(
        _queue.last.assetPath,
        _queue.last.volume,
        _queue.last.delay + duration,
      );
    }
    return this;
  }

  /// Воспроизводит всю последовательность
  Future<void> play() async {
    for (final item in _queue) {
      if (item.delay > Duration.zero) {
        await Future.delayed(item.delay);
      }
      await _player.play(item.assetPath, volume: item.volume);
    }
    _queue.clear();
  }
}

/// Элемент очереди звуков
class _SfxQueueItem {
  final String assetPath;
  final double volume;
  final Duration delay;

  _SfxQueueItem(this.assetPath, this.volume, this.delay);
}
