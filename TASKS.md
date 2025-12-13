# MATH SHIELD — Задачи для Claude Code

> Выполняй задачи **СТРОГО ПО ПОРЯДКУ**. Каждая задача зависит от предыдущих.

---

## 📋 ЭТАП 0: Подготовка (уже выполнено)

- [x] Создан pubspec.yaml
- [x] Создана структура папок
- [x] Созданы CLAUDE.md и SPEC.md

---

## 📋 ЭТАП 1: Core Layer

### Задача 1.1 — Константы игры
```
Прочитай CLAUDE.md и SPEC.md.

Создай файл lib/core/config/game_constants.dart со всеми константами игры:
- Количество миров (10)
- Жизни игрока (3)
- Время на ответ (15 сек)
- Очки за правильный ответ (100)
- Настройки комбо (множитель 0.5, максимум 5.0)
- HP боссов по мирам (100 + worldIndex * 100)
- Размеры UI элементов для детей (минимум 48dp, кнопки 64dp)
- Длительности анимаций

Следуй стилю кода из CLAUDE.md.
```

### Задача 1.2 — Классы ошибок
```
Создай файл lib/core/errors/failures.dart с классами ошибок:
- Failure (абстрактный базовый класс)
- ServerFailure
- CacheFailure
- ValidationFailure

Каждый класс должен иметь поле message.
```

### Задача 1.3 — Утилиты
```
Создай файл lib/core/utils/extensions.dart с полезными расширениями:
- IntExtension: isEven, isOdd, toRoman
- StringExtension: capitalize, isNumeric
- ListExtension: random (безопасный random элемент)

Добавь файл lib/core/utils/validators.dart:
- validateAnswer(int answer, int expected): bool
- validateMultiplier(int multiplier): bool (0-9)
```

---

## 📋 ЭТАП 2: Domain Layer

### Задача 2.1 — Entities
```
Прочитай CLAUDE.md секцию "Entities (Domain)".

Создай файлы в lib/domain/entities/:

1. player_entity.dart:
   - id: String
   - lives: int (текущие жизни)
   - maxLives: int
   - score: int
   - currentWorld: int (0-9)
   - unlockedWorlds: List<int>
   - combo: int
   - Метод: copyWith, factory empty()

2. world_entity.dart:
   - id: int (0-9)
   - name: String
   - multiplier: int (совпадает с id)
   - isUnlocked: bool
   - isCompleted: bool
   - bestScore: int
   - bossDefeated: bool
   - Метод: copyWith

3. boss_entity.dart:
   - id: int
   - name: String
   - worldId: int
   - maxHp: int
   - currentHp: int
   - phase: BossPhase (enum: idle, attack, hurt, rage, defeat)
   - Метод: copyWith, hpPercentage getter

4. example_task_entity.dart:
   - id: String
   - multiplicand: int (первое число)
   - multiplier: int (второе число, это номер мира)
   - correctAnswer: int
   - userAnswer: int? (null если не отвечено)
   - isCorrect: bool? (null если не проверено)
   - timeSpent: Duration?
   - Метод: copyWith

Все классы должны быть immutable с const конструкторами.
```

### Задача 2.2 — Repository Interfaces
```
Создай абстрактные репозитории в lib/domain/repositories/:

1. player_repository.dart:
   - Future<PlayerEntity> getPlayer()
   - Future<void> savePlayer(PlayerEntity player)
   - Future<void> updateScore(int score)
   - Future<void> updateLives(int lives)
   - Future<void> unlockWorld(int worldId)

2. world_repository.dart:
   - Future<List<WorldEntity>> getAllWorlds()
   - Future<WorldEntity> getWorld(int id)
   - Future<void> completeWorld(int worldId, int score)
   - Future<void> defeatBoss(int worldId)

3. example_repository.dart:
   - Future<ExampleTaskEntity> generateExample(int multiplier, int difficulty)
   - Future<List<ExampleTaskEntity>> generateExampleBatch(int multiplier, int count)
   - Future<void> saveResult(ExampleTaskEntity task)
   - Future<List<ExampleTaskEntity>> getHistory(int worldId)

Используй Either<Failure, T> для возврата результатов (импортируй из dartz или создай свой).
```

