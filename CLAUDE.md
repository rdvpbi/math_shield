# MATH SHIELD — Мастер-инструкция для Claude Code

> ⚠️ **ВАЖНО**: Перед выполнением ЛЮБОЙ задачи — прочитай этот файл и SPEC.md полностью!

---

## 🎯 О проекте

**Math Shield** — образовательная мобильная игра для детей 5-9 лет.  
Цель: обучение таблице умножения через платформер с боссами.

- **Платформа**: Android (Flutter)
- **Целевая аудитория**: дети 5-9 лет
- **Основная механика**: математические примеры + платформер + битвы с боссами

---

## 📁 Структура проекта (СТРОГО СОБЛЮДАТЬ)

```
lib/
├── core/                          # Ядро приложения
│   ├── config/
│   │   └── game_constants.dart    # Все константы игры
│   ├── errors/
│   │   └── failures.dart          # Классы ошибок
│   └── utils/
│       └── extensions.dart        # Расширения Dart
│
├── domain/                        # DOMAIN LAYER (чистая бизнес-логика)
│   ├── entities/                  # Бизнес-сущности (immutable)
│   │   ├── player_entity.dart
│   │   ├── world_entity.dart
│   │   ├── boss_entity.dart
│   │   └── example_task_entity.dart
│   ├── repositories/              # Абстрактные репозитории (интерфейсы)
│   │   ├── player_repository.dart
│   │   ├── world_repository.dart
│   │   └── example_repository.dart
│   └── usecases/                  # Use Cases (один класс = одно действие)
│       ├── generate_example_usecase.dart
│       ├── check_answer_usecase.dart
│       ├── load_progress_usecase.dart
│       ├── save_progress_usecase.dart
│       └── unlock_world_usecase.dart
│
├── data/                          # DATA LAYER (работа с данными)
│   ├── datasources/
│   │   └── local_datasource.dart  # SharedPreferences
│   ├── models/                    # DTO модели с toJson/fromJson
│   │   ├── player_model.dart
│   │   ├── world_model.dart
│   │   ├── boss_model.dart
│   │   └── example_task_model.dart
│   └── repositories_impl/         # Реализации репозиториев
│       ├── player_repository_impl.dart
│       ├── world_repository_impl.dart
│       └── example_repository_impl.dart
│
├── application/                   # APPLICATION LAYER (бизнес-логика приложения)
│   ├── state/                     # Состояния (immutable с copyWith)
│   │   ├── game_state.dart
│   │   ├── world_state.dart
│   │   ├── boss_state.dart
│   │   └── math_state.dart
│   ├── controllers/               # Контроллеры (управление состоянием)
│   │   ├── game_controller.dart
│   │   ├── world_controller.dart
│   │   ├── boss_controller.dart
│   │   ├── math_controller.dart
│   │   └── audio_controller.dart
│   ├── services/                  # Сервисы (бизнес-логика)
│   │   ├── example_generator_service.dart
│   │   ├── difficulty_service.dart
│   │   ├── combo_service.dart
│   │   ├── progress_service.dart
│   │   └── reward_service.dart
│   └── providers/
│       └── providers.dart         # Все Riverpod providers
│
├── presentation/                  # PRESENTATION LAYER (UI)
│   ├── screens/
│   │   ├── splash_screen.dart
│   │   ├── hub_screen.dart
│   │   ├── world_screen.dart      # Универсальный экран мира
│   │   ├── boss_screen.dart       # Экран битвы с боссом
│   │   └── settings_screen.dart
│   ├── widgets/
│   │   ├── health_bar.dart
│   │   ├── answer_pad.dart        # Клавиатура для ввода ответа
│   │   ├── math_hud.dart          # HUD с примером и комбо
│   │   ├── boss_widget.dart
│   │   ├── world_button.dart
│   │   └── filin_helper.dart      # Виджет помощника Филина
│   ├── dialogs/
│   │   ├── filin_dialog.dart      # Диалог с ментором
│   │   ├── sleshsh_dialog.dart    # Диалог с антагонистом
│   │   ├── victory_popup.dart
│   │   ├── defeat_popup.dart
│   │   └── pause_popup.dart
│   ├── animations/
│   │   └── game_animations.dart
│   └── theme/
│       ├── app_theme.dart
│       └── app_colors.dart
│
├── navigation/
│   └── app_router.dart            # GoRouter конфигурация
│
├── audio/
│   ├── audio_manager.dart
│   └── sfx_player.dart
│
└── main.dart                      # Точка входа
```

