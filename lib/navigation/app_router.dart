/// Навигация приложения
///
/// Конфигурация GoRouter для навигации между экранами.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../application/controllers/game_controller.dart';
import '../application/controllers/world_controller.dart';
import '../domain/entities/world_entity.dart';
import '../presentation/screens/boss_screen.dart';
import '../presentation/screens/hub_screen.dart';
import '../presentation/screens/settings_screen.dart';
import '../presentation/screens/splash_screen.dart';
import '../presentation/screens/world_screen.dart';

/// Пути маршрутов
abstract class AppRoutes {
  static const splash = '/';
  static const hub = '/hub';
  static const world = '/world/:worldId';
  static const boss = '/boss/:worldId';
  static const settings = '/settings';

  /// Построить путь к миру
  static String worldPath(int worldId) => '/world/$worldId';

  /// Построить путь к боссу
  static String bossPath(int worldId) => '/boss/$worldId';
}

/// Provider для GoRouter
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    routes: [
      // Splash Screen
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: SplashScreen(
            onLoadComplete: () {
              // Инициализируем игру и переходим на хаб
              ref.read(gameControllerProvider.notifier).loadGame();
              ref.read(worldControllerProvider.notifier).loadWorlds();
              context.go(AppRoutes.hub);
            },
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),

      // Hub Screen
      GoRoute(
        path: AppRoutes.hub,
        name: 'hub',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: HubScreen(
            onWorldSelected: (world) {
              context.push(AppRoutes.worldPath(world.id));
            },
            onSettingsPressed: () {
              context.push(AppRoutes.settings);
            },
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),

      // World Screen
      GoRoute(
        path: AppRoutes.world,
        name: 'world',
        pageBuilder: (context, state) {
          final worldId = int.tryParse(state.pathParameters['worldId'] ?? '0') ?? 0;
          final worldState = ref.read(worldControllerProvider);
          final world = worldState.worlds.firstWhere(
            (w) => w.id == worldId,
            orElse: () => WorldEntity.empty(),
          );

          return CustomTransitionPage(
            key: state.pageKey,
            child: WorldScreen(
              world: world,
              onComplete: () {
                // Сохраняем прогресс
                ref.read(gameControllerProvider.notifier).saveGame();
                context.pop();
              },
              onExit: () {
                context.pop();
              },
              onBossBattle: () {
                context.pushReplacement(AppRoutes.bossPath(worldId));
              },
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              );
            },
          );
        },
      ),

      // Boss Screen
      GoRoute(
        path: AppRoutes.boss,
        name: 'boss',
        pageBuilder: (context, state) {
          final worldId = int.tryParse(state.pathParameters['worldId'] ?? '0') ?? 0;
          final worldState = ref.read(worldControllerProvider);
          final world = worldState.worlds.firstWhere(
            (w) => w.id == worldId,
            orElse: () => WorldEntity.empty(),
          );

          return CustomTransitionPage(
            key: state.pageKey,
            child: BossScreen(
              world: world,
              onVictory: () {
                // Отмечаем босса побеждённым и разблокируем следующий мир
                ref.read(worldControllerProvider.notifier).defeatBoss(worldId);
                ref.read(gameControllerProvider.notifier).saveGame();
                context.go(AppRoutes.hub);
              },
              onDefeat: () {
                context.go(AppRoutes.hub);
              },
              onExit: () {
                context.go(AppRoutes.hub);
              },
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
                  child: child,
                ),
              );
            },
          );
        },
      ),

      // Settings Screen
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: SettingsScreen(
            onClose: () {
              context.pop();
            },
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            );
          },
        ),
      ),
    ],

    // Обработка ошибок навигации
    errorPageBuilder: (context, state) => MaterialPage(
      key: state.pageKey,
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Страница не найдена',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                state.uri.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.hub),
                child: const Text('На главную'),
              ),
            ],
          ),
        ),
      ),
    ),

    // Редирект при необходимости
    redirect: (context, state) {
      // Можно добавить логику редиректа здесь
      // Например, если пользователь не авторизован
      return null;
    },
  );
});

/// Расширение для удобной навигации
extension GoRouterExtension on BuildContext {
  /// Перейти на хаб
  void goToHub() => go(AppRoutes.hub);

  /// Перейти к миру
  void goToWorld(int worldId) => push(AppRoutes.worldPath(worldId));

  /// Перейти к боссу
  void goToBoss(int worldId) => push(AppRoutes.bossPath(worldId));

  /// Открыть настройки
  void goToSettings() => push(AppRoutes.settings);
}

/// Навигационный observer для отладки
class AppNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    debugPrint('PUSH: ${route.settings.name}');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    debugPrint('POP: ${route.settings.name}');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    debugPrint('REPLACE: ${oldRoute?.settings.name} -> ${newRoute?.settings.name}');
  }
}