### Задача 2.3 — Use Cases
```
Создай use cases в lib/domain/usecases/:

1. generate_example_usecase.dart:
   - Генерирует пример для указанного множителя
   - Учитывает сложность (влияет на диапазон первого числа)
   - Возвращает ExampleTaskEntity

2. check_answer_usecase.dart:
   - Принимает ExampleTaskEntity и ответ пользователя
   - Возвращает обновлённый ExampleTaskEntity с isCorrect

3. load_progress_usecase.dart:
   - Загружает PlayerEntity из репозитория
   - Возвращает Either<Failure, PlayerEntity>

4. save_progress_usecase.dart:
   - Сохраняет PlayerEntity
   - Возвращает Either<Failure, void>

5. unlock_world_usecase.dart:
   - Проверяет условия разблокировки
   - Разблокирует следующий мир
   - Возвращает Either<Failure, WorldEntity>

Каждый UseCase — отдельный класс с методом call() или execute().
```

---

## 📋 ЭТАП 3: Data Layer

### Задача 3.1 — Models
```
Создай модели в lib/data/models/:

1. player_model.dart:
   - Extends PlayerEntity
   - fromJson, toJson
   - fromEntity factory

2. world_model.dart:
   - Extends WorldEntity
   - fromJson, toJson
   - fromEntity factory
   - Статический список WORLD_DATA с названиями и боссами всех 10 миров

3. boss_model.dart:
   - Extends BossEntity
   - fromJson, toJson
   - fromEntity factory
   - Статический список BOSS_DATA с данными всех 10 боссов

4. example_task_model.dart:
   - Extends ExampleTaskEntity
   - fromJson, toJson
   - fromEntity factory

Используй json_annotation для генерации, или напиши вручную.
```

### Задача 3.2 — DataSource
```
Создай lib/data/datasources/local_datasource.dart:

abstract class LocalDataSource {
  Future<PlayerModel?> getPlayer();
  Future<void> savePlayer(PlayerModel player);
  Future<List<WorldModel>> getWorlds();
  Future<void> saveWorld(WorldModel world);
  Future<void> clearAll();
}

class LocalDataSourceImpl implements LocalDataSource {
  final SharedPreferences prefs;
  
  // Ключи для SharedPreferences
  static const String playerKey = 'player_data';
  static const String worldsKey = 'worlds_data';
  
  // Реализуй все методы с JSON сериализацией
}
```

### Задача 3.3 — Repository Implementations
```
Создай реализации в lib/data/repositories_impl/:

1. player_repository_impl.dart:
   - Implements PlayerRepository
   - Использует LocalDataSource
   - Обрабатывает ошибки и возвращает Either

2. world_repository_impl.dart:
   - Implements WorldRepository
   - Инициализирует миры из WORLD_DATA при первом запуске
   - Сохраняет прогресс

3. example_repository_impl.dart:
   - Implements ExampleRepository
   - Генерирует примеры локально (без сервера)
   - Использует Random для генерации
```

---

## 📋 ЭТАП 4: Application Layer

### Задача 4.1 — States
```
Создай состояния в lib/application/state/:

1. game_state.dart:
   - player: PlayerEntity
   - isLoading: bool
   - error: String?
   - Методы: copyWith, initial(), loading()

2. world_state.dart:
   - worlds: List<WorldEntity>
   - currentWorld: WorldEntity?
   - isLoading: bool
   - Методы: copyWith, initial()

3. boss_state.dart:
   - boss: BossEntity?
   - isAttacking: bool
   - lastDamage: int
   - Методы: copyWith, initial()

4. math_state.dart:
   - currentTask: ExampleTaskEntity?
   - tasksCompleted: int
   - correctAnswers: int
   - combo: int
   - timeRemaining: int
   - Методы: copyWith, initial()

Все состояния immutable!
```

### Задача 4.2 — Services
```
Создай сервисы в lib/application/services/:

1. example_generator_service.dart:
   - generateForWorld(int worldId, int difficulty): ExampleTaskEntity
   - generateBatch(int worldId, int count): List<ExampleTaskEntity>
   - Алгоритм: multiplicand = random(0, 10), multiplier = worldId

2. difficulty_service.dart:
   - currentDifficulty: int (1-5)
   - increaseDifficulty(): void
   - decreaseDifficulty(): void
   - Логика: +1 после 5 правильных, -1 после 3 ошибок подряд

3. combo_service.dart:
   - currentCombo: int
   - maxCombo: int
   - onCorrectAnswer(): double (возвращает множитель урона)
   - onWrongAnswer(): void (сбрасывает комбо)
   - getMultiplier(): double (1 + combo * 0.5, max 5.0)

4. progress_service.dart:
   - calculateStars(int score, int maxScore): int (1-3 звезды)
   - shouldUnlockNextWorld(WorldEntity current): bool
   - getCompletionPercentage(): double

5. reward_service.dart:
   - calculateScore(int correct, int combo, int time): int
   - getRewardForWorld(int worldId): RewardData
```