---

## 🏗️ Архитектурные правила

### Clean Architecture — СТРОГО!

```
┌─────────────────────────────────────────┐
│           PRESENTATION                   │  ← UI виджеты, экраны
│  (зависит от Application)               │
├─────────────────────────────────────────┤
│           APPLICATION                    │  ← Controllers, Services, State
│  (зависит от Domain)                    │
├─────────────────────────────────────────┤
│           DOMAIN                         │  ← Entities, UseCases, Repository interfaces
│  (не зависит ни от чего)                │
├─────────────────────────────────────────┤
│           DATA                           │  ← Models, DataSources, Repository impl
│  (реализует Domain interfaces)          │
└─────────────────────────────────────────┘
```

### Правила зависимостей:
- ✅ Presentation → Application → Domain ← Data
- ❌ Domain НИКОГДА не импортирует Flutter
- ❌ Бизнес-логика НИКОГДА в виджетах
- ❌ Controllers НИКОГДА не содержат UI код

---

## 📝 Правила написания кода

### Именование
```dart
// Файлы: snake_case
player_entity.dart
game_controller.dart

// Классы: PascalCase
class PlayerEntity {}
class GameController {}

// Переменные и методы: camelCase
final playerHealth = 100;
void updateScore() {}

// Константы: lowerCamelCase или SCREAMING_SNAKE_CASE
const maxLives = 3;
const MAX_COMBO_MULTIPLIER = 5.0;
```

### Entities (Domain)
```dart
// ВСЕГДА immutable, ВСЕГДА с copyWith
class PlayerEntity {
  final String id;
  final int lives;
  final int score;
  final int currentWorld;
  
  const PlayerEntity({
    required this.id,
    required this.lives,
    required this.score,
    required this.currentWorld,
  });
  
  PlayerEntity copyWith({
    String? id,
    int? lives,
    int? score,
    int? currentWorld,
  }) {
    return PlayerEntity(
      id: id ?? this.id,
      lives: lives ?? this.lives,
      score: score ?? this.score,
      currentWorld: currentWorld ?? this.currentWorld,
    );
  }
}
```

### Models (Data)
```dart
// Наследуют Entity, добавляют сериализацию
class PlayerModel extends PlayerEntity {
  const PlayerModel({
    required super.id,
    required super.lives,
    required super.score,
    required super.currentWorld,
  });
  
  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    return PlayerModel(
      id: json['id'] as String,
      lives: json['lives'] as int,
      score: json['score'] as int,
      currentWorld: json['currentWorld'] as int,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lives': lives,
      'score': score,
      'currentWorld': currentWorld,
    };
  }
  
  factory PlayerModel.fromEntity(PlayerEntity entity) {
    return PlayerModel(
      id: entity.id,
      lives: entity.lives,
      score: entity.score,
      currentWorld: entity.currentWorld,
    );
  }
}
```

### State (Application)
```dart
// Immutable состояние с copyWith
class GameState {
  final PlayerEntity player;
  final bool isLoading;
  final String? error;
  
  const GameState({
    required this.player,
    this.isLoading = false,
    this.error,
  });
  
  GameState copyWith({...}) {...}
  
  // Фабричные методы для удобства
  factory GameState.initial() => GameState(
    player: PlayerEntity.empty(),
  );
  
  factory GameState.loading() => GameState(
    player: PlayerEntity.empty(),
    isLoading: true,
  );
}
```

### Controllers (Application)
```dart
// Используют Riverpod Notifier
class GameController extends Notifier<GameState> {
  @override
  GameState build() => GameState.initial();
  
  Future<void> loadGame() async {
    state = state.copyWith(isLoading: true);
    
    final result = await ref.read(loadProgressUseCaseProvider).execute();
    
    result.fold(
      (failure) => state = state.copyWith(error: failure.message, isLoading: false),
      (player) => state = state.copyWith(player: player, isLoading: false),
    );
  }
}
```

