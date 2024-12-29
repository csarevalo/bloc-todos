// ignore_for_file: avoid_redundant_argument_values

import 'package:bloc_todos/todos_overview/bloc/todos_overview_bloc.dart';
import 'package:bloc_todos/todos_overview/models/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todos_repository/todos_repository.dart';

void main() {
  final mockTodo = Todo(
    id: '0',
    title: 'todo 0',
    description: 'description 0',
  );
  final mockTodos = [mockTodo];
  group('TodosOverviewState', () {
    TodosOverviewState createSubject({
      TodosOverviewStatus status = TodosOverviewStatus.initial,
      List<Todo>? todos,
      TodosViewFilter filter = TodosViewFilter.all,
      Todo? lastDeletedTodo,
    }) {
      return TodosOverviewState(
        status: status,
        todos: todos ?? mockTodos,
        filter: filter,
        lastDeletedTodo: lastDeletedTodo,
      );
    }

    test('supports value equality', () {
      expect(
        createSubject(),
        equals(createSubject()),
      );
    });
    test('props are correct', () {
      expect(
        createSubject(
          status: TodosOverviewStatus.initial,
          todos: mockTodos,
          filter: TodosViewFilter.all,
          lastDeletedTodo: null,
        ).props,
        equals(<Object?>[
          TodosOverviewStatus.initial,
          mockTodos,
          TodosViewFilter.all,
          null,
        ]),
      );
    });
    test('filteredTodos returns todos filtered by filter', () {
      expect(
        createSubject(
          todos: mockTodos,
          filter: TodosViewFilter.completedOnly,
        ).filteredTodos,
        mockTodos.where((t) => t.isCompleted).toList(),
      );
    });
    group('copyWith', () {
      test('returns the same object if no arguments are provided', () {
        expect(
          createSubject().copyWith(),
          equals(createSubject()),
        );
      });
      test('retains the old value for every parameter null is provided', () {
        expect(
          createSubject().copyWith(
            status: null,
            todos: null,
            filter: null,
            lastDeletedTodo: null,
          ),
          equals(createSubject()),
        );
      });
      test('replaces every non-null parameter', () {
        expect(
          createSubject().copyWith(
            status: TodosOverviewStatus.success,
            todos: [],
            filter: TodosViewFilter.completedOnly,
            lastDeletedTodo: () => mockTodo,
          ),
          createSubject(
            status: TodosOverviewStatus.success,
            todos: [],
            filter: TodosViewFilter.completedOnly,
            lastDeletedTodo: mockTodo,
          ),
        );
      });
      test('can copyWith null lastDeletedTodo', () {
        expect(
          createSubject(lastDeletedTodo: mockTodo).copyWith(
            lastDeletedTodo: () => null,
          ),
          createSubject(lastDeletedTodo: null),
        );
      });
    });
  });
}
