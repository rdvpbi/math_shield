/// Классы ошибок для обработки исключений в приложении
///
/// Используются с Either<Failure, T> для безопасной обработки ошибок
/// без выбрасывания исключений.
library;

/// Базовый абстрактный класс ошибки
///
/// Все ошибки в приложении наследуют этот класс.
/// Содержит сообщение об ошибке и опциональный стек-трейс.
abstract class Failure {
  /// Человекочитаемое сообщение об ошибке
  final String message;

  /// Опциональный стек-трейс для отладки
  final StackTrace? stackTrace;

  const Failure({
    required this.message,
    this.stackTrace,
  });

  @override
  String toString() => '$runtimeType: $message';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Failure && other.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}

/// Ошибка сервера (сетевые запросы, API)
///
/// Используется когда:
/// - Нет соединения с интернетом
/// - Сервер вернул ошибку
/// - Таймаут запроса
class ServerFailure extends Failure {
  /// HTTP код ошибки (если применимо)
  final int? statusCode;

  const ServerFailure({
    required super.message,
    super.stackTrace,
    this.statusCode,
  });

  /// Фабрика для ошибки отсутствия соединения
  factory ServerFailure.noConnection() {
    return const ServerFailure(
      message: 'Нет подключения к интернету',
    );
  }

  /// Фабрика для ошибки таймаута
  factory ServerFailure.timeout() {
    return const ServerFailure(
      message: 'Превышено время ожидания ответа от сервера',
    );
  }

  /// Фабрика для неизвестной ошибки сервера
  factory ServerFailure.unknown([String? details]) {
    return ServerFailure(
      message: details ?? 'Произошла неизвестная ошибка сервера',
    );
  }
}

/// Ошибка кэша (локальное хранилище)
///
/// Используется когда:
/// - Не удалось прочитать данные из SharedPreferences
/// - Не удалось записать данные
/// - Данные повреждены
class CacheFailure extends Failure {
  /// Ключ, с которым произошла ошибка
  final String? key;

  const CacheFailure({
    required super.message,
    super.stackTrace,
    this.key,
  });

  /// Фабрика для ошибки чтения
  factory CacheFailure.readError(String key) {
    return CacheFailure(
      message: 'Не удалось прочитать данные из кэша',
      key: key,
    );
  }

  /// Фабрика для ошибки записи
  factory CacheFailure.writeError(String key) {
    return CacheFailure(
      message: 'Не удалось сохранить данные в кэш',
      key: key,
    );
  }

  /// Фабрика для повреждённых данных
  factory CacheFailure.corruptedData(String key) {
    return CacheFailure(
      message: 'Данные в кэше повреждены',
      key: key,
    );
  }

  /// Фабрика для отсутствующих данных
  factory CacheFailure.notFound(String key) {
    return CacheFailure(
      message: 'Данные не найдены в кэше',
      key: key,
    );
  }
}

/// Ошибка валидации (некорректные данные)
///
/// Используется когда:
/// - Введены некорректные данные
/// - Нарушены бизнес-правила
/// - Значение вне допустимого диапазона
class ValidationFailure extends Failure {
  /// Поле, в котором произошла ошибка
  final String? field;

  /// Некорректное значение
  final dynamic invalidValue;

  const ValidationFailure({
    required super.message,
    super.stackTrace,
    this.field,
    this.invalidValue,
  });

  /// Фабрика для ошибки диапазона
  factory ValidationFailure.outOfRange({
    required String field,
    required dynamic value,
    required num min,
    required num max,
  }) {
    return ValidationFailure(
      message: 'Значение $field должно быть от $min до $max',
      field: field,
      invalidValue: value,
    );
  }

  /// Фабрика для ошибки обязательного поля
  factory ValidationFailure.required(String field) {
    return ValidationFailure(
      message: 'Поле $field обязательно для заполнения',
      field: field,
    );
  }

  /// Фабрика для ошибки некорректного формата
  factory ValidationFailure.invalidFormat(String field, [String? expected]) {
    final expectedPart = expected != null ? '. Ожидается: $expected' : '';
    return ValidationFailure(
      message: 'Некорректный формат поля $field$expectedPart',
      field: field,
    );
  }

  /// Фабрика для ошибки некорректного множителя (0-9)
  factory ValidationFailure.invalidMultiplier(int value) {
    return ValidationFailure(
      message: 'Множитель должен быть от 0 до 9',
      field: 'multiplier',
      invalidValue: value,
    );
  }

  /// Фабрика для ошибки некорректного ответа
  factory ValidationFailure.invalidAnswer(int value) {
    return ValidationFailure(
      message: 'Ответ должен быть неотрицательным числом',
      field: 'answer',
      invalidValue: value,
    );
  }
}

/// Ошибка игровой логики
///
/// Используется когда:
/// - Нарушена игровая логика
/// - Невозможное состояние игры
class GameFailure extends Failure {
  const GameFailure({
    required super.message,
    super.stackTrace,
  });

  /// Фабрика для ошибки заблокированного мира
  factory GameFailure.worldLocked(int worldId) {
    return GameFailure(
      message: 'Мир $worldId ещё не разблокирован',
    );
  }

  /// Фабрика для ошибки отсутствия жизней
  factory GameFailure.noLivesLeft() {
    return const GameFailure(
      message: 'Закончились жизни',
    );
  }

  /// Фабрика для ошибки некорректного состояния босса
  factory GameFailure.invalidBossState(String state) {
    return GameFailure(
      message: 'Некорректное состояние босса: $state',
    );
  }
}
