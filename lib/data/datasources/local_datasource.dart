/// Локальный источник данных
///
/// Абстракция над SharedPreferences для хранения данных игры.
library;

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/config/game_constants.dart';
import '../models/player_model.dart';
import '../models/world_model.dart';
import '../models/example_task_model.dart';

/// Абстрактный класс источника данных
abstract class LocalDataSource {
  // ==================== Player ====================

  /// Получает данные игрока
  Future<PlayerModel?> getPlayer();

  /// Сохраняет данные игрока
  Future<bool> savePlayer(PlayerModel player);

  /// Проверяет, есть ли сохранённые данные игрока
  Future<bool> hasPlayer();

  // ==================== Worlds ====================

  /// Получает список всех миров
  Future<List<WorldModel>?> getWorlds();

  /// Сохраняет список миров
  Future<bool> saveWorlds(List<WorldModel> worlds);

  /// Сохраняет один мир (обновляет в списке)
  Future<bool> saveWorld(WorldModel world);

  /// Проверяет, есть ли сохранённые данные миров
  Future<bool> hasWorlds();

  // ==================== History ====================

  /// Получает историю примеров
  Future<List<ExampleTaskModel>> getHistory({int? worldId, int limit = 100});

  /// Сохраняет результат примера в историю
  Future<bool> saveTaskResult(ExampleTaskModel task);

  /// Очищает историю примеров
  Future<bool> clearHistory({int? worldId});

  // ==================== Settings ====================

  /// Получает настройки
  Future<Map<String, dynamic>?> getSettings();

  /// Сохраняет настройки
  Future<bool> saveSettings(Map<String, dynamic> settings);

  // ==================== Utility ====================

  /// Очищает все данные
  Future<bool> clearAll();

  /// Проверяет первый запуск
  Future<bool> isFirstLaunch();

  /// Отмечает, что первый запуск выполнен
  Future<bool> markFirstLaunchDone();
}

/// Реализация локального источника данных через SharedPreferences
class LocalDataSourceImpl implements LocalDataSource {
  final SharedPreferences _prefs;

  LocalDataSourceImpl(this._prefs);

  // ==================== Player ====================

  @override
  Future<PlayerModel?> getPlayer() async {
    final jsonString = _prefs.getString(StorageKeys.playerData);
    if (jsonString == null) return null;

    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return PlayerModel.fromJson(json);
    } catch (e) {
      // Данные повреждены, возвращаем null
      return null;
    }
  }

  @override
  Future<bool> savePlayer(PlayerModel player) async {
    try {
      final jsonString = jsonEncode(player.toJson());
      return _prefs.setString(StorageKeys.playerData, jsonString);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> hasPlayer() async {
    return _prefs.containsKey(StorageKeys.playerData);
  }

  // ==================== Worlds ====================

  @override
  Future<List<WorldModel>?> getWorlds() async {
    final jsonString = _prefs.getString(StorageKeys.worldsData);
    if (jsonString == null) return null;

    try {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => WorldModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Данные повреждены, возвращаем null
      return null;
    }
  }

  @override
  Future<bool> saveWorlds(List<WorldModel> worlds) async {
    try {
      final jsonList = worlds.map((w) => w.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      return _prefs.setString(StorageKeys.worldsData, jsonString);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> saveWorld(WorldModel world) async {
    try {
      // Получаем текущий список миров
      var worlds = await getWorlds();

      if (worlds == null) {
        // Если миров нет, создаём новый список
        worlds = WorldModel.createAllWorlds();
      }

      // Обновляем мир в списке
      final index = worlds.indexWhere((w) => w.id == world.id);
      if (index >= 0) {
        worlds[index] = world;
      } else {
        worlds.add(world);
      }

      // Сохраняем обновлённый список
      return saveWorlds(worlds);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> hasWorlds() async {
    return _prefs.containsKey(StorageKeys.worldsData);
  }

  // ==================== History ====================

  static const String _historyKeyPrefix = 'math_shield_history';

  String _getHistoryKey(int? worldId) {
    if (worldId != null) {
      return '${_historyKeyPrefix}_world_$worldId';
    }
    return '${_historyKeyPrefix}_all';
  }

  @override
  Future<List<ExampleTaskModel>> getHistory({
    int? worldId,
    int limit = 100,
  }) async {
    try {
      final key = _getHistoryKey(worldId);
      final jsonString = _prefs.getString(key);

      if (jsonString == null) return [];

      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      final tasks = jsonList
          .map((json) => ExampleTaskModel.fromJson(json as Map<String, dynamic>))
          .toList();

      // Сортируем по дате (новые первые) и ограничиваем
      tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      if (tasks.length > limit) {
        return tasks.sublist(0, limit);
      }

      return tasks;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<bool> saveTaskResult(ExampleTaskModel task) async {
    try {
      // Сохраняем в общую историю
      await _addToHistory(_getHistoryKey(null), task);

      // Сохраняем в историю конкретного мира
      await _addToHistory(_getHistoryKey(task.multiplier), task);

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _addToHistory(String key, ExampleTaskModel task) async {
    final jsonString = _prefs.getString(key);
    List<Map<String, dynamic>> jsonList;

    if (jsonString != null) {
      jsonList = (jsonDecode(jsonString) as List<dynamic>)
          .cast<Map<String, dynamic>>();
    } else {
      jsonList = [];
    }

    // Добавляем новую задачу в начало
    jsonList.insert(0, task.toJson());

    // Ограничиваем размер истории (максимум 500 записей)
    const maxHistorySize = 500;
    if (jsonList.length > maxHistorySize) {
      jsonList = jsonList.sublist(0, maxHistorySize);
    }

    await _prefs.setString(key, jsonEncode(jsonList));
  }

  @override
  Future<bool> clearHistory({int? worldId}) async {
    try {
      if (worldId != null) {
        // Очищаем историю конкретного мира
        await _prefs.remove(_getHistoryKey(worldId));
      } else {
        // Очищаем всю историю
        await _prefs.remove(_getHistoryKey(null));

        // Очищаем историю каждого мира
        for (var i = 0; i < WorldConstants.totalWorlds; i++) {
          await _prefs.remove(_getHistoryKey(i));
        }
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  // ==================== Settings ====================

  @override
  Future<Map<String, dynamic>?> getSettings() async {
    final jsonString = _prefs.getString(StorageKeys.settingsData);
    if (jsonString == null) return null;

    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> saveSettings(Map<String, dynamic> settings) async {
    try {
      final jsonString = jsonEncode(settings);
      return _prefs.setString(StorageKeys.settingsData, jsonString);
    } catch (e) {
      return false;
    }
  }

  // ==================== Utility ====================

  @override
  Future<bool> clearAll() async {
    try {
      // Удаляем все ключи нашего приложения
      await _prefs.remove(StorageKeys.playerData);
      await _prefs.remove(StorageKeys.worldsData);
      await _prefs.remove(StorageKeys.settingsData);
      await _prefs.remove(StorageKeys.statisticsData);
      await _prefs.remove(StorageKeys.firstLaunch);

      // Очищаем историю
      await clearHistory();

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> isFirstLaunch() async {
    return !_prefs.containsKey(StorageKeys.firstLaunch);
  }

  @override
  Future<bool> markFirstLaunchDone() async {
    return _prefs.setBool(StorageKeys.firstLaunch, true);
  }
}
