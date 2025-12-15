/// Модель игрока для сериализации
///
/// Расширяет [PlayerEntity] и добавляет JSON-сериализацию.
library;

import '../../domain/entities/player_entity.dart';

/// Модель игрока с поддержкой JSON
class PlayerModel extends PlayerEntity {
  const PlayerModel({
    required super.id,
    required super.lives,
    required super.maxLives,
    required super.score,
    required super.currentWorld,
    required super.unlockedWorlds,
    required super.combo,
  });

  /// Создаёт модель из JSON
  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    return PlayerModel(
      id: json['id'] as String? ?? 'player_1',
      lives: json['lives'] as int? ?? 3,
      maxLives: json['maxLives'] as int? ?? 5,
      score: json['score'] as int? ?? 0,
      currentWorld: json['currentWorld'] as int? ?? 0,
      unlockedWorlds: (json['unlockedWorlds'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          const [0],
      combo: json['combo'] as int? ?? 0,
    );
  }

  /// Создаёт модель из Entity
  factory PlayerModel.fromEntity(PlayerEntity entity) {
    return PlayerModel(
      id: entity.id,
      lives: entity.lives,
      maxLives: entity.maxLives,
      score: entity.score,
      currentWorld: entity.currentWorld,
      unlockedWorlds: entity.unlockedWorlds,
      combo: entity.combo,
    );
  }

  /// Создаёт пустую модель с начальными значениями
  factory PlayerModel.empty() {
    return PlayerModel.fromEntity(PlayerEntity.empty());
  }

  /// Конвертирует в JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lives': lives,
      'maxLives': maxLives,
      'score': score,
      'currentWorld': currentWorld,
      'unlockedWorlds': unlockedWorlds,
      'combo': combo,
    };
  }

  /// Создаёт копию модели с изменёнными полями
  @override
  PlayerModel copyWith({
    String? id,
    int? lives,
    int? maxLives,
    int? score,
    int? currentWorld,
    List<int>? unlockedWorlds,
    int? combo,
  }) {
    return PlayerModel(
      id: id ?? this.id,
      lives: lives ?? this.lives,
      maxLives: maxLives ?? this.maxLives,
      score: score ?? this.score,
      currentWorld: currentWorld ?? this.currentWorld,
      unlockedWorlds: unlockedWorlds ?? this.unlockedWorlds,
      combo: combo ?? this.combo,
    );
  }
}
