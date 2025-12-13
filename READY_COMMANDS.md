# 🚀 ГОТОВЫЕ КОМАНДЫ ДЛЯ CLAUDE CODE

> Копируй каждую команду целиком и вставляй в Claude Code на [claude.ai/code](https://claude.ai/code)

---

## ⚙️ НАСТРОЙКА (выполни один раз)

После подключения репозитория, создай первую задачу с этим текстом:

```
Прочитай файлы CLAUDE.md, SPEC.md и TASKS.md в корне репозитория.
Подтверди, что понял:
1. Архитектуру проекта (Clean Architecture + MVVM + Riverpod)
2. Структуру папок
3. Правила написания кода
4. Игровые механики

Кратко опиши план работы.
```

---

## 📋 ЭТАП 1: CORE LAYER

### Задача 1.1
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

### Задача 1.2
```
Создай файл lib/core/errors/failures.dart с классами ошибок:
- Failure (абстрактный базовый класс с полем message)
- ServerFailure
- CacheFailure  
- ValidationFailure

Каждый класс наследует Failure.
```

### Задача 1.3
```
Создай утилиты:

1. lib/core/utils/extensions.dart:
   - IntExtension: isEven, isOdd
   - StringExtension: capitalize, isNumeric
   - ListExtension: randomElement (безопасный random)

2. lib/core/utils/validators.dart:
   - validateAnswer(int answer, int expected): bool
   - validateMultiplier(int multiplier): bool (0-9)
```

---

## 📋 ЭТАП 2: DOMAIN LAYER

### Задача 2.1
```
Прочитай CLAUDE.md секцию "Entities (Domain)".

Создай 4 файла в lib/domain/entities/:

1. player_entity.dart:
   - id, lives, maxLives, score, currentWorld, unlockedWorlds, combo
   - copyWith, factory empty()

2. world_entity.dart:
   - id (0-9), name, multiplier, isUnlocked, isCompleted, bestScore, bossDefeated
   - copyWith

3. boss_entity.dart:
   - id, name, worldId, maxHp, currentHp, phase (enum: idle, attack, hurt, rage, defeat)
   - copyWith, hpPercentage getter

4. example_task_entity.dart:
   - id, multiplicand, multiplier, correctAnswer, userAnswer, isCorrect, timeSpent
   - copyWith

Все классы immutable с const конструкторами!
```

### Задача 2.2
```
Создай абстрактные репозитории в lib/domain/repositories/:

1. player_repository.dart:
   - getPlayer(), savePlayer(), updateScore(), updateLives(), unlockWorld()

2. world_repository.dart:
   - getAllWorlds(), getWorld(), completeWorld(), defeatBoss()

3. example_repository.dart:
   - generateExample(), generateExampleBatch(), saveResult(), getHistory()

Используй Either<Failure, T> из пакета dartz для возврата.
```

### Задача 2.3
```
Создай 5 use cases в lib/domain/usecases/:

1. generate_example_usecase.dart - генерация примера
2. check_answer_usecase.dart - проверка ответа
3. load_progress_usecase.dart - загрузка прогресса
4. save_progress_usecase.dart - сохранение прогресса
5. unlock_world_usecase.dart - разблокировка мира

Каждый UseCase - отдельный класс с методом call().
```

---

## 📋 ЭТАП 3: DATA LAYER

### Задача 3.1
```
Создай модели в lib/data/models/:

1. player_model.dart - extends PlayerEntity, fromJson/toJson
2. world_model.dart - extends WorldEntity, + WORLD_DATA с 10 мирами
3. boss_model.dart - extends BossEntity, + BOSS_DATA с 10 боссами
4. example_task_model.dart - extends ExampleTaskEntity

Все с fromJson, toJson, fromEntity.
```

### Задача 3.2
```
Создай lib/data/datasources/local_datasource.dart:

abstract class LocalDataSource + class LocalDataSourceImpl

Методы:
- getPlayer(), savePlayer()
- getWorlds(), saveWorld()
- clearAll()

Используй SharedPreferences с JSON сериализацией.
```

### Задача 3.3
```
Создай реализации репозиториев в lib/data/repositories_impl/:

1. player_repository_impl.dart
2. world_repository_impl.dart
3. example_repository_impl.dart

Каждый implements соответствующий интерфейс из domain.
Обрабатывай ошибки через try-catch и возвращай Either.
```

---

## 📋 ЭТАП 4: APPLICATION LAYER

### Задача 4.1
```
Создай состояния в lib/application/state/:

1. game_state.dart - player, isLoading, error
2. world_state.dart - worlds, currentWorld, isLoading
3. boss_state.dart - boss, isAttacking, lastDamage
4. math_state.dart - currentTask, tasksCompleted, correctAnswers, combo, timeRemaining

Все с copyWith, initial().
```

### Задача 4.2
```
Создай сервисы в lib/application/services/:

1. example_generator_service.dart - generateForWorld(), generateBatch()
2. difficulty_service.dart - currentDifficulty, increase/decrease
3. combo_service.dart - onCorrectAnswer(), onWrongAnswer(), getMultiplier()
4. progress_service.dart - calculateStars(), shouldUnlockNextWorld()
5. reward_service.dart - calculateScore()
```

### Задача 4.3
```
Создай контроллеры (Riverpod Notifier) в lib/application/controllers/:

1. game_controller.dart - loadGame, saveGame, loseLife, addScore, resetGame
2. world_controller.dart - loadWorlds, selectWorld, completeWorld, unlockNextWorld
3. boss_controller.dart - initBoss, dealDamage, triggerAttack, defeatBoss
4. math_controller.dart - generateTask, submitAnswer, startTimer, onTimeUp
5. audio_controller.dart - playMusic, playSfx, setVolume, stopAll

Каждый extends Notifier<State>.
```

### Задача 4.4
```
Создай lib/application/providers/providers.dart:

Определи все Riverpod providers:
- Для всех контроллеров (NotifierProvider)
- Для repositories
- Для usecases
- Для services
- Для LocalDataSource
```

---

## 📋 ЭТАП 5: THEME

### Задача 5.1
```
Создай lib/presentation/theme/:

1. app_colors.dart:
   - Все цвета из CLAUDE.md
   - 10 уникальных палитр для миров

2. app_theme.dart:
   - ThemeData Material 3
   - Большие шрифты
   - Кнопки 64x64
```

---

## 📋 ЭТАП 6: WIDGETS

### Задача 6.1
```
Создай виджеты в lib/presentation/widgets/:

1. health_bar.dart - HP с анимацией, цвет по уровню
2. answer_pad.dart - цифровая клавиатура 0-9, кнопки 64x64
3. math_hud.dart - пример, комбо, таймер, счёт
4. boss_widget.dart - спрайт босса + анимации фаз
5. world_button.dart - кнопка мира (locked/unlocked/completed)
6. filin_helper.dart - виджет помощника-совы
```

### Задача 6.2
```
Создай диалоги в lib/presentation/dialogs/:

1. filin_dialog.dart - диалог с ментором
2. victory_popup.dart - победа, звёзды, статистика
3. defeat_popup.dart - поражение, поддержка
4. pause_popup.dart - меню паузы
5. sleshsh_dialog.dart - диалог с антагонистом
```

---

## 📋 ЭТАП 7: SCREENS

### Задача 7.1
```
Создай экраны в lib/presentation/screens/:

1. splash_screen.dart - логотип, загрузка, автопереход
2. hub_screen.dart - хаб с 10 мирами, Филин, настройки
3. world_screen.dart - игровой экран уровня
4. boss_screen.dart - битва с боссом
5. settings_screen.dart - громкость, сброс, о приложении
```

---

## 📋 ЭТАП 8: NAVIGATION

### Задача 8.1
```
Создай lib/navigation/app_router.dart:

GoRouter со всеми маршрутами:
- / → SplashScreen
- /hub → HubScreen
- /world/:id → WorldScreen
- /boss/:worldId → BossScreen
- /settings → SettingsScreen

Добавь анимации переходов.
```

---

## 📋 ЭТАП 9: AUDIO

### Задача 9.1
```
Создай lib/audio/:

1. audio_manager.dart - singleton, playBgm, stopBgm, playSfx, предзагрузка
2. sfx_player.dart - пути к звукам, методы playCorrect, playWrong, playCombo и т.д.
```

---

## 📋 ЭТАП 10: ФИНАЛИЗАЦИЯ

### Задача 10.1
```
Обнови lib/main.dart:
- ProviderScope
- Инициализация SharedPreferences
- AudioManager
- Ориентация landscape
- Полноэкранный режим
- Подключи AppRouter и AppTheme
```

### Задача 10.2
```
Проверь весь проект:
1. Clean Architecture соблюдена?
2. Нет бизнес-логики в виджетах?
3. Все состояния immutable?
4. Нет циклических зависимостей?
5. Все файлы на местах?

Исправь все несоответствия.
```

### Задача 10.3
```
Запусти flutter analyze.
Исправь все warnings и errors.
```

### Задача 10.4
```
Создай базовые тесты в test/:

1. test/unit/domain/generate_example_usecase_test.dart
2. test/unit/application/combo_service_test.dart
3. test/widget/answer_pad_test.dart
```

---

## 📋 ЭТАП 11: BUILD

### Задача 11.1
```
Подготовь проект к сборке:
1. Проверь pubspec.yaml
2. Настрой android/app/build.gradle
3. Проверь minSdkVersion: 23, targetSdkVersion: 34
```

### Задача 11.2
```
Выполни сборку:
flutter clean
flutter pub get
flutter build apk --release

Проверь, что APK собирается без ошибок.
```

---

## ✅ ГОТОВО!

После выполнения всех задач у тебя будет полностью работающий проект Math Shield! 🎮🛡️
