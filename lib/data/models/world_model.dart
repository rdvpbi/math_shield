/// Модель мира для сериализации
///
/// Расширяет [WorldEntity] и добавляет JSON-сериализацию.
/// Содержит статические данные о всех 10 мирах.
library;

import '../../domain/entities/world_entity.dart';

/// Модель мира с поддержкой JSON
class WorldModel extends WorldEntity {
  const WorldModel({
    required super.id,
    required super.name,
    required super.multiplier,
    required super.bossName,
    super.isUnlocked,
    super.isCompleted,
    super.bestScore,
    super.bossDefeated,
    super.stars,
  });

  /// Создаёт модель из JSON
  factory WorldModel.fromJson(Map<String, dynamic> json) {
    return WorldModel(
      id: json['id'] as int,
      name: json['name'] as String,
      multiplier: json['multiplier'] as int,
      bossName: json['bossName'] as String,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      isCompleted: json['isCompleted'] as bool? ?? false,
      bestScore: json['bestScore'] as int? ?? 0,
      bossDefeated: json['bossDefeated'] as bool? ?? false,
      stars: json['stars'] as int? ?? 0,
    );
  }

  /// Создаёт модель из Entity
  factory WorldModel.fromEntity(WorldEntity entity) {
    return WorldModel(
      id: entity.id,
      name: entity.name,
      multiplier: entity.multiplier,
      bossName: entity.bossName,
      isUnlocked: entity.isUnlocked,
      isCompleted: entity.isCompleted,
      bestScore: entity.bestScore,
      bossDefeated: entity.bossDefeated,
      stars: entity.stars,
    );
  }

  /// Создаёт модель из статических данных
  factory WorldModel.fromWorldData(int worldId, {bool isUnlocked = false}) {
    final data = worldDataList[worldId];
    return WorldModel(
      id: worldId,
      name: data['name'] as String,
      multiplier: worldId,
      bossName: data['bossName'] as String,
      isUnlocked: isUnlocked,
    );
  }

  /// Конвертирует в JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'multiplier': multiplier,
      'bossName': bossName,
      'isUnlocked': isUnlocked,
      'isCompleted': isCompleted,
      'bestScore': bestScore,
      'bossDefeated': bossDefeated,
      'stars': stars,
    };
  }

  /// Создаёт копию модели с изменёнными полями
  @override
  WorldModel copyWith({
    int? id,
    String? name,
    int? multiplier,
    String? bossName,
    bool? isUnlocked,
    bool? isCompleted,
    int? bestScore,
    bool? bossDefeated,
    int? stars,
  }) {
    return WorldModel(
      id: id ?? this.id,
      name: name ?? this.name,
      multiplier: multiplier ?? this.multiplier,
      bossName: bossName ?? this.bossName,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      isCompleted: isCompleted ?? this.isCompleted,
      bestScore: bestScore ?? this.bestScore,
      bossDefeated: bossDefeated ?? this.bossDefeated,
      stars: stars ?? this.stars,
    );
  }

  /// Статические данные о всех 10 мирах
  static const List<Map<String, String>> worldDataList = [
    // Мир 0: ×0
    {
      'name': 'Лабиринт Нуля',
      'bossName': 'Зероид',
      'description': 'Прозрачный мир, где всё умножается на ноль',
    },
    // Мир 1: ×1
    {
      'name': 'Фабрика Хаоса',
      'bossName': 'Хаос-Бот',
      'description': 'Фабрика, где числа остаются самими собой',
    },
    // Мир 2: ×2
    {
      'name': 'Зеркальная Башня',
      'bossName': 'Дупликатор',
      'description': 'Башня зеркал, где всё удваивается',
    },
    // Мир 3: ×3
    {
      'name': 'Тройной Лес',
      'bossName': 'Трикстер',
      'description': 'Волшебный лес, где всё растёт тройками',
    },
    // Мир 4: ×4
    {
      'name': 'Квадратный Город',
      'bossName': 'Квадроблокс',
      'description': 'Город идеальных квадратов',
    },
    // Мир 5: ×5
    {
      'name': 'Вихревая Фабрика',
      'bossName': 'Спин-Циклон',
      'description': 'Фабрика вращающихся механизмов',
    },
    // Мир 6: ×6
    {
      'name': 'Гекса-Лаборатория',
      'bossName': 'Гекса-Вирус',
      'description': 'Лаборатория с шестиугольными структурами',
    },
    // Мир 7: ×7
    {
      'name': 'Казино Удачи',
      'bossName': 'Лаки-Севен',
      'description': 'Казино, где правит число семь',
    },
    // Мир 8: ×8
    {
      'name': 'Океан Осьминога',
      'bossName': 'Окто-Баг',
      'description': 'Подводный мир восьми щупалец',
    },
    // Мир 9: ×9
    {
      'name': 'Дворец Девяти Зеркал',
      'bossName': 'Найнер-Рор',
      'description': 'Дворец, где отражения играют с числами',
    },
  ];

  /// Получить данные мира по ID
  static Map<String, String> getWorldData(int worldId) {
    if (worldId < 0 || worldId >= worldDataList.length) {
      throw ArgumentError('Invalid worldId: $worldId');
    }
    return worldDataList[worldId];
  }

  /// Создать список всех миров с начальным состоянием
  static List<WorldModel> createAllWorlds() {
    return List.generate(
      worldDataList.length,
      (index) => WorldModel.fromWorldData(
        index,
        isUnlocked: index == 0, // Только первый мир разблокирован
      ),
    );
  }
}
