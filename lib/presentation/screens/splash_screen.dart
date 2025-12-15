/// Экран загрузки (Splash Screen)
///
/// Отображает логотип игры и загружает начальные данные.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/game_constants.dart';
import '../theme/app_colors.dart';

/// Экран загрузки
class SplashScreen extends ConsumerStatefulWidget {
  /// Callback после завершения загрузки
  final VoidCallback? onLoadComplete;

  /// Длительность показа в миллисекундах
  final int durationMs;

  const SplashScreen({
    super.key,
    this.onLoadComplete,
    this.durationMs = 2500,
  });

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _loadingController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<double> _loadingProgress;

  bool _isLoading = true;
  String _loadingMessage = 'Загрузка...';

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startLoading();
  }

  void _initAnimations() {
    // Анимация логотипа
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeIn),
    );

    // Анимация текста
    _textController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );

    // Анимация загрузки
    _loadingController = AnimationController(
      duration: Duration(milliseconds: widget.durationMs),
      vsync: this,
    );

    _loadingProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _loadingController, curve: Curves.easeInOut),
    );

    // Запуск последовательности анимаций
    _logoController.forward().then((_) {
      _textController.forward();
    });
  }

  Future<void> _startLoading() async {
    // Имитация загрузки данных
    _loadingController.forward();

    // Этапы загрузки
    await _loadStep('Инициализация...', 0.2);
    await _loadStep('Загрузка миров...', 0.4);
    await _loadStep('Подготовка боссов...', 0.6);
    await _loadStep('Настройка звуков...', 0.8);
    await _loadStep('Готово!', 1.0);

    setState(() => _isLoading = false);

    // Небольшая задержка перед переходом
    await Future.delayed(const Duration(milliseconds: 500));

    widget.onLoadComplete?.call();
  }

  Future<void> _loadStep(String message, double progress) async {
    if (!mounted) return;
    setState(() => _loadingMessage = message);
    // Ждём пока анимация дойдёт до нужной точки
    await Future.delayed(Duration(
      milliseconds: (widget.durationMs * (progress - (_loadingProgress.value))).toInt().clamp(100, 500),
    ));
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary.withValues(alpha: 0.3),
              AppColors.backgroundDark,
              AppColors.backgroundDark,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // Логотип
                _buildLogo(),

                const SizedBox(height: UIConstants.paddingLarge),

                // Название игры
                _buildTitle(),

                const Spacer(flex: 2),

                // Индикатор загрузки
                _buildLoadingIndicator(),

                const SizedBox(height: UIConstants.paddingLarge),

                // Сообщение загрузки
                _buildLoadingMessage(),

                const Spacer(),

                // Копирайт
                _buildCopyright(),

                const SizedBox(height: UIConstants.paddingMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: _logoController,
      builder: (context, child) {
        return Transform.scale(
          scale: _logoScale.value,
          child: Opacity(
            opacity: _logoOpacity.value,
            child: child,
          ),
        );
      },
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              AppColors.primary,
              AppColors.primaryDark,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.5),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shield,
                size: 60,
                color: Colors.white,
              ),
              SizedBox(height: 4),
              Text(
                '×',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return FadeTransition(
      opacity: _textOpacity,
      child: Column(
        children: [
          const Text(
            'MATH',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: 8,
            ),
          ),
          const Text(
            'SHIELD',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: AppColors.accent,
              letterSpacing: 8,
            ),
          ),
          const SizedBox(height: UIConstants.paddingSmall),
          Text(
            'Защити мир умножением!',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return AnimatedBuilder(
      animation: _loadingProgress,
      builder: (context, child) {
        return SizedBox(
          width: 200,
          child: Column(
            children: [
              // Прогресс-бар
              ClipRRect(
                borderRadius: BorderRadius.circular(UIConstants.borderRadiusSmall),
                child: LinearProgressIndicator(
                  value: _loadingProgress.value,
                  backgroundColor: AppColors.surface,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _isLoading ? AppColors.primary : AppColors.success,
                  ),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: UIConstants.paddingSmall),
              // Процент
              Text(
                '${(_loadingProgress.value * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingMessage() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: Text(
        _loadingMessage,
        key: ValueKey(_loadingMessage),
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildCopyright() {
    return Text(
      '© 2024 Math Shield',
      style: TextStyle(
        fontSize: 12,
        color: AppColors.textTertiary,
      ),
    );
  }
}
