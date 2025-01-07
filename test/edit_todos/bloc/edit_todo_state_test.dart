// ignore_for_file: avoid_redundant_argument_values

import 'package:bloc_todos/edit_todo/bloc/edit_todo_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todos_repository/todos_repository.dart';

void main() {
  group('EditTodoState', () {
    final mockInitialTodo = Todo(
      id: '1',
      title: 'title 1',
      description: 'description 1',
    );

    EditTodoState createSubject({
      EditTodoStatus status = EditTodoStatus.initial,
      String title = '',
      String description = '',
      Todo? initialTodo,
    }) {
      return EditTodoState(
        status: status,
        title: title,
        description: description,
        initialTodo: initialTodo,
      );
    }

    test('supports value equality', () {
      expect(createSubject(), equals(createSubject()));
    });

    test('props are correct', () {
      expect(
        createSubject(
          status: EditTodoStatus.success,
          initialTodo: mockInitialTodo,
          title: 'title',
          description: 'description',
        ).props,
        equals(<Object?>[
          EditTodoStatus.success, //status
          mockInitialTodo, //initialTodo
          'title', //title
          'description', //description
        ]),
      );
    });

    test(
      'isNewTodo returns true '
      'when a new todo is being created',
      () {
        expect(
          createSubject(
            initialTodo: null,
          ).isNewTodo,
          isTrue,
        );
      },
    );

    group('copyWith()', () {
      test('returns the same object when no arguments are provided', () {
        expect(
          createSubject().copyWith(),
          equals(createSubject()),
        );
      });

      test('returns the same value for every parameter if null is provided',
          () {
        expect(
          createSubject().copyWith(
            status: null,
            title: null,
            description: null,
            initialTodo: null,
          ),
          equals(createSubject()),
        );
      });
      test('replaces every non-null value', () {
        expect(
          createSubject().copyWith(
            status: EditTodoStatus.success,
            title: 'title',
            description: 'description',
            initialTodo: mockInitialTodo,
          ),
          equals(
            createSubject(
              status: EditTodoStatus.success,
              title: 'title',
              description: 'description',
              initialTodo: mockInitialTodo,
            ),
          ),
        );
      });
    });
  });
}
