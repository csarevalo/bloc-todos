import 'package:bloc_todos/edit_todo/bloc/edit_todo_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EditTodoEvent', () {
    group('EditTodoSubmitted', () {
      test('supports value equality', () {
        expect(
          const EditTodoSubmitted(),
          equals(const EditTodoSubmitted()),
        );
      });
      test('props are correct', () {
        expect(
          const EditTodoSubmitted().props,
          equals(<Object?>[]),
        );
      });
    });

    group('EditTodoTitleChanged', () {
      test('supports value equality', () {
        expect(
          const EditTodoTitleChanged('title'),
          equals(const EditTodoTitleChanged('title')),
        );
      });
      test('props are correct', () {
        expect(
          const EditTodoTitleChanged('title').props,
          equals(<Object?>[
            'title', //title
          ]),
        );
      });
    });

    group('EditTodoDescriptionChanged', () {
      test('supports value equality', () {
        expect(
          const EditTodoDescriptionChanged('description'),
          equals(const EditTodoDescriptionChanged('description')),
        );
      });
      test('props are correct', () {
        expect(
          const EditTodoDescriptionChanged('description').props,
          equals(<Object?>[
            'description', //description
          ]),
        );
      });
    });
  });
}