### Задача 4.3 — Controllers
```
Создай контроллеры в lib/application/controllers/:

1. game_controller.dart (Riverpod Notifier):
   - state: GameState
   - loadGame(): Future<void>
   - saveGame(): Future<void>
   - loseLife(): void
   - addScore(int points): void
   - resetGame(): void

2. world_controller.dart:
   - state: WorldState
   - loadWorlds(): Future<void>
   - selectWorld(int id): void
   - completeWorld(int score): Future<void>
   - unlockNextWorld(): Future<void>

3. boss_controller.dart:
   - state: BossState
   - initBoss(int worldId): void
   - dealDamage(int damage): void
   - triggerAttack(): void
   - checkPhaseTransition(): void (IDLE→RAGE при HP<30%)
   - defeatBoss(): void

4. math_controller.dart:
   - state: MathState
   - generateTask(): void
   - submitAnswer(int answer): AnswerResult
   - startTimer(): void
   - pauseTimer(): void
   - onTimeUp(): void

5. audio_controller.dart:
   - playMusic(String track): void
   - playSfx(String sound): void
   - setMusicVolume(double volume): void
   - setSfxVolume(double volume): void
   - stopAll(): void

Каждый контроллер использует extends Notifier<State>.
```

### Задача 4.4 — Providers
```
Создай lib/application/providers/providers.dart:

Определи все Riverpod providers:
- gameControllerProvider
- worldControllerProvider
- bossControllerProvider
- mathControllerProvider
- audioControllerProvider

А также providers для:
- Repositories
- UseCases
- Services
- LocalDataSource

Используй riverpod_annotation или стандартный синтаксис.
```

---

## 📋 ЭТАП 5: Presentation Layer — Theme

### Задача 5.1 — Тема и цвета
```
Создай lib/presentation/theme/:

1. app_colors.dart:
   - Все цвета из CLAUDE.md
   - Цвета для каждого мира (10 уникальных палитр)

2. app_theme.dart:
   - ThemeData для Material 3
   - Большие шрифты для детей
   - Кнопки минимум 64x64
   - Настройки для тёмной темы
```

---

## 📋 ЭТАП 6: Presentation Layer — Widgets

### Задача 6.1 — Базовые виджеты
```
Создай lib/presentation/widgets/:

1. health_bar.dart:
   - Отображает HP (игрока или босса)
   - Анимация при изменении
   - Цвет меняется: зелёный→жёлтый→красный

2. answer_pad.dart:
   - Цифровая клавиатура 0-9
   - Кнопки 64x64 минимум
   - Кнопка очистки и подтверждения
   - Callback onAnswer(int)

3. math_hud.dart:
   - Отображает текущий пример (большим шрифтом!)
   - Счётчик комбо
   - Таймер
   - Текущий счёт

4. boss_widget.dart:
   - Отображает спрайт босса
   - Анимация по фазам (idle, attack, hurt, rage, defeat)
   - HealthBar босса

5. world_button.dart:
   - Кнопка выбора мира на хабе
   - Состояния: locked, unlocked, completed
   - Отображает номер множителя и название

6. filin_helper.dart:
   - Виджет помощника-совы
   - Показывает подсказки
   - Анимация появления
```

### Задача 6.2 — Диалоги
```
Создай lib/presentation/dialogs/:

1. filin_dialog.dart:
   - Диалог с ментором Филином
   - Портрет + текст
   - Кнопка "Понятно"

2. victory_popup.dart:
   - Popup победы
   - Звёзды (1-3)
   - Счёт и статистика
   - Кнопки: "Дальше", "Повторить", "В хаб"

3. defeat_popup.dart:
   - Popup поражения
   - Сообщение поддержки
   - Кнопки: "Повторить", "В хаб"

4. pause_popup.dart:
   - Меню паузы
   - Кнопки: "Продолжить", "Настройки", "Выйти"

5. sleshsh_dialog.dart:
   - Диалог с антагонистом
   - Угрожающий стиль
```

---

## 📋 ЭТАП 7: Presentation Layer — Screens

