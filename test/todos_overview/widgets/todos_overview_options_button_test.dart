// ignore_for_file: avoid_redundant_argument_values

import 'package:bloc_test/bloc_test.dart';
import 'package:bloc_todos/todos_overview/todos_overview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todos_repository/todos_repository.dart';

import '../../helpers/helpers.dart';

class MockTodosOverviewBloc
    extends MockBloc<TodosOverviewEvent, TodosOverviewState>
    implements TodosOverviewBloc {}

class MockRepository extends Mock implements TodosRepository {}

extension on CommonFinders {
  Finder optionMenuItem({
    required TodosOverviewOption option,
    required String title,
    bool enabled = false,
  }) {
    return find.descendant(
      of: find.byWidgetPredicate(
        (w) => w is PopupMenuItem && w.value == option && w.enabled == enabled,
      ),
      matching: find.text(title),
    );
  }
}

extension on WidgetTester {
  Future<void> openOptionButtonPopup() async {
    await tap(find.byType(TodosOverviewOptionsButton));
    await pumpAndSettle();
  }
}

void main() {
  group('TodosOverviewOptionsButton', () {
    late TodosOverviewBloc todosOverviewBloc;
    setUpAll(() {
      todosOverviewBloc = MockTodosOverviewBloc();
      when(() => todosOverviewBloc.state).thenReturn(
        const TodosOverviewState(),
      );
    });
    Widget buildSubject() {
      return BlocProvider.value(
        value: todosOverviewBloc,
        child: const TodosOverviewOptionsButton(),
      );
    }

    group('constructor', () {
      testWidgets('works properly', (tester) async {
        expect(
          () => const TodosOverviewOptionsButton(),
          returnsNormally,
        );
      });
      testWidgets('buildSubject works properly for testing', (tester) async {
        expect(
          buildSubject,
          returnsNormally,
        );
      });
    });

    testWidgets('renders more_horiz_rounded icon', (tester) async {
      await tester.pumpApp(buildSubject());
      expect(
        find.byIcon(Icons.more_horiz_rounded),
        findsOneWidget,
      );
    });

    group('internal popUpMenuItem', () {
      testWidgets('is rendered', (tester) async {
        await tester.pumpApp(buildSubject());
        expect(
          find.bySpecificType<PopupMenuButton<TodosOverviewOption>>(),
          findsOneWidget,
        );
      });
      testWidgets('has no initial value', (tester) async {
        await tester.pumpApp(buildSubject());
        final popupButton = tester.widget<PopupMenuButton<TodosOverviewOption>>(
          find.bySpecificType<PopupMenuButton<TodosOverviewOption>>(),
        );
        expect(
          popupButton.initialValue,
          equals(null),
        );
      });
      group(
          'renders correct options '
          'when popup button is pressed and', () {
        testWidgets('when there are no todos', (tester) async {
          when(() => todosOverviewBloc.state).thenReturn(
            const TodosOverviewState(
              status: TodosOverviewStatus.success,
              todos: [],
            ),
          );
          await tester.pumpApp(buildSubject());
          await tester.openOptionButtonPopup();
          expect(
            find.optionMenuItem(
              option: TodosOverviewOption.clearCompleted,
              title: l10n.todosOverviewOptionsClearCompleted,
              enabled: false, //hasTodos == false && completedTodos is Not > 0
            ),
            findsOneWidget,
          );
          expect(
            find.optionMenuItem(
              option: TodosOverviewOption.toggleAll,
              title: l10n.todosOverviewOptionsMarkAllIncomplete,
              enabled: false, //hasTodos == false
            ),
            findsOneWidget,
          );
        });
        testWidgets('when completedTodosAmount equals state.todos.length',
            (tester) async {
          when(() => todosOverviewBloc.state).thenReturn(
            TodosOverviewState(
              status: TodosOverviewStatus.success,
              todos: [
                Todo(title: 'a', isCompleted: true),
                Todo(title: 'b', isCompleted: true),
              ],
            ),
          );

          await tester.pumpApp(buildSubject());
          await tester.openOptionButtonPopup();

          expect(
            find.optionMenuItem(
              option: TodosOverviewOption.clearCompleted,
              title: l10n.todosOverviewOptionsClearCompleted,
              enabled: true, //hasTodos && completedTodos > 0
            ),
            findsOneWidget,
          );
          expect(
            find.optionMenuItem(
              option: TodosOverviewOption.toggleAll,
              title: l10n.todosOverviewOptionsMarkAllIncomplete,
              enabled: true, //hasTodos
            ),
            findsOneWidget,
          );
        });
        testWidgets(
            'when completedTodosAmount does NOT equals state.todos.length',
            (tester) async {
          when(() => todosOverviewBloc.state).thenReturn(
            TodosOverviewState(
              status: TodosOverviewStatus.success,
              todos: [
                Todo(title: 'a', isCompleted: true),
                Todo(title: 'b', isCompleted: false),
              ],
            ),
          );

          await tester.pumpApp(buildSubject());
          await tester.openOptionButtonPopup();

          expect(
            find.optionMenuItem(
              option: TodosOverviewOption.clearCompleted,
              title: l10n.todosOverviewOptionsClearCompleted,
              enabled: true, //hasTodos && completedTodos > 0
            ),
            findsOneWidget,
          );
          expect(
            find.optionMenuItem(
              option: TodosOverviewOption.toggleAll,
              title: l10n.todosOverviewOptionsMarkAllComplete,
              enabled: true, //hasTodos
            ),
            findsOneWidget,
          );
        });
      });
      testWidgets(
          'adds TodosOverviewToggleAllRequested event '
          'to TodosOverviewBloc '
          'when toggleAll option is pressed', (tester) async {
        when(() => todosOverviewBloc.state).thenReturn(
          TodosOverviewState(
            status: TodosOverviewStatus.success,
            todos: [
              Todo(title: 'a', isCompleted: true),
              Todo(title: 'b', isCompleted: false),
            ],
          ),
        );
        await tester.pumpApp(buildSubject());
        await tester.openOptionButtonPopup();

        await tester.tap(
          find.optionMenuItem(
            option: TodosOverviewOption.toggleAll,
            title: l10n.todosOverviewOptionsMarkAllComplete,
            enabled: true, //hasTodos && completedTodos > 0
          ),
        );
        await tester.pumpAndSettle();
        verify(
          () => todosOverviewBloc.add(
            const TodosOverviewToggleAllRequested(),
          ),
        ).called(1);
      });
      testWidgets(
          'adds TodosOverviewClearCompletedRequested event '
          'to TodosOverviewBloc '
          'when clearAllCompleted option is pressed', (tester) async {
        when(() => todosOverviewBloc.state).thenReturn(
          TodosOverviewState(
            status: TodosOverviewStatus.success,
            todos: [
              Todo(title: 'a', isCompleted: true),
              Todo(title: 'b', isCompleted: false),
            ],
          ),
        );
        await tester.pumpApp(buildSubject());
        await tester.openOptionButtonPopup();

        await tester.tap(
          find.optionMenuItem(
            option: TodosOverviewOption.clearCompleted,
            title: l10n.todosOverviewOptionsClearCompleted,
            enabled: true, //hasTodos && completedTodos > 0
          ),
        );
        await tester.pumpAndSettle();
        verify(
          () => todosOverviewBloc.add(
            const TodosOverviewClearCompletedRequested(),
          ),
        ).called(1);
      });
    });
  });
}
