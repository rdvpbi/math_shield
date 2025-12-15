/// Центральный файл провайдеров Riverpod
///
/// Содержит все провайдеры приложения:
/// - Контроллеры (StateNotifier)
/// - Репозитории
/// - Use Cases
/// - Сервисы
/// - Источники данных
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ==================== Data Layer ====================
import '../../data/datasources/local_datasource.dart';
import '../../data/repositories_impl/example_repository_impl.dart';
import '../../data/repositories_impl/player_repository_impl.dart';
import '../../data/repositories_impl/world_repository_impl.dart';

// ==================== Domain Layer ====================
import '../../domain/repositories/example_repository.dart';
import '../../domain/repositories/player_repository.dart';
import '../../domain/repositories/world_repository.dart';
import '../../domain/usecases/check_answer_usecase.dart';
import '../../domain/usecases/generate_example_usecase.dart';
import '../../domain/usecases/load_progress_usecase.dart';
import '../../domain/usecases/save_progress_usecase.dart';
import '../../domain/usecases/unlock_world_usecase.dart';

// ==================== Application Layer ====================
import '../services/combo_service.dart';
import '../services/difficulty_service.dart';
import '../services/example_generator_service.dart';
import '../services/progress_service.dart';
import '../services/reward_service.dart';

// ==================== Controllers ====================
// Контроллеры определяют свои провайдеры в своих файлах.
// Импортируйте их напрямую:
// - audioControllerProvider из '../controllers/audio_controller.dart'
// - bossControllerProvider из '../controllers/boss_controller.dart'
// - gameControllerProvider из '../controllers/game_controller.dart'
// - mathControllerProvider из '../controllers/math_controller.dart'
// - worldControllerProvider из '../controllers/world_controller.dart'

// ============================================================================
// CORE PROVIDERS
// ============================================================================

/// Provider для SharedPreferences
///
/// Должен быть переопределён в main.dart после инициализации.
/// ```dart
/// final prefs = await SharedPreferences.getInstance();
/// runApp(
///   ProviderScope(
///     overrides: [
///       sharedPreferencesProvider.overrideWithValue(prefs),
///     ],
///     child: MyApp(),
///   ),
/// );
/// ```
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main.dart',
  );
});

// ============================================================================
// DATA SOURCE PROVIDERS
// ============================================================================

/// Provider для LocalDataSource
final localDataSourceProvider = Provider<LocalDataSource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocalDataSourceImpl(prefs);
});

// ============================================================================
// REPOSITORY PROVIDERS
// ============================================================================

/// Provider для PlayerRepository
final playerRepositoryImplProvider = Provider<PlayerRepositoryImpl>((ref) {
  final dataSource = ref.watch(localDataSourceProvider);
  return PlayerRepositoryImpl(dataSource);
});

/// Provider для PlayerRepository (абстракция)
final playerRepoProvider = Provider<PlayerRepository>((ref) {
  return ref.watch(playerRepositoryImplProvider);
});

/// Provider для WorldRepository
final worldRepositoryImplProvider = Provider<WorldRepositoryImpl>((ref) {
  final dataSource = ref.watch(localDataSourceProvider);
  return WorldRepositoryImpl(dataSource);
});

/// Provider для WorldRepository (абстракция)
final worldRepoProvider = Provider<WorldRepository>((ref) {
  return ref.watch(worldRepositoryImplProvider);
});

/// Provider для ExampleRepository
final exampleRepositoryImplProvider = Provider<ExampleRepositoryImpl>((ref) {
  final dataSource = ref.watch(localDataSourceProvider);
  return ExampleRepositoryImpl(dataSource);
});

/// Provider для ExampleRepository (абстракция)
final exampleRepoProvider = Provider<ExampleRepository>((ref) {
  return ref.watch(exampleRepositoryImplProvider);
});

// ============================================================================
// USE CASE PROVIDERS
// ============================================================================

/// Provider для GenerateExampleUseCase
final generateExampleUseCaseProvider = Provider<GenerateExampleUseCase>((ref) {
  final repository = ref.watch(exampleRepoProvider);
  return GenerateExampleUseCase(repository);
});

/// Provider для GenerateExampleBatchUseCase
final generateExampleBatchUseCaseProvider =
    Provider<GenerateExampleBatchUseCase>((ref) {
  final repository = ref.watch(exampleRepoProvider);
  return GenerateExampleBatchUseCase(repository);
});

/// Provider для CheckAnswerUseCase
final checkAnswerUseCaseProvider = Provider<CheckAnswerUseCase>((ref) {
  return const CheckAnswerUseCase();
});

/// Provider для ValidateAnswerUseCase
final validateAnswerUseCaseProvider = Provider<ValidateAnswerUseCase>((ref) {
  return const ValidateAnswerUseCase();
});

