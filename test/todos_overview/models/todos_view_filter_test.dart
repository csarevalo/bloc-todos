import 'package:bloc_todos/todos_overview/models/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todos_repository/todos_repository.dart';

void main() {
  group('TodosViewFilter', () {
    final completedTodo = Todo(
      title: 'completed',
      isCompleted: true,
    );
    final incompleteTodo = Todo(title: 'incomplete');

    group('apply', () {
      test('always returns true when filter is .all', () {
        expect(
          TodosViewFilter.all.apply(completedTodo),
          equals(true),
        );
        expect(
          TodosViewFilter.all.apply(incompleteTodo),
          equals(true),
        );
      });
      test(
          'returns true when filter is .activeOnly '
          'and the Todo is incomplete', () {
        expect(
          TodosViewFilter.activeOnly.apply(completedTodo),
          equals(false),
        );
        expect(
          TodosViewFilter.activeOnly.apply(incompleteTodo),
          equals(true),
        );
      });
      test(
          'returns true when filter is .completedOnly '
          'and the Todo is complete', () {
        expect(
          TodosViewFilter.completedOnly.apply(completedTodo),
          equals(true),
        );
        expect(
          TodosViewFilter.completedOnly.apply(incompleteTodo),
          equals(false),
        );
      });
    });
    group('applyAll', () {
      test('correctly filters provider iterable based on selected filter', () {
        final allTodos = [completedTodo, incompleteTodo];
        expect(
          TodosViewFilter.all.applyAll(allTodos),
          equals(allTodos),
        );
        expect(
          TodosViewFilter.activeOnly.applyAll(allTodos),
          equals([incompleteTodo]),
        );
        expect(
          TodosViewFilter.completedOnly.applyAll(allTodos),
          equals([completedTodo]),
        );
      });
    });
  });
}