---

## 🎮 Игровые механики (краткая справка)

### Миры (таблица умножения)
| Мир | Множитель | Название | Босс |
|-----|-----------|----------|------|
| 0 | ×0 | Лабиринт Нуля | Зеронавт |
| 1 | ×1 | Фабрика Хаоса | Хаосмейкер |
| 2 | ×2 | Зеркальная Башня | Двуликий |
| 3 | ×3 | Тройной Лес | Триморф |
| 4 | ×4 | Квадратный Город | Квадрон |
| 5 | ×5 | Вихревая Фабрика | Пентавихрь |
| 6 | ×6 | Семь Чудес | Гексамастер |
| 7 | ×7 | Казино Удачи | Септижокер |
| 8 | ×8 | Океан Осьминога | Октопринц |
| 9 | ×9 | Дворец Девяти Зеркал | Новемзеркал |

### Генерация примеров
```dart
// Пример для мира 3 (×3):
// a × 3 = ? где a ∈ [0, 10]
// Генератор должен быть 100% точным!
```

### Combo система
- Правильный ответ: combo += 1
- Неправильный ответ: combo = 0
- Урон боссу = baseDamage × (1 + combo × 0.5)
- Максимальный множитель: 5.0

### Boss FSM
```
IDLE → (игрок атакует) → HURT → IDLE
IDLE → (HP < 30%) → RAGE
RAGE → (HP <= 0) → DEFEAT
```

---

## 🎨 UI/UX для детей

### Размеры элементов
- Минимальный touch target: **48×48 dp**
- Кнопки ответов: **64×64 dp**
- Отступы между кнопками: **16 dp**

### Цветовая палитра
```dart
// Основные
primaryColor: Color(0xFF6C5CE7)    // Фиолетовый
secondaryColor: Color(0xFF00CEC9)  // Бирюзовый
accentColor: Color(0xFFFDCB6E)     // Золотой

// Фоны
backgroundDark: Color(0xFF1A1A2E)
backgroundLight: Color(0xFF16213E)

// Статусы
successColor: Color(0xFF00B894)    // Зелёный
errorColor: Color(0xFFE74C3C)      // Красный
```

### Правила UI
- ❌ Мелкий текст
- ❌ Сложные жесты
- ❌ Много текста на экране
- ✅ Большие кнопки
- ✅ Яркие иконки
- ✅ Звуковая обратная связь
- ✅ Анимации поощрения

---

## 📦 Зависимости

```yaml
dependencies:
  flutter_riverpod: ^2.4.10
  riverpod_annotation: ^2.3.5
  go_router: ^13.2.0
  shared_preferences: ^2.2.2
  audioplayers: ^5.2.1
  flame: ^1.15.0
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1
  flutter_animate: ^4.5.0
  gap: ^3.0.1

dev_dependencies:
  riverpod_generator: ^2.3.11
  build_runner: ^2.4.8
  freezed: ^2.4.7
  json_serializable: ^6.7.1
  flutter_launcher_icons: ^0.13.1
```

---

## ⚠️ Запрещено

1. ❌ **НЕ** упрощай архитектуру
2. ❌ **НЕ** объединяй файлы (один класс = один файл)
3. ❌ **НЕ** пиши бизнес-логику в виджетах
4. ❌ **НЕ** используй setState (только Riverpod)
5. ❌ **НЕ** делай синхронные операции в build()
6. ❌ **НЕ** игнорируй null-safety
7. ❌ **НЕ** создавай God-объекты

---

## ✅ Чеклист перед коммитом

- [ ] Код соответствует структуре папок
- [ ] Нет бизнес-логики в виджетах
- [ ] Все состояния immutable
- [ ] Используется copyWith
- [ ] Нет неиспользуемых импортов
- [ ] `flutter analyze` без ошибок

---

## 🔗 Связанные файлы

- **SPEC.md** — Полное техническое задание
- **TASKS.md** — Список задач для генерации
- **pubspec.yaml** — Зависимости проекта
