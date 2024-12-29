import 'package:bloc_todos/todos_overview/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todos_repository/todos_repository.dart';

import '../../helpers/helpers.dart';

void main() {
  group('TodoListTile', () {
    final completedTask = Todo(
      id: '1',
      title: 'title 1',
      description: 'description 1',
      isCompleted: true,
    );
    final incompleteTask = Todo(
      id: '1',
      title: 'title 1',
      description: 'description 1',
    );
    final onToggleCompletedCalls = <bool>[];
    late int onDismissedCallCount;
    late int onTapCallCount;

    Widget buildSubject({Todo? todo}) {
      return Material(
        child: TodoListTile(
          todo: todo ?? incompleteTask,
          onToggleCompleted: onToggleCompletedCalls.add,
          onDismissed: (_) => onDismissedCallCount++,
          onTap: () => onTapCallCount++,
        ),
      );
    }

    setUp(() {
      onDismissedCallCount = 0;
      onTapCallCount = 0;
    });

    group('constructor', () {
      test('works properly', () {
        expect(
          () => TodoListTile(todo: incompleteTask),
          returnsNormally,
        );
      });
      test('buildSubject also works properly', () {
        expect(
          buildSubject,
          returnsNormally,
        );
      });
    });
    group('Checkbox', () {
      testWidgets('is rendered', (tester) async {
        await tester.pumpApp(buildSubject());
        expect(find.byType(Checkbox), findsOneWidget);
      });
      testWidgets('is checked when todo is completed', (tester) async {
        await tester.pumpApp(
          buildSubject(todo: completedTask),
        );
        final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
        expect(checkbox.value, isTrue);
      });
      testWidgets('is unchecked when todo is incomplete', (tester) async {
        await tester.pumpApp(
          buildSubject(todo: incompleteTask),
        );
        final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
        expect(checkbox.value, isFalse);
      });
      testWidgets(
        'calls onToggleCompleted with correct value on tapped',
        (tester) async {
          await tester.pumpApp(
            buildSubject(todo: completedTask),
          );
          await tester.tap(find.byType(Checkbox));
          await tester.pumpAndSettle();
          expect(onToggleCompletedCalls, equals([false]));
        },
      );
    });
    group('Dismissable', () {
      final todo = incompleteTask; //used by default on buildSubject();
      final dismissableKey = Key('todoListTile_dismissible_${todo.id}');
      testWidgets('is rendered', (tester) async {
        await tester.pumpApp(buildSubject());
        expect(find.byType(Dismissible), findsOneWidget);
        expect(find.byKey(dismissableKey), findsOneWidget);
      });
      testWidgets('calls onDismissed when swiped to the left', (tester) async {
        await tester.pumpApp(buildSubject());
        await tester.fling(
          find.byKey(dismissableKey),
          const Offset(-300, 0),
          1000,
        );
        await tester.pumpAndSettle();
        expect(onDismissedCallCount, equals(1));
      });
    });

    group('todo title', () {
      final todo = incompleteTask;
      testWidgets('is rendered', (tester) async {
        await tester.pumpApp(buildSubject(todo: todo));
        expect(find.text(todo.title), findsOneWidget);
      });
      testWidgets('is struckthrough when todo is completed', (tester) async {
        await tester.pumpApp(
          buildSubject(todo: completedTask),
        );
        final text = tester.widget<Text>(find.text(completedTask.title));
        expect(text.data, completedTask.title);
        expect(
          text.style,
          isA<TextStyle>().having(
            (s) => s.decoration,
            'decoration',
            TextDecoration.lineThrough,
          ),
        );
      });
    });
    group('todo description', () {
      testWidgets('is rendered', (tester) async {
        await tester.pumpApp(
          buildSubject(todo: incompleteTask),
        );
        expect(find.text(incompleteTask.description), findsOneWidget);
      });
    });

    testWidgets('calls onTap when pressed', (tester) async {
      final todo = incompleteTask; //used by default on buildSubject();
      final listTileKey = Key('todoListTile_listTile_${todo.id}');
      await tester.pumpApp(buildSubject(todo: todo));

      await tester.tap(find.byKey(listTileKey));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ListTile)); //cannot be TodoListTile
      await tester.pumpAndSettle();

      expect(onTapCallCount, equals(2));
    });
  });
}
