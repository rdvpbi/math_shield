/// Модель босса для сериализации
///
/// Расширяет [BossEntity] и добавляет JSON-сериализацию.
/// Содержит статические данные о всех 10 боссах.
library;

import '../../core/config/game_constants.dart';
import '../../domain/entities/boss_entity.dart';

/// Модель босса с поддержкой JSON
class BossModel extends BossEntity {
  const BossModel({
    required super.id,
    required super.name,
    required super.worldId,
    required super.maxHp,
    required super.currentHp,
    super.phase,
    super.description,
  });

  /// Создаёт модель из JSON
  factory BossModel.fromJson(Map<String, dynamic> json) {
    return BossModel(
      id: json['id'] as int,
      name: json['name'] as String,
      worldId: json['worldId'] as int,
      maxHp: json['maxHp'] as int,
      currentHp: json['currentHp'] as int,
      phase: BossPhase.values.firstWhere(
        (e) => e.name == json['phase'],
        orElse: () => BossPhase.idle,
      ),
      description: json['description'] as String? ?? '',
    );
  }

  /// Создаёт модель из Entity
  factory BossModel.fromEntity(BossEntity entity) {
    return BossModel(
      id: entity.id,
      name: entity.name,
      worldId: entity.worldId,
      maxHp: entity.maxHp,
      currentHp: entity.currentHp,
      phase: entity.phase,
      description: entity.description,
    );
  }

  /// Создаёт модель из статических данных
  factory BossModel.fromBossData(int worldId) {
    final data = bossDataList[worldId];
    final hp = BossConstants.calculateBossHp(worldId);
    return BossModel(
      id: worldId,
      name: data['name'] as String,
      worldId: worldId,
      maxHp: hp,
      currentHp: hp,
      description: data['description'] as String,
    );
  }

  /// Конвертирует в JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'worldId': worldId,
      'maxHp': maxHp,
      'currentHp': currentHp,
      'phase': phase.name,
      'description': description,
    };
  }

  /// Создаёт копию модели с изменёнными полями
  @override
  BossModel copyWith({
    int? id,
    String? name,
    int? worldId,
    int? maxHp,
    int? currentHp,
    BossPhase? phase,
    String? description,
  }) {
    return BossModel(
      id: id ?? this.id,
      name: name ?? this.name,
      worldId: worldId ?? this.worldId,
      maxHp: maxHp ?? this.maxHp,
      currentHp: currentHp ?? this.currentHp,
      phase: phase ?? this.phase,
      description: description ?? this.description,
    );
  }

  /// Статические данные о всех 10 боссах
  static const List<Map<String, String>> bossDataList = [
    // Босс 0: Зероид (×0)
    {
      'name': 'Зероид',
      'description': 'Прозрачный страж нуля. Робкий и неуверенный, '
          'считает себя бесполезным, ведь всё умноженное на него исчезает.',
      'taunt': 'Я... я ничего не значу... но и ты станешь нулём!',
      'defeat': 'Может, ноль — это тоже важно?',
    },
    // Босс 1: Хаос-Бот (×1)
    {
      'name': 'Хаос-Бот',
      'description': 'Сломанный робот из несовместимых деталей. '
          'Всё усложняет, хотя умножение на 1 — самое простое.',
      'taunt': 'Я УЛУЧШУ твои вычисления! *искры*',
      'defeat': 'Оказывается, простота — это тоже сила...',
    },
    // Босс 2: Дупликатор (×2)
    {
      'name': 'Дупликатор',
      'description': 'Два разума в одном костюме. Левый — логичный, '
          'правый — эмоциональный. Постоянно спорят друг с другом.',
      'taunt': 'Мы удвоим твои проблемы! — Нет, утроим! — Это не наша таблица!',
      'defeat': 'Наконец-то мы согласны... мы проиграли.',
    },
    // Босс 3: Трикстер (×3)
    {
      'name': 'Трикстер',
      'description': 'Трёхголовый дракончик-шутник. Каждая голова '
          'говорит своё, создавая путаницу и хаос.',
      'taunt': 'Три загадки! — Три подвоха! — Три... я забыл.',
      'defeat': 'Втроём проиграть — втройне обидно!',
    },
    // Босс 4: Квадроблокс (×4)
    {
      'name': 'Квадроблокс',
      'description': 'Гигантский квадратный робот. Добрый, но постоянно '
          'застревает в дверных проёмах из-за своей формы.',
      'taunt': 'Извини, что загораживаю... но я должен тебя остановить!',
      'defeat': 'Может, мне стоит скруглить углы...',
    },
    // Босс 5: Спин-Циклон (×5)
    {
      'name': 'Спин-Циклон',
      'description': 'Вращающийся цилиндр с пятью руками. Не может '
          'остановиться и постоянно кружится до головокружения.',
      'taunt': 'Пять оборотов! Десять! Пятнадцать! Кружииится...',
      'defeat': 'Наконец-то... могу... остановиться... *падает*',
    },
    // Босс 6: Гекса-Вирус (×6)
    {
      'name': 'Гекса-Вирус',
      'description': 'Шестиногий паукобот. Очень тревожный и пугливый, '
          'постоянно путается в собственных ногах.',
      'taunt': 'Ой-ой-ой! Не подходи! *запутывается*',
      'defeat': 'Может, четырёх ног было бы достаточно...',
    },
    // Босс 7: Лаки-Севен (×7)
    {
      'name': 'Лаки-Севен',
      'description': 'Кролик-робот в стиле казино. Считает себя везунчиком, '
          'но удача всегда отворачивается в последний момент.',
      'taunt': 'Семёрка — счастливое число! Сейчас мне повезёт!.. правда?',
      'defeat': 'Казино всегда проигрывает... подожди, это не так работает!',
    },
    // Босс 8: Окто-Баг (×8)
    {
      'name': 'Окто-Баг',
      'description': 'Осьминог-робот с восемью контроллерами. Пытается '
          'делать восемь дел одновременно, но ни одно не получается.',
      'taunt': 'Восемь рук! Восемь задач! Восемь... ой, всё перепуталось!',
      'defeat': 'Может, стоило сфокусироваться на чём-то одном...',
    },
    // Босс 9: Найнер-Рор (×9)
    {
      'name': 'Найнер-Рор',
      'description': 'Лис с девятью хвостами и зеркальными очками. '
          'Стильный и уверенный, но путает 6 и 9.',
      'taunt': 'Девятка — вершина элегантности! Или это шестёрка? Неважно!',
      'defeat': 'Кажется, мне нужны новые очки...',
    },
  ];

  /// Получить данные босса по ID мира
  static Map<String, String> getBossData(int worldId) {
    if (worldId < 0 || worldId >= bossDataList.length) {
      throw ArgumentError('Invalid worldId: $worldId');
    }
    return bossDataList[worldId];
  }

  /// Создать босса для указанного мира
  static BossModel createForWorld(int worldId) {
    return BossModel.fromBossData(worldId);
  }

  /// Получить фразу насмешки босса
  String get tauntPhrase {
    final data = bossDataList[worldId];
    return data['taunt'] ?? 'Приготовься к бою!';
  }

  /// Получить фразу поражения босса
  String get defeatPhrase {
    final data = bossDataList[worldId];
    return data['defeat'] ?? 'Ты победил...';
  }
}