### Задача 7.1 — Splash и Hub
```
Создай/обнови lib/presentation/screens/:

1. splash_screen.dart:
   - Логотип игры
   - Анимация загрузки
   - Предзагрузка ассетов
   - Автопереход на hub через 2-3 сек

2. hub_screen.dart:
   - Центральный хаб "Математический Проспект"
   - Сетка из 10 миров (кнопки WorldButton)
   - Персонаж Филин с приветствием
   - Кнопка настроек
   - Отображение общего прогресса
```

### Задача 7.2 — Игровые экраны
```
1. world_screen.dart:
   - Универсальный экран уровня
   - Принимает worldId как параметр
   - MathHUD сверху
   - AnswerPad снизу
   - Фон мира
   - Логика: ответил правильно → следующий пример

2. boss_screen.dart:
   - Экран битвы с боссом
   - BossWidget в центре
   - MathHUD и AnswerPad
   - Фазы боя
   - Победа → VictoryPopup
   - Поражение → DefeatPopup

3. settings_screen.dart:
   - Громкость музыки
   - Громкость звуков
   - Сброс прогресса (с подтверждением)
   - О приложении
```

---

## 📋 ЭТАП 8: Navigation

### Задача 8.1 — Роутинг
```
Обнови lib/navigation/app_router.dart:

Настрой GoRouter со всеми маршрутами:
- / → SplashScreen
- /hub → HubScreen
- /world/:id → WorldScreen
- /boss/:worldId → BossScreen
- /settings → SettingsScreen

Добавь переходы с анимациями.
Используй redirect для защиты маршрутов.
```

---

## 📋 ЭТАП 9: Audio

### Задача 9.1 — Аудио система
```
Создай lib/audio/:

1. audio_manager.dart:
   - Singleton для управления аудио
   - Методы: playBgm, stopBgm, playSfx
   - Предзагрузка звуков
   - Управление громкостью

2. sfx_player.dart:
   - Константы путей к звукам
   - Методы для конкретных звуков:
     - playCorrect()
     - playWrong()
     - playCombo()
     - playBossHit()
     - playVictory()
     - playDefeat()
```

---

## 📋 ЭТАП 10: Финализация

### Задача 10.1 — main.dart
```
Обнови lib/main.dart:
- ProviderScope
- Инициализация SharedPreferences
- Инициализация AudioManager
- Ориентация экрана (landscape)
- Полноэкранный режим
```

### Задача 10.2 — Проверка архитектуры
```
Проверь весь проект на соответствие:
1. Clean Architecture соблюдена
2. Нет бизнес-логики в виджетах
3. Все состояния immutable
4. Нет циклических зависимостей
5. Все файлы на своих местах

Исправь все найденные несоответствия.
```

### Задача 10.3 — flutter analyze
```
Запусти flutter analyze и исправь все warnings и errors:
- Unused imports
- Missing return types
- Deprecated APIs
- Null safety issues
```

### Задача 10.4 — Базовые тесты
```
Создай тесты в test/:

1. test/unit/domain/generate_example_usecase_test.dart
   - Тест генерации примеров для каждого множителя
   - Тест правильности ответов

2. test/unit/application/combo_service_test.dart
   - Тест увеличения комбо
   - Тест сброса комбо
   - Тест множителя урона

3. test/widget/answer_pad_test.dart
   - Тест нажатия кнопок
   - Тест callback
```

---

## 📋 ЭТАП 11: Сборка

### Задача 11.1 — Подготовка к сборке
```
1. Проверь pubspec.yaml на корректность
2. Добавь иконку приложения в assets/logo/
3. Настрой flutter_launcher_icons
4. Проверь android/app/build.gradle:
   - minSdkVersion: 23
   - targetSdkVersion: 34
```

### Задача 11.2 — Build APK
```
Выполни команды:
flutter clean
flutter pub get
flutter build apk --release

Проверь, что APK собирается без ошибок.
```

---

## ✅ Итоговый чеклист

После выполнения всех задач, проект должен содержать:

- [ ] 4 Entity класса
- [ ] 3 Repository интерфейса
- [ ] 5 UseCase классов
- [ ] 4 Model класса
- [ ] 1 LocalDataSource
- [ ] 3 Repository реализации
- [ ] 4 State класса
- [ ] 5 Service классов
- [ ] 5 Controller классов
- [ ] 6+ Widget классов
- [ ] 5 Dialog классов
- [ ] 5 Screen классов
- [ ] GoRouter конфигурация
- [ ] Audio система
- [ ] Базовые тесты
- [ ] Собирающийся APK

---

> 💡 **Совет**: Копируй текст задачи целиком в Claude Code. Он прочитает CLAUDE.md и SPEC.md автоматически.