/// Provider для LoadProgressUseCase
final loadProgressUseCaseProvider = Provider<LoadProgressUseCase>((ref) {
  final playerRepo = ref.watch(playerRepoProvider);
  final worldRepo = ref.watch(worldRepoProvider);
  return LoadProgressUseCase(
    playerRepository: playerRepo,
    worldRepository: worldRepo,
  );
});

/// Provider для LoadPlayerUseCase
final loadPlayerUseCaseProvider = Provider<LoadPlayerUseCase>((ref) {
  final playerRepo = ref.watch(playerRepoProvider);
  return LoadPlayerUseCase(playerRepo);
});

/// Provider для LoadWorldsUseCase
final loadWorldsUseCaseProvider = Provider<LoadWorldsUseCase>((ref) {
  final worldRepo = ref.watch(worldRepoProvider);
  return LoadWorldsUseCase(worldRepo);
});

/// Provider для SaveProgressUseCase
final saveProgressUseCaseProvider = Provider<SaveProgressUseCase>((ref) {
  final playerRepo = ref.watch(playerRepoProvider);
  final worldRepo = ref.watch(worldRepoProvider);
  return SaveProgressUseCase(
    playerRepository: playerRepo,
    worldRepository: worldRepo,
  );
});

/// Provider для SavePlayerUseCase
final savePlayerUseCaseProvider = Provider<SavePlayerUseCase>((ref) {
  final playerRepo = ref.watch(playerRepoProvider);
  return SavePlayerUseCase(playerRepo);
});

/// Provider для SaveWorldUseCase
final saveWorldUseCaseProvider = Provider<SaveWorldUseCase>((ref) {
  final worldRepo = ref.watch(worldRepoProvider);
  return SaveWorldUseCase(worldRepo);
});

/// Provider для UnlockWorldUseCase
final unlockWorldUseCaseProvider = Provider<UnlockWorldUseCase>((ref) {
  final playerRepo = ref.watch(playerRepoProvider);
  final worldRepo = ref.watch(worldRepoProvider);
  return UnlockWorldUseCase(
    playerRepository: playerRepo,
    worldRepository: worldRepo,
  );
});

/// Provider для UnlockNextWorldUseCase
final unlockNextWorldUseCaseProvider = Provider<UnlockNextWorldUseCase>((ref) {
  final playerRepo = ref.watch(playerRepoProvider);
  final worldRepo = ref.watch(worldRepoProvider);
  return UnlockNextWorldUseCase(
    playerRepository: playerRepo,
    worldRepository: worldRepo,
  );
});

/// Provider для CanUnlockWorldUseCase
final canUnlockWorldUseCaseProvider = Provider<CanUnlockWorldUseCase>((ref) {
  final playerRepo = ref.watch(playerRepoProvider);
  final worldRepo = ref.watch(worldRepoProvider);
  return CanUnlockWorldUseCase(
    playerRepository: playerRepo,
    worldRepository: worldRepo,
  );
});

// ============================================================================
// SERVICE PROVIDERS
// ============================================================================

/// Provider для ExampleGeneratorService
final exampleGeneratorServiceProvider =
    Provider<ExampleGeneratorService>((ref) {
  return ExampleGeneratorService();
});

/// Provider для DifficultyService
///
/// Используется StateProvider, так как сервис имеет изменяемое состояние.
final difficultyServiceProvider = Provider<DifficultyService>((ref) {
  return DifficultyService();
});

/// Provider для ComboService
///
/// Используется StateProvider, так как сервис имеет изменяемое состояние.
final comboServiceProvider = Provider<ComboService>((ref) {
  return ComboService();
});

/// Provider для ProgressService
final progressServiceProvider = Provider<ProgressService>((ref) {
  return ProgressService();
});

/// Provider для RewardService
final rewardServiceProvider = Provider<RewardService>((ref) {
  return RewardService();
});

// ============================================================================
// CONVENIENCE PROVIDERS
// ============================================================================

/// Provider для текущего комбо
final currentComboProvider = Provider<int>((ref) {
  return ref.watch(comboServiceProvider).currentCombo;
});

/// Provider для множителя комбо
final comboMultiplierProvider = Provider<double>((ref) {
  return ref.watch(comboServiceProvider).multiplier;
});

/// Provider для текущей сложности
final currentDifficultyProvider = Provider<int>((ref) {
  return ref.watch(difficultyServiceProvider).currentDifficulty;
});

/// Provider для уровня комбо
final comboLevelProvider = Provider<ComboLevel>((ref) {
  return ref.watch(comboServiceProvider).comboLevel;
});

// ============================================================================
// OVERRIDES HELPER
// ============================================================================

/// Создаёт список переопределений провайдеров для ProviderScope
///
/// Использование:
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   final prefs = await SharedPreferences.getInstance();
///
///   runApp(
///     ProviderScope(
///       overrides: createProviderOverrides(prefs),
///       child: MyApp(),
///     ),
///   );
/// }
/// ```
List<Override> createProviderOverrides(SharedPreferences prefs) {
  return [
    sharedPreferencesProvider.overrideWithValue(prefs),
  ];
}
