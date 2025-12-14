/// Расширения Dart для удобной работы с базовыми типами
library;

import 'dart:math' as math;

/// Расширения для [int]
extension IntExtension on int {
  /// Проверяет, является ли число чётным
  bool get isEven => this % 2 == 0;

  /// Проверяет, является ли число нечётным
  bool get isOdd => this % 2 != 0;

  /// Проверяет, находится ли число в диапазоне [min, max] включительно
  bool inRange(int min, int max) => this >= min && this <= max;

  /// Ограничивает число диапазоном [min, max]
  int clampInt(int min, int max) => math.max(min, math.min(max, this));

  /// Преобразует число в строку с ведущими нулями
  ///
  /// ```dart
  /// 5.padLeft(2) // '05'
  /// 42.padLeft(4) // '0042'
  /// ```
  String padLeft(int width, [String padding = '0']) {
    return toString().padLeft(width, padding);
  }

  /// Возвращает знак числа: -1, 0 или 1
  int get sign {
    if (this < 0) return -1;
    if (this > 0) return 1;
    return 0;
  }

  /// Преобразует секунды в Duration
  Duration get seconds => Duration(seconds: this);

  /// Преобразует миллисекунды в Duration
  Duration get milliseconds => Duration(milliseconds: this);
}

/// Расширения для [String]
extension StringExtension on String {
  /// Делает первую букву заглавной
  ///
  /// ```dart
  /// 'hello'.capitalize // 'Hello'
  /// 'HELLO'.capitalize // 'HELLO'
  /// ''.capitalize // ''
  /// ```
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Делает первую букву заглавной, остальные строчными
  ///
  /// ```dart
  /// 'hELLO'.capitalizeFirst // 'Hello'
  /// ```
  String get capitalizeFirst {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  /// Проверяет, является ли строка числом
  ///
  /// ```dart
  /// '123'.isNumeric // true
  /// '-45'.isNumeric // true
  /// '12.5'.isNumeric // true
  /// 'abc'.isNumeric // false
  /// ''.isNumeric // false
  /// ```
  bool get isNumeric {
    if (isEmpty) return false;
    return double.tryParse(this) != null;
  }

  /// Проверяет, является ли строка целым числом
  ///
  /// ```dart
  /// '123'.isInteger // true
  /// '12.5'.isInteger // false
  /// ```
  bool get isInteger {
    if (isEmpty) return false;
    return int.tryParse(this) != null;
  }

  /// Безопасно преобразует строку в int, возвращает null при ошибке
  int? toIntOrNull() => int.tryParse(this);

  /// Преобразует строку в int с значением по умолчанию
  int toIntOr(int defaultValue) => int.tryParse(this) ?? defaultValue;

  /// Проверяет, пуста ли строка или содержит только пробелы
  bool get isBlank => trim().isEmpty;

  /// Проверяет, не пуста ли строка и не содержит только пробелы
  bool get isNotBlank => !isBlank;
}

/// Расширения для [List]
extension ListExtension<T> on List<T> {
  /// Безопасно возвращает случайный элемент списка
  ///
  /// Возвращает null для пустого списка.
  ///
  /// ```dart
  /// [1, 2, 3].randomElement // 1, 2 или 3
  /// [].randomElement // null
  /// ```
  T? get randomElement {
    if (isEmpty) return null;
    final random = math.Random();
    return this[random.nextInt(length)];
  }

  /// Возвращает случайный элемент с указанным Random генератором
  ///
  /// Полезно для детерминированного тестирования.
  T? randomElementWith(math.Random random) {
    if (isEmpty) return null;
    return this[random.nextInt(length)];
  }

  /// Безопасно возвращает элемент по индексу
  ///
  /// Возвращает null если индекс вне диапазона.
  ///
  /// ```dart
  /// [1, 2, 3].getOrNull(1) // 2
  /// [1, 2, 3].getOrNull(5) // null
  /// [1, 2, 3].getOrNull(-1) // null
  /// ```
  T? getOrNull(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }

  /// Возвращает элемент по индексу или значение по умолчанию
  T getOr(int index, T defaultValue) {
    return getOrNull(index) ?? defaultValue;
  }

  /// Первый элемент или null для пустого списка
  T? get firstOrNull => isEmpty ? null : first;

  /// Последний элемент или null для пустого списка
  T? get lastOrNull => isEmpty ? null : last;
}

/// Расширения для [Iterable]
extension IterableExtension<T> on Iterable<T> {
  /// Разделяет коллекцию на группы указанного размера
  ///
  /// ```dart
  /// [1, 2, 3, 4, 5].chunked(2) // [[1, 2], [3, 4], [5]]
  /// ```
  Iterable<List<T>> chunked(int size) sync* {
    if (size <= 0) {
      throw ArgumentError('Size must be positive: $size');
    }

    final iterator = this.iterator;
    while (iterator.moveNext()) {
      final chunk = <T>[iterator.current];
      for (var i = 1; i < size && iterator.moveNext(); i++) {
        chunk.add(iterator.current);
      }
      yield chunk;
    }
  }
}

/// Расширения для [Duration]
extension DurationExtension on Duration {
  /// Форматирует Duration в строку MM:SS
  ///
  /// ```dart
  /// Duration(minutes: 2, seconds: 30).toMMSS // '02:30'
  /// ```
  String get toMMSS {
    final minutes = inMinutes.remainder(60).padLeft(2);
    final seconds = inSeconds.remainder(60).padLeft(2);
    return '$minutes:$seconds';
  }

  /// Форматирует Duration в строку с секундами
  ///
  /// ```dart
  /// Duration(seconds: 15).toSecondsString // '15'
  /// ```
  String get toSecondsString => inSeconds.toString();
}

/// Расширения для [double]
extension DoubleExtension on double {
  /// Округляет до указанного количества знаков после запятой
  ///
  /// ```dart
  /// 3.14159.roundTo(2) // 3.14
  /// ```
  double roundTo(int places) {
    final mod = math.pow(10.0, places);
    return (this * mod).round() / mod;
  }

  /// Преобразует в проценты (0.0-1.0 → 0-100)
  int get toPercent => (this * 100).round();
}
