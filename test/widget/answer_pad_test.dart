/// Виджет-тесты для AnswerPad
///
/// Проверяет взаимодействие с цифровой клавиатурой.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:math_shield/presentation/widgets/answer_pad.dart';

void main() {
  /// Вспомогательный виджет для тестов
  Widget createTestWidget({
    String currentInput = '',
    bool isDisabled = false,
    int maxInputLength = 4,
    void Function(String)? onDigitPressed,
    void Function()? onConfirmPressed,
    void Function()? onDeletePressed,
    void Function()? onClearPressed,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 400,
            child: AnswerPad(
              currentInput: currentInput,
              isDisabled: isDisabled,
              maxInputLength: maxInputLength,
              onDigitPressed: onDigitPressed,
              onConfirmPressed: onConfirmPressed,
              onDeletePressed: onDeletePressed,
              onClearPressed: onClearPressed,
              enableHapticFeedback: false, // Отключаем для тестов
            ),
          ),
        ),
      ),
    );
  }

  group('AnswerPad - Отображение', () {
    testWidgets('должен отображать все цифры 0-9', (tester) async {
      await tester.pumpWidget(createTestWidget());

      for (var i = 0; i <= 9; i++) {
        expect(find.text('$i'), findsOneWidget);
      }
    });

    testWidgets('должен отображать "?" при пустом вводе', (tester) async {
      await tester.pumpWidget(createTestWidget(currentInput: ''));

      expect(find.text('?'), findsOneWidget);
    });

    testWidgets('должен отображать текущий ввод', (tester) async {
      await tester.pumpWidget(createTestWidget(currentInput: '42'));

      expect(find.text('42'), findsOneWidget);
      expect(find.text('?'), findsNothing);
    });

    testWidgets('должен отображать кнопку подтверждения', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('OK'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('должен отображать кнопки удаления и очистки', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byIcon(Icons.backspace_outlined), findsOneWidget);
      expect(find.byIcon(Icons.clear), findsOneWidget);
    });
  });

  group('AnswerPad - Нажатие цифр', () {
    testWidgets('должен вызывать onDigitPressed при нажатии на цифру',
        (tester) async {
      String? pressedDigit;

      await tester.pumpWidget(createTestWidget(
        onDigitPressed: (digit) => pressedDigit = digit,
      ));

      await tester.tap(find.text('5'));
      await tester.pump();

      expect(pressedDigit, '5');
    });

    testWidgets('должен работать со всеми цифрами', (tester) async {
      final pressedDigits = <String>[];

      await tester.pumpWidget(createTestWidget(
        onDigitPressed: (digit) => pressedDigits.add(digit),
      ));

      for (var i = 0; i <= 9; i++) {
        await tester.tap(find.text('$i'));
        await tester.pump();
      }

      expect(pressedDigits, ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']);
    });

    testWidgets('не должен вызывать callback при достижении maxInputLength',
        (tester) async {
      String? pressedDigit;

      await tester.pumpWidget(createTestWidget(
        currentInput: '1234', // maxInputLength = 4
        maxInputLength: 4,
        onDigitPressed: (digit) => pressedDigit = digit,
      ));

      await tester.tap(find.text('5'));
      await tester.pump();

      expect(pressedDigit, isNull);
    });
  });

  group('AnswerPad - Кнопка удаления', () {
    testWidgets('должен вызывать onDeletePressed при наличии ввода',
        (tester) async {
      var deleteCalled = false;

      await tester.pumpWidget(createTestWidget(
        currentInput: '42',
        onDeletePressed: () => deleteCalled = true,
      ));

      await tester.tap(find.byIcon(Icons.backspace_outlined));
      await tester.pump();

      expect(deleteCalled, true);
    });

    testWidgets('не должен вызывать onDeletePressed при пустом вводе',
        (tester) async {
      var deleteCalled = false;

      await tester.pumpWidget(createTestWidget(
        currentInput: '',
        onDeletePressed: () => deleteCalled = true,
      ));

      await tester.tap(find.byIcon(Icons.backspace_outlined));
      await tester.pump();

      expect(deleteCalled, false);
    });
  });

  group('AnswerPad - Кнопка очистки', () {
    testWidgets('должен вызывать onClearPressed при наличии ввода',
        (tester) async {
      var clearCalled = false;

      await tester.pumpWidget(createTestWidget(
        currentInput: '123',
        onClearPressed: () => clearCalled = true,
      ));

      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      expect(clearCalled, true);
    });

    testWidgets('не должен вызывать onClearPressed при пустом вводе',
        (tester) async {
      var clearCalled = false;

      await tester.pumpWidget(createTestWidget(
        currentInput: '',
        onClearPressed: () => clearCalled = true,
      ));

      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      expect(clearCalled, false);
    });
  });

  group('AnswerPad - Кнопка подтверждения', () {
    testWidgets('должен вызывать onConfirmPressed при наличии ввода',
        (tester) async {
      var confirmCalled = false;

      await tester.pumpWidget(createTestWidget(
        currentInput: '42',
        onConfirmPressed: () => confirmCalled = true,
      ));

      await tester.tap(find.text('OK'));
      await tester.pump();

      expect(confirmCalled, true);
    });

    testWidgets('не должен вызывать onConfirmPressed при пустом вводе',
        (tester) async {
      var confirmCalled = false;

      await tester.pumpWidget(createTestWidget(
        currentInput: '',
        onConfirmPressed: () => confirmCalled = true,
      ));

      await tester.tap(find.text('OK'));
      await tester.pump();

      expect(confirmCalled, false);
    });
  });

  group('AnswerPad - Disabled state', () {
    testWidgets('не должен реагировать на нажатия в disabled состоянии',
        (tester) async {
      String? pressedDigit;
      var deleteCalled = false;
      var clearCalled = false;
      var confirmCalled = false;

      await tester.pumpWidget(createTestWidget(
        currentInput: '42',
        isDisabled: true,
        onDigitPressed: (digit) => pressedDigit = digit,
        onDeletePressed: () => deleteCalled = true,
        onClearPressed: () => clearCalled = true,
        onConfirmPressed: () => confirmCalled = true,
      ));

      // Пробуем нажать на все кнопки
      await tester.tap(find.text('5'));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.backspace_outlined));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      await tester.tap(find.text('OK'));
      await tester.pump();

      expect(pressedDigit, isNull);
      expect(deleteCalled, false);
      expect(clearCalled, false);
      expect(confirmCalled, false);
    });
  });

  group('CompactAnswerPad', () {
    testWidgets('должен отображать все цифры 0-9', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 300,
            height: 200,
            child: CompactAnswerPad(
              onAnswer: (_) {},
            ),
          ),
        ),
      ));

      for (var i = 0; i <= 9; i++) {
        expect(find.text('$i'), findsOneWidget);
      }
    });

    testWidgets('должен вызывать onAnswer при нажатии', (tester) async {
      int? answeredValue;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 300,
            height: 200,
            child: CompactAnswerPad(
              onAnswer: (value) => answeredValue = value,
            ),
          ),
        ),
      ));

      await tester.tap(find.text('7'));
      await tester.pump();

      expect(answeredValue, 7);
    });

    testWidgets('не должен вызывать onAnswer в disabled состоянии',
        (tester) async {
      int? answeredValue;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 300,
            height: 200,
            child: CompactAnswerPad(
              isDisabled: true,
              onAnswer: (value) => answeredValue = value,
            ),
          ),
        ),
      ));

      await tester.tap(find.text('7'));
      await tester.pump();

      expect(answeredValue, isNull);
    });
  });

  group('HorizontalAnswerPad', () {
    testWidgets('должен отображать все цифры 0-9', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 600,
            child: HorizontalAnswerPad(
              onDigitPressed: (_) {},
            ),
          ),
        ),
      ));

      for (var i = 0; i <= 9; i++) {
        expect(find.text('$i'), findsOneWidget);
      }
    });

    testWidgets('должен вызывать onDigitPressed при нажатии', (tester) async {
      String? pressedDigit;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 600,
            child: HorizontalAnswerPad(
              onDigitPressed: (digit) => pressedDigit = digit,
            ),
          ),
        ),
      ));

      await tester.tap(find.text('3'));
      await tester.pump();

      expect(pressedDigit, '3');
    });

    testWidgets('не должен принимать ввод при достижении maxInputLength',
        (tester) async {
      String? pressedDigit;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 600,
            child: HorizontalAnswerPad(
              currentInput: '1234',
              maxInputLength: 4,
              onDigitPressed: (digit) => pressedDigit = digit,
            ),
          ),
        ),
      ));

      await tester.tap(find.text('5'));
      await tester.pump();

      expect(pressedDigit, isNull);
    });
  });
}
