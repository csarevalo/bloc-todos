import 'package:bloc_todos/todos_overview/bloc/todos_overview_bloc.dart';
import 'package:bloc_todos/todos_overview/models/todos_view_filter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todos_repository/todos_repository.dart';

void main() {
  group('TodosOverviewEvent', () {
    final mockTodo = Todo(
      id: '1',
      title: 'title 1',
      description: 'description 1',
    );
    group('TodosOverviewSubscriptionRequested', () {
      test('supports value equalitiy', () {
        expect(
          const TodosOverviewSubscriptionRequested(),
          equals(const TodosOverviewSubscriptionRequested()),
        );
      });
      test('props are correct', () {
        expect(
          const TodosOverviewSubscriptionRequested().props,
          <Object?>[],
        );
      });
    });
    group('TodosOverviewTodoCompletionToggled', () {
      test('supports value equalitiy', () {
        expect(
          TodosOverviewTodoCompletionToggled(
            todo: mockTodo,
            isCompleted: !mockTodo.isCompleted,
          ),
          equals(
            TodosOverviewTodoCompletionToggled(
              todo: mockTodo,
              isCompleted: !mockTodo.isCompleted,
            ),
          ),
        );
      });
      test('props are correct', () {
        expect(
          TodosOverviewTodoCompletionToggled(
            todo: mockTodo,
            isCompleted: !mockTodo.isCompleted,
          ).props,
          <Object?>[
            mockTodo, // `todo`
            !mockTodo.isCompleted, // isCompleted
          ],
        );
      });
    });
    group('TodosOverviewTodoDeleted', () {
      test('supports value equalitiy', () {
        expect(
          TodosOverviewTodoDeleted(todo: mockTodo),
          equals(
            TodosOverviewTodoDeleted(todo: mockTodo),
          ),
        );
      });
      test('props are correct', () {
        expect(
          TodosOverviewTodoDeleted(
            todo: mockTodo,
          ).props,
          <Object?>[
            mockTodo, // `todo`
          ],
        );
      });
    });
    group('TodosOverviewUndoDeletionRequested', () {
      test('supports value equalitiy', () {
        expect(
          const TodosOverviewUndoDeletionRequested(),
          equals(const TodosOverviewUndoDeletionRequested()),
        );
      });
      test('props are correct', () {
        expect(
          const TodosOverviewUndoDeletionRequested().props,
          <Object?>[],
        );
      });
    });
    group('TodosOverviewFilterChanged', () {
      test('supports value equalitiy', () {
        expect(
          const TodosOverviewFilterChanged(filter: TodosViewFilter.all),
          equals(
            const TodosOverviewFilterChanged(filter: TodosViewFilter.all),
          ),
        );
      });
      test('props are correct', () {
        expect(
          const TodosOverviewFilterChanged(
            filter: TodosViewFilter.all,
          ).props,
          <Object?>[
            TodosViewFilter.all, // `filter`
          ],
        );
      });
    });
    group('TodosOverviewToggleAllRequested', () {
      test('supports value equalitiy', () {
        expect(
          const TodosOverviewToggleAllRequested(),
          equals(const TodosOverviewToggleAllRequested()),
        );
      });
      test('props are correct', () {
        expect(
          const TodosOverviewToggleAllRequested().props,
          <Object?>[],
        );
      });
    });
    group('TodosOverviewClearCompletedRequested', () {
      test('supports value equalitiy', () {
        expect(
          const TodosOverviewClearCompletedRequested(),
          equals(const TodosOverviewClearCompletedRequested()),
        );
      });
      test('props are correct', () {
        expect(
          const TodosOverviewClearCompletedRequested().props,
          <Object?>[],
        );
      });
    });
  });
}
