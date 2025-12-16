/// Math Shield — Образовательная игра для изучения таблицы умножения
///
/// Точка входа в приложение.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'application/providers/providers.dart';
import 'audio/audio_manager.dart';
import 'navigation/app_router.dart';
import 'presentation/theme/app_theme.dart';

void main() async {
  // Инициализируем Flutter binding
  WidgetsFlutterBinding.ensureInitialized();

  // Настраиваем ориентацию экрана (landscape для игры)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Полноэкранный режим (immersive)
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
    overlays: [],
  );

  // Настраиваем системный UI (для случаев когда UI виден)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarContrastEnforced: false,
    ),
  );

  // Инициализируем SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();

  // Инициализируем аудио
  await AudioManager.instance.initialize();

  // Предзагружаем звуки для быстрого отклика
  await AudioManager.instance.preloadGameSounds();

  // Запускаем приложение
  runApp(
    ProviderScope(
      overrides: [
        // Переопределяем provider для SharedPreferences
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const AudioLifecycleWrapper(
        child: MathShieldApp(),
      ),
    ),
  );
}

/// Главное приложение Math Shield
class MathShieldApp extends ConsumerWidget {
  const MathShieldApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Получаем роутер
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      // Конфигурация роутера
      routerConfig: router,

      // Информация о приложении
      title: 'Math Shield',
      debugShowCheckedModeBanner: false,

      // Тема приложения
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,

      // Локализация
      locale: const Locale('ru', 'RU'),
      supportedLocales: const [
        Locale('ru', 'RU'),
        Locale('en', 'US'),
      ],

      // Настройки скроллинга для детей
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        physics: const BouncingScrollPhysics(),
      ),

      // Builder для дополнительных настроек
      builder: (context, child) {
        // Ограничиваем масштабирование текста для консистентного UI
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              MediaQuery.of(context).textScaler.scale(1.0).clamp(0.8, 1.2),
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

/// Lifecycle observer для управления аудио
class AppLifecycleObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        // Приглушаем музыку когда приложение в фоне
        AudioManager.instance.pauseMusic();
        break;
      case AppLifecycleState.resumed:
        // Возобновляем музыку когда приложение активно
        AudioManager.instance.resumeMusic();
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        // Останавливаем всё при закрытии
        AudioManager.instance.stopAll();
        break;
    }
  }
}

/// Виджет для управления жизненным циклом аудио
class AudioLifecycleWrapper extends StatefulWidget {
  final Widget child;

  const AudioLifecycleWrapper({
    super.key,
    required this.child,
  });

  @override
  State<AudioLifecycleWrapper> createState() => _AudioLifecycleWrapperState();
}

class _AudioLifecycleWrapperState extends State<AudioLifecycleWrapper>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        AudioManager.instance.pauseMusic();
        break;
      case AppLifecycleState.resumed:
        AudioManager.instance.resumeMusic();
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        AudioManager.instance.stopAll();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
