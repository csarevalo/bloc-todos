import 'package:bloc_test/bloc_test.dart';
import 'package:bloc_todos/edit_todo/bloc/edit_todo_bloc.dart';
import 'package:bloc_todos/edit_todo/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockingjay/mockingjay.dart';
import 'package:todos_repository/todos_repository.dart';

import '../../helpers/helpers.dart';

class MockEditTodoBloc extends MockBloc<EditTodoEvent, EditTodoState>
    implements EditTodoBloc {}

void main() {
  final mockTodo = Todo(
    id: 'id 1',
    title: 'title 1',
    description: 'description 1',
  );
  const titleTextFormField = Key('editTodoView_title_textFormField');
  group('TitleField', () {
    late EditTodoBloc editTodoBloc;

    setUp(() {
      editTodoBloc = MockEditTodoBloc();
      when(() => editTodoBloc.state).thenReturn(
        EditTodoState(
          initialTodo: mockTodo,
          title: mockTodo.title,
          description: mockTodo.description,
        ),
      );
    });

    Widget buildSubject() {
      return BlocProvider.value(
        value: editTodoBloc,
        child: const Material(
          child: TitleField(),
        ),
      );
    }

    group('constructor', () {
      test('works properly', () {
        expect(() => const TitleField(), returnsNormally);
      });
      test('test buildSubject() works properly', () {
        expect(buildSubject, returnsNormally);
      });
    });

    testWidgets(
      'renders correct title',
      (WidgetTester tester) async {
        await tester.pumpApp(buildSubject());
        expect(find.byType(TitleField), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(TitleField),
            matching: find.text(mockTodo.title),
          ),
          findsAtLeastNWidgets(1),
        );
      },
    );

    testWidgets(
      'is disabled when status is loading or success',
      (WidgetTester tester) async {
        when(() => editTodoBloc.state).thenReturn(
          const EditTodoState(
            status: EditTodoStatus.loading,
            title: 'title',
          ),
        );

        await tester.pumpApp(buildSubject());
        expect(find.byType(TitleField), findsOneWidget);

        final textfield = tester.widget<TextFormField>(
          find.byKey(titleTextFormField),
        );
        expect(textfield.enabled, false);
      },
    );

    testWidgets(
      'adds EditTodoTitleChanged '
      'to EditTodoBloc '
      'when a new value is entered',
      (WidgetTester tester) async {
        await tester.pumpApp(buildSubject());
        await tester.enterText(
          find.byKey(titleTextFormField),
          'new title',
        );
        verify(
          () => editTodoBloc.add(
            const EditTodoTitleChanged('new title'),
          ),
        ).called(1);
      },
    );
  });
}
